//
//  SOSButton.swift
//  Wayfarer
//

import SwiftUI

/// Hold-to-activate SOS control. The long hold prevents accidental triggers.
struct SOSButton: View {
    var onActivate: () -> Void

    @State private var isPressing = false
    @State private var didActivate = false

    private let holdDuration: Double = 1.5

    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.96))
                .frame(width: 138, height: 138)
                .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white, Color.red.opacity(0.08)],
                        center: .center,
                        startRadius: 12,
                        endRadius: 68
                    )
                )
                .frame(width: 126, height: 126)

            Circle()
                .stroke(Color.red.opacity(0.35), lineWidth: 7)
                .frame(width: 112, height: 112)

            Circle()
                .trim(from: 0, to: isPressing ? 1 : 0)
                .stroke(Color.red, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 112, height: 112)
                .animation(
                    isPressing ? .linear(duration: holdDuration) : .easeOut(duration: 0.2),
                    value: isPressing
                )

            VStack(spacing: 2) {
                Text("SOS")
                    .font(.system(.title, design: .rounded, weight: .black))
                Text("Hold")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.red)
            .shadow(color: .white, radius: 1, x: 0, y: 1)
        }
        .scaleEffect(isPressing ? 1.06 : 1)
        .animation(.easeInOut(duration: 0.2), value: isPressing)
        .onLongPressGesture(minimumDuration: holdDuration) {
            didActivate.toggle()
            onActivate()
        } onPressingChanged: { pressing in
            isPressing = pressing
        }
        .sensoryFeedback(.warning, trigger: didActivate)
        .accessibilityLabel("SOS")
        .accessibilityHint("Hold for one and a half seconds to open emergency options")
    }
}

#Preview {
    SOSButton(onActivate: {})
}
