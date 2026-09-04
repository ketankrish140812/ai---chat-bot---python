//
//  Textures.swift
//  Chroma Orbit
//

import UIKit
import SpriteKit

/// Procedurally generated textures. The game ships with zero bundled image
/// assets besides the App Icon — every glow, spark, and trail particle is
/// drawn at launch with Core Graphics and cached as an SKTexture.
enum Textures {
    /// A soft white radial-gradient dot, tinted per-use via
    /// `particleColor` / `particleColorBlendFactor`. Used for the player's
    /// trail and every burst/shatter effect.
    static let softDot: SKTexture = {
        let size = CGSize(width: 64, height: 64)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let colors = [
                UIColor.white.withAlphaComponent(1.0).cgColor,
                UIColor.white.withAlphaComponent(0.0).cgColor
            ]
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: [0, 1]
            ) else { return }

            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: size.width / 2,
                options: []
            )
        }
        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        return texture
    }()
}
