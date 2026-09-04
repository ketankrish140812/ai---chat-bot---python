//
//  ContentView.swift
//  Chroma Orbit
//
//  The whole screen: a SpriteKit scene for gameplay, with a SwiftUI overlay
//  (menu / HUD / game-over) swapped in based on GameState.phase.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @State private var scene: GameScene?

    var body: some View {
        ZStack {
            Palette.backgroundDeep.ignoresSafeArea()

            if let scene {
                SpriteView(scene: scene, options: [.ignoresSiblingOrder])
                    .ignoresSafeArea()
            }

            switch gameState.phase {
            case .menu:
                MenuView(bestScore: gameState.bestScore) {
                    scene?.startRun()
                }
            case .playing:
                HUDView(score: gameState.score, combo: gameState.combo)
            case .gameOver:
                GameOverView(score: gameState.score, bestScore: gameState.bestScore) {
                    scene?.startRun()
                } onMenu: {
                    scene?.returnToMenu()
                }
            }
        }
        .statusBarHidden(true)
        .onAppear {
            if scene == nil {
                scene = GameScene(gameState: gameState)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: gameState.phase)
    }
}

#Preview {
    ContentView()
}
