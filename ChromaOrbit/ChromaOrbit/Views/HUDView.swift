//
//  HUDView.swift
//  Chroma Orbit
//

import SwiftUI

struct HUDView: View {
    let score: Int
    let combo: Int

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(score)")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: score)
                    if combo > 1 {
                        Text("x\(combo) combo")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(PrismHue.gold.color)
                    }
                }
                Spacer()
            }
            .padding(.top, 56)
            .padding(.horizontal, 24)

            Spacer()
        }
        // The HUD sits above the SpriteKit view but must never intercept
        // taps — those need to reach GameScene.touchesBegan to fire launches.
        .allowsHitTesting(false)
    }
}

#Preview {
    HUDView(score: 1280, combo: 4)
}
