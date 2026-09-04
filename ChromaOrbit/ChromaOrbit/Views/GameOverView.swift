//
//  GameOverView.swift
//  Chroma Orbit
//

import SwiftUI

struct GameOverView: View {
    let score: Int
    let bestScore: Int
    let onRetry: () -> Void
    let onMenu: () -> Void

    private var isNewBest: Bool { score > 0 && score >= bestScore }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text(isNewBest ? "NEW BEST" : "RUN OVER")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(isNewBest ? PrismHue.gold.color : .white)

            Text("\(score)")
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("Best \(bestScore)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Palette.textSecondary)

            Spacer()

            VStack(spacing: 14) {
                Button(action: onRetry) {
                    Text("RETRY")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(width: 200, height: 56)
                        .background(Capsule().fill(Color.white))
                }
                Button(action: onMenu) {
                    Text("Menu")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Palette.textSecondary)
                }
            }
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.background.opacity(0.72).ignoresSafeArea())
        .transition(.opacity)
    }
}

#Preview {
    GameOverView(score: 340, bestScore: 480, onRetry: {}, onMenu: {})
}
