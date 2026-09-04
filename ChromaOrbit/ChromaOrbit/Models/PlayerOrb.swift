//
//  PlayerOrb.swift
//  Chroma Orbit
//

import SpriteKit

/// The player-controlled orb. It is always in exactly one of two states,
/// tracked by GameScene: orbiting a Prism, or flying in a straight line
/// after a tap-triggered launch. This node only owns its look, not its
/// motion.
final class PlayerOrb: SKNode {
    private let core: SKShapeNode
    private let trail: SKEmitterNode

    var hue: PrismHue = .cyan {
        didSet { updateColor() }
    }

    override init() {
        core = SKShapeNode(circleOfRadius: 7)
        core.fillColor = .white
        core.strokeColor = .white
        core.glowWidth = 4

        trail = SKEmitterNode()
        trail.particleTexture = Textures.softDot
        trail.particleBirthRate = 90
        trail.particleLifetime = 0.4
        trail.particleLifetimeRange = 0.15
        trail.particleSpeed = 0
        trail.particlePositionRange = CGVector(dx: 4, dy: 4)
        trail.particleAlpha = 0.55
        trail.particleAlphaSpeed = -1.4
        trail.particleScale = 0.32
        trail.particleScaleSpeed = -0.55
        trail.particleColorBlendFactor = 1
        trail.particleBlendMode = .add

        super.init()
        zPosition = 10
        addChild(core)
        updateColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Trail particles must live in world space rather than as children of
    /// this fast-moving node, or they'd slide along with the orb instead of
    /// lingering behind it. Call once after the orb has been added under the
    /// scene's world node.
    func attachTrail(to worldNode: SKNode) {
        trail.targetNode = worldNode
        addChild(trail)
    }

    private func updateColor() {
        core.fillColor = hue.skColor
        trail.particleColor = hue.skColor
    }
}
