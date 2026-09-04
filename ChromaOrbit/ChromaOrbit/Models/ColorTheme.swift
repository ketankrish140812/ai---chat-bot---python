//
//  ColorTheme.swift
//  Chroma Orbit
//

import SwiftUI
import SpriteKit

/// The three prism hues the orb can resonate with. Kept to exactly three so
/// the player can hold the whole palette in their head during fast play —
/// this is the "read the board" skill layered on top of the orbit-and-launch
/// timing skill.
enum PrismHue: Int, CaseIterable, Equatable {
    case cyan
    case magenta
    case gold

    var skColor: SKColor {
        switch self {
        case .cyan: return SKColor(red: 0.25, green: 0.90, blue: 1.00, alpha: 1.0)
        case .magenta: return SKColor(red: 1.00, green: 0.30, blue: 0.75, alpha: 1.0)
        case .gold: return SKColor(red: 1.00, green: 0.80, blue: 0.25, alpha: 1.0)
        }
    }

    var color: Color { Color(skColor) }

    /// Picks a random hue, optionally excluding one (used so two consecutive
    /// prisms don't always share a color by chance alone).
    static func random(excluding hue: PrismHue? = nil) -> PrismHue {
        var candidates = allCases
        if let hue { candidates.removeAll { $0 == hue } }
        return candidates.randomElement() ?? .cyan
    }
}

/// App-wide colors shared between SwiftUI chrome and the SpriteKit scene.
enum Palette {
    static let background = Color(red: 0.04, green: 0.05, blue: 0.10)
    static let backgroundDeep = Color(red: 0.02, green: 0.02, blue: 0.06)
    static let backgroundSK = SKColor(red: 0.04, green: 0.05, blue: 0.10, alpha: 1.0)
    static let hazard = Color(red: 1.0, green: 0.24, blue: 0.24)
    static let hazardSK = SKColor(red: 1.0, green: 0.24, blue: 0.24, alpha: 1.0)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.6)
}
