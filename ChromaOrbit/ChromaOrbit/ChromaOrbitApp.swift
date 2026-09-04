//
//  ChromaOrbitApp.swift
//  Chroma Orbit
//
//  App entry point. The whole game runs inside ContentView, which layers a
//  SpriteKit scene (the actual gameplay) under a SwiftUI menu/HUD/game-over
//  chrome driven by GameState.
//

import SwiftUI

@main
struct ChromaOrbitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .persistentSystemOverlays(.hidden)
        }
    }
}
