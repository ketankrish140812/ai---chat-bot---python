//
//  HapticsManager.swift
//  Chroma Orbit
//

import UIKit

/// Centralizes haptic feedback so the rest of the game doesn't need to know
/// about UIKit's separate generator types.
final class HapticsManager {
    static let shared = HapticsManager()
    private init() {}

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light:
            impactLight.impactOccurred()
        default:
            impactMedium.impactOccurred()
        }
    }

    func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(type)
    }
}
