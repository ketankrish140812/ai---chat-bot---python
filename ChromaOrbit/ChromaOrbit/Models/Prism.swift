//
//  Prism.swift
//  Chroma Orbit
//

import SpriteKit

/// A pivot the player's orb can orbit. Regular prisms are safe to dock on
/// and are drawn as a slowly spinning colored hexagon with a soft glow.
/// Hazard prisms end the run on contact and are drawn as a fast-spinning
/// red spiked star so they read as dangerous at a glance.
final class Prism: SKNode {
    let hue: PrismHue
    let isHazard: Bool
    let orbitRadius: CGFloat
    let angularSpeed: CGFloat // radians per second
    let spinDirection: CGFloat // +1 = counter-clockwise, -1 = clockwise
    let index: Int

    private let bodyShape: SKShapeNode
    private let glow: SKShapeNode

    init(hue: PrismHue, isHazard: Bool, orbitRadius: CGFloat, angularSpeed: CGFloat, spinDirection: CGFloat, index: Int) {
        self.hue = hue
        self.isHazard = isHazard
        self.orbitRadius = orbitRadius
        self.angularSpeed = angularSpeed
        self.spinDirection = spinDirection
        self.index = index

        let radius: CGFloat = isHazard ? 16 : 14
        let path = Prism.polygonPath(radius: radius, sides: isHazard ? 8 : 6, spiky: isHazard)

        bodyShape = SKShapeNode(path: path)
        bodyShape.fillColor = isHazard ? Palette.hazardSK : hue.skColor
        bodyShape.strokeColor = .white
        bodyShape.lineWidth = 1.5
        bodyShape.glowWidth = 0.5

        let glowColor = isHazard ? Palette.hazardSK : hue.skColor
        glow = SKShapeNode(circleOfRadius: radius * 2.2)
        glow.fillColor = glowColor.withAlphaComponent(0.18)
        glow.strokeColor = .clear
        glow.blendMode = .add

        super.init()
        addChild(glow)
        addChild(bodyShape)
        zPosition = 5

        if isHazard {
            bodyShape.run(.repeatForever(.rotate(byAngle: .pi * 2, duration: 1.6)))
        } else {
            bodyShape.run(.repeatForever(.rotate(byAngle: .pi * 2 * spinDirection, duration: 6)))
            let pulse = SKAction.sequence([
                .scale(to: 1.12, duration: 0.9),
                .scale(to: 1.0, duration: 0.9)
            ])
            glow.run(.repeatForever(pulse))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// World-space point on this prism's orbit ring at angle `theta`
    /// (standard math convention: 0 = +x axis, increasing counter-clockwise).
    func orbitPoint(atAngle theta: CGFloat) -> CGPoint {
        CGPoint(x: position.x + orbitRadius * cos(theta), y: position.y + orbitRadius * sin(theta))
    }

    /// Builds either a regular polygon (safe prisms) or an alternating
    /// inner/outer-radius spiked star (hazard prisms).
    private static func polygonPath(radius: CGFloat, sides: Int, spiky: Bool) -> CGPath {
        let path = CGMutablePath()
        let outer = radius
        let inner = radius * 0.5
        let points = spiky ? sides * 2 : sides

        for i in 0..<points {
            let angle = (CGFloat(i) / CGFloat(points)) * .pi * 2 - .pi / 2
            let r = (spiky && i % 2 == 1) ? inner : outer
            let point = CGPoint(x: r * cos(angle), y: r * sin(angle))
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}
