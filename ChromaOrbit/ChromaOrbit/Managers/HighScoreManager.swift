//
//  HighScoreManager.swift
//  Chroma Orbit
//

import Foundation

/// Thin UserDefaults wrapper for the single persisted value this game needs.
final class HighScoreManager {
    static let shared = HighScoreManager()

    private let key = "com.chromaorbit.bestScore"
    private init() {}

    var bestScore: Int {
        get { UserDefaults.standard.integer(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
