//
//  MenuView.swift
//  Chroma Orbit
//

import SwiftUI

struct MenuView: View {
    let bestScore: Int
    let onPlay: () -> Void

    @State private var pulse = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 6) {
                Text("CHROMA")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("ORBIT")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [PrismHue.cyan.color, PrismHue.magenta.color, PrismHue.gold.color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .shadow(color: .black.opacity(0.4), radius: 12, y: 4)

            Text("Tap to launch off each prism.\nChain matching colors. Dodge the spiked ones.")
                .multilineTextAlignment(.center)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Palette.textSecondary)
                .padding(.horizontal, 32)

            if bestScore > 0 {
                Label("Best \(bestScore)", systemImage: "star.fill")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(PrismHue.gold.color)
            }

            Spacer()

            Button(action: onPlay) {
                Text("PLAY")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .frame(width: 200, height: 58)
                    .background(Capsule().fill(Color.white))
                    .scaleEffect(pulse ? 1.04 : 1.0)
            }
            .padding(.bottom, 60)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.background.opacity(0.55).ignoresSafeArea())
    }
}

#Preview {
    MenuView(bestScore: 240, onPlay: {})
}
