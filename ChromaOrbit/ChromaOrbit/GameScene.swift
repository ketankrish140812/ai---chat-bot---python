//
//  GameScene.swift
//  Chroma Orbit
//
//  The complete game engine: prism spawning, orbit/launch kinematics,
//  capture and hazard detection, scoring, and camera follow. All gameplay
//  state lives here; SwiftUI only reads `gameState` to render the menu /
//  HUD / game-over chrome around this scene.
//
//  CORE LOOP
//  ---------
//  The orb is always either orbiting the current Prism, or flying in a
//  straight line after being launched by a tap. A tap releases the orb
//  tangentially at whatever angle it currently sits on the orbit ring, so
//  *when* you tap is the entire input — there is no second control. Flying
//  in a straight line means aiming error at launch grows with distance to
//  the next prism, which is what makes farther, faster prisms harder
//  without needing any extra difficulty parameter.
//
//  Landing on a prism whose hue matches the one you just launched from
//  extends a scoring combo; landing on a different hue resets it. Hazard
//  prisms (spiked, red) simply end the run on contact.
//

import SpriteKit
import UIKit

final class GameScene: SKScene {

    // MARK: Tuning

    private enum Tuning {
        static let launchSpeed: CGFloat = 460
        static let captureRadius: CGFloat = 34
        static let hazardRadius: CGFloat = 26
        static let baseScore = 10
        static let cameraLerp: CGFloat = 0.12
        static let lookahead = 4
    }

    private enum RunState {
        case idle
        case orbiting(prism: Prism, angle: CGFloat)
        case flying(launchedFrom: PrismHue, fromIndex: Int)
        case ended

        var isActive: Bool {
            switch self {
            case .orbiting, .flying: return true
            case .idle, .ended: return false
            }
        }
    }

    private let gameState: GameState
    private let cameraNode = SKCameraNode()
    private let worldNode = SKNode()

    private var orb: PlayerOrb!
    private var prisms: [Prism] = []
    private var runState: RunState = .idle
    private var lastUpdateTime: TimeInterval = 0
    private var prismsSpawned = 0
    private var velocity: CGVector = .zero

    init(gameState: GameState) {
        self.gameState = gameState
        super.init(size: CGSize(width: 400, height: 800))
        scaleMode = .resizeFill
        backgroundColor = Palette.backgroundSK
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        camera = cameraNode
        addChild(worldNode)
        worldNode.addChild(cameraNode)
        setupMenuPreview()
    }

    // MARK: Public control (called from SwiftUI)

    func startRun() {
        worldNode.removeAllChildren()
        worldNode.addChild(cameraNode)
        addStarfield()

        prisms.removeAll()
        prismsSpawned = 0
        gameState.reset()

        let firstPrism = Prism(hue: .cyan, isHazard: false, orbitRadius: 60, angularSpeed: 1.1, spinDirection: 1, index: 0)
        firstPrism.position = .zero
        worldNode.addChild(firstPrism)
        prisms.append(firstPrism)
        prismsSpawned = 1

        orb = PlayerOrb()
        orb.hue = firstPrism.hue
        orb.position = firstPrism.orbitPoint(atAngle: .pi / 2)
        worldNode.addChild(orb)
        orb.attachTrail(to: worldNode)

        runState = .orbiting(prism: firstPrism, angle: .pi / 2)

        while prisms.count < Tuning.lookahead {
            spawnNextPrism()
        }

        cameraNode.position = firstPrism.position
        gameState.phase = .playing
    }

    func returnToMenu() {
        runState = .idle
        gameState.phase = .menu
        worldNode.removeAllChildren()
        worldNode.addChild(cameraNode)
        setupMenuPreview()
    }

    // MARK: Touch input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameState.phase == .playing else { return }
        guard case let .orbiting(prism, angle) = runState else { return }
        launch(from: prism, angle: angle)
    }

    private func launch(from prism: Prism, angle: CGFloat) {
        let tangentSign = prism.spinDirection
        let dx = -sin(angle) * tangentSign
        let dy = cos(angle) * tangentSign
        velocity = CGVector(dx: dx * Tuning.launchSpeed, dy: dy * Tuning.launchSpeed)
        runState = .flying(launchedFrom: prism.hue, fromIndex: prism.index)
        HapticsManager.shared.impact(.light)
    }

    // MARK: Update loop

    override func update(_ currentTime: TimeInterval) {
        defer { lastUpdateTime = currentTime }
        guard lastUpdateTime > 0 else { return }
        let dt = min(currentTime - lastUpdateTime, 1.0 / 30.0)

        switch runState {
        case .idle, .ended:
            break

        case .orbiting(let prism, let angle):
            let newAngle = angle + prism.angularSpeed * prism.spinDirection * CGFloat(dt)
            orb.position = prism.orbitPoint(atAngle: newAngle)
            runState = .orbiting(prism: prism, angle: newAngle)

        case .flying(let launchedFrom, let fromIndex):
            orb.position.x += velocity.dx * CGFloat(dt)
            orb.position.y += velocity.dy * CGFloat(dt)
            handleFlightCollisions(launchedFrom: launchedFrom, fromIndex: fromIndex)
        }

        if gameState.phase == .playing {
            updateCamera()
        }
    }

    private func handleFlightCollisions(launchedFrom: PrismHue, fromIndex: Int) {
        for prism in prisms {
            let d = hypot(orb.position.x - prism.position.x, orb.position.y - prism.position.y)

            if prism.isHazard {
                if d <= Tuning.hazardRadius {
                    endRun()
                    return
                }
                continue
            }

            if prism.index == fromIndex { continue } // never re-dock the prism we just left
            if d <= Tuning.captureRadius {
                attach(to: prism, launchedFrom: launchedFrom)
                return
            }
        }

        // Missed everything: flew off the top/bottom of the screen, or
        // drifted past the next prism without ever getting close enough.
        let verticalBound = size.height / 2 + 140
        if abs(orb.position.y - cameraNode.position.y) > verticalBound {
            endRun()
            return
        }
        if let target = prisms.first(where: { $0.index == fromIndex + 1 }), orb.position.x > target.position.x + 140 {
            endRun()
        }
    }

    private func attach(to prism: Prism, launchedFrom: PrismHue) {
        let angle = atan2(orb.position.y - prism.position.y, orb.position.x - prism.position.x)
        runState = .orbiting(prism: prism, angle: angle)
        orb.hue = prism.hue

        if prism.hue == launchedFrom {
            gameState.combo += 1
        } else {
            gameState.combo = 1
        }
        gameState.score += Tuning.baseScore * gameState.combo

        HapticsManager.shared.impact(.medium)
        SoundManager.shared.playCapture(comboLevel: gameState.combo)
        spawnBurst(at: prism.position, hue: prism.hue)

        while prisms.count < prism.index + 1 + Tuning.lookahead {
            spawnNextPrism()
        }
        pruneOldPrisms(keepingFrom: prism.index)
    }

    private func endRun() {
        guard runState.isActive else { return }
        runState = .ended
        HapticsManager.shared.notify(.error)
        SoundManager.shared.playShatter()
        spawnShatter(at: orb.position)
        gameState.recordRunEnded()
        gameState.phase = .gameOver
    }

    // MARK: Spawning

    private func spawnNextPrism() {
        let previous = prisms.last
        let spec = LevelGenerator.nextSpec(
            afterIndex: previous?.index ?? -1,
            previousPosition: previous?.position ?? .zero,
            previousHue: previous?.hue
        )
        let prism = Prism(
            hue: spec.hue,
            isHazard: spec.isHazard,
            orbitRadius: spec.orbitRadius,
            angularSpeed: spec.angularSpeed,
            spinDirection: spec.spinDirection,
            index: prismsSpawned
        )
        prism.position = spec.position
        worldNode.addChild(prism)
        prisms.append(prism)
        prismsSpawned += 1
    }

    private func pruneOldPrisms(keepingFrom currentIndex: Int) {
        let cutoffIndex = currentIndex - 2
        let cutoffX = cameraNode.position.x - 500
        prisms.removeAll { candidate in
            guard candidate.index < cutoffIndex, candidate.position.x < cutoffX else { return false }
            candidate.removeFromParent()
            return true
        }
    }

    // MARK: Camera & background

    private func updateCamera() {
        cameraNode.position = CGPoint(
            x: cameraNode.position.x + (orb.position.x - cameraNode.position.x) * Tuning.cameraLerp,
            y: cameraNode.position.y + (orb.position.y - cameraNode.position.y) * Tuning.cameraLerp * 0.5
        )
    }

    private func addStarfield() {
        let starfield = SKNode()
        starfield.zPosition = -10
        for _ in 0..<80 {
            let dot = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.6...1.8))
            dot.fillColor = .white
            dot.strokeColor = .clear
            dot.alpha = CGFloat.random(in: 0.15...0.5)
            dot.position = CGPoint(x: CGFloat.random(in: -240...240), y: CGFloat.random(in: -420...420))
            starfield.addChild(dot)
        }
        cameraNode.addChild(starfield)
    }

    private func setupMenuPreview() {
        addStarfield()

        let previewPrism = Prism(hue: .cyan, isHazard: false, orbitRadius: 60, angularSpeed: 0.6, spinDirection: 1, index: 0)
        previewPrism.position = .zero
        worldNode.addChild(previewPrism)

        let previewOrb = PlayerOrb()
        previewOrb.hue = .cyan
        previewOrb.position = previewPrism.orbitPoint(atAngle: .pi / 2)
        worldNode.addChild(previewOrb)

        let orbitAction = SKAction.customAction(withDuration: 1000) { node, elapsed in
            node.position = previewPrism.orbitPoint(atAngle: .pi / 2 + elapsed * 0.6)
        } // `node` here is previewOrb itself; using it (rather than the captured var) keeps the action reusable.
        previewOrb.run(.repeatForever(orbitAction))

        cameraNode.position = .zero
    }

    // MARK: Effects

    private func spawnBurst(at point: CGPoint, hue: PrismHue) {
        let burst = SKEmitterNode()
        burst.particleTexture = Textures.softDot
        burst.particleBirthRate = 4000
        burst.numParticlesToEmit = 18
        burst.particleLifetime = 0.35
        burst.particleSpeed = 90
        burst.particleSpeedRange = 40
        burst.emissionAngleRange = .pi * 2
        burst.particleScale = 0.4
        burst.particleScaleSpeed = -0.8
        burst.particleAlphaSpeed = -2.5
        burst.particleColor = hue.skColor
        burst.particleColorBlendFactor = 1
        burst.particleBlendMode = .add
        burst.position = point
        burst.zPosition = 6
        worldNode.addChild(burst)
        burst.run(.sequence([.wait(forDuration: 0.5), .removeFromParent()]))
    }

    private func spawnShatter(at point: CGPoint) {
        let burst = SKEmitterNode()
        burst.particleTexture = Textures.softDot
        burst.particleBirthRate = 8000
        burst.numParticlesToEmit = 40
        burst.particleLifetime = 0.6
        burst.particleSpeed = 160
        burst.particleSpeedRange = 80
        burst.emissionAngleRange = .pi * 2
        burst.particleScale = 0.5
        burst.particleScaleSpeed = -0.8
        burst.particleAlphaSpeed = -1.8
        burst.particleColor = .white
        burst.particleColorBlendFactor = 1
        burst.particleBlendMode = .add
        burst.position = point
        burst.zPosition = 20
        worldNode.addChild(burst)
        burst.run(.sequence([.wait(forDuration: 0.7), .removeFromParent()]))
    }
}
