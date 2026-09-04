//
//  LevelGenerator.swift
//  Chroma Orbit
//

import CoreGraphics

/// Produces the next Prism's parameters given how many prisms have been
/// spawned so far. Kept free of any SpriteKit dependency (pure CoreGraphics
/// math only) so the placement/difficulty curve is easy to read — and easy
/// to unit test independently of rendering, if a test target is added later.
enum LevelGenerator {
    struct PrismSpec {
        let hue: PrismHue
        let isHazard: Bool
        let orbitRadius: CGFloat
        let angularSpeed: CGFloat
        let spinDirection: CGFloat
        let position: CGPoint
    }

    /// Prisms spawned at index 0..<tutorialPrismCount are never hazards and
    /// use gentler spacing, giving a new player a few free reps before any
    /// real risk shows up.
    private static let tutorialPrismCount = 4

    /// - Parameters:
    ///   - previousIndex: the index of the most recently spawned prism, or
    ///     -1 if none has been spawned yet.
    ///   - previousPosition: that prism's world position (`.zero` if none).
    ///   - previousHue: that prism's hue, used only to avoid repeats.
    static func nextSpec(afterIndex previousIndex: Int, previousPosition: CGPoint, previousHue: PrismHue?) -> PrismSpec {
        let newIndex = previousIndex + 1
        let difficulty = min(CGFloat(newIndex) / 40.0, 1.0)

        // Reach — the distance to the next prism — is the main difficulty
        // knob: because the orb flies in a dead-straight line after launch,
        // a longer reach makes the same small aiming error at launch miss
        // by a proportionally larger margin. No separate "precision" stat
        // is needed; geometry alone does the tightening.
        let dx = CGFloat.random(in: (280 + difficulty * 160)...(360 + difficulty * 220))
        let dy = CGFloat.random(in: -170...170)
        let position = CGPoint(x: previousPosition.x + dx, y: dy)

        let isTutorial = newIndex < tutorialPrismCount
        let hazardChance = isTutorial ? 0.0 : (0.08 + 0.18 * Double(difficulty))
        let isHazard = Double.random(in: 0...1) < hazardChance

        let hue = PrismHue.random(excluding: previousHue)
        let orbitRadius = CGFloat.random(in: 46...70)
        let angularSpeed = CGFloat.random(in: (1.0 + difficulty * 0.8)...(1.6 + difficulty * 1.2))
        let spinDirection: CGFloat = Bool.random() ? 1 : -1

        return PrismSpec(
            hue: hue,
            isHazard: isHazard,
            orbitRadius: orbitRadius,
            angularSpeed: angularSpeed,
            spinDirection: spinDirection,
            position: position
        )
    }
}
