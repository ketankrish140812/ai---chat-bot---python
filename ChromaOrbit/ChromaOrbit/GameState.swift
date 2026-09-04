//
//  GameState.swift
//  Chroma Orbit
//

import Foundation

enum GamePhase: Equatable {
    case menu
    case playing
    case gameOver
}

/// Shared, observable state bridging the SpriteKit scene (GameScene) and the
/// SwiftUI overlay chrome (MenuView, HUDView, GameOverView).
///
/// This is mutated only from the main thread: SwiftUI's view updates and
/// SpriteKit's render loop (`update(_:)`, `touchesBegan(_:with:)`) both
/// already run there, so no extra synchronization is needed.
final class GameState: ObservableObject {
    @Published var phase: GamePhase = .menu
    @Published var score: Int = 0
    @Published var combo: Int = 1
    @Published private(set) var bestScore: Int = HighScoreManager.shared.bestScore

    /// Called at the start of every run.
    func reset() {
        score = 0
        combo = 1
    }

    /// Called once when a run ends; persists a new best score if one was set.
    func recordRunEnded() {
        if score > bestScore {
            bestScore = score
            HighScoreManager.shared.bestScore = score
        }
    }
}
