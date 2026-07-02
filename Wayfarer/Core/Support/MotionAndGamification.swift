//
//  MotionAndGamification.swift
//  Wayfarer
//

import SwiftUI

struct AnimatedLogoMark: View {
    var size: CGFloat = 52
    var cornerRadius: CGFloat = 15

    @State private var isFloating = false

    var body: some View {
        Image("WayfarerLogo")
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .background(Color.blue.opacity(0.5), in: RoundedRectangle(cornerRadius: cornerRadius))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.white.opacity(0.48), lineWidth: 1)
            )
            .shadow(color: WayfarerTheme.reef.opacity(0.38), radius: isFloating ? 16 : 8, x: 0, y: isFloating ? 8 : 4)
            .offset(y: isFloating ? -3 : 2)
            .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: isFloating)
            .onAppear { isFloating = true }
            .accessibilityLabel("Wayfarer logo")
    }
}

struct AmbientTravelMotion: View {
    var tint: Color = .white
    @State private var drift = false

    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(tint.opacity(index.isMultiple(of: 2) ? 0.16 : 0.08))
                    .frame(width: CGFloat(34 + index * 12), height: CGFloat(34 + index * 12))
                    .offset(
                        x: drift ? CGFloat(index * 18 - 52) : CGFloat(68 - index * 10),
                        y: drift ? CGFloat(42 - index * 12) : CGFloat(index * 14 - 28)
                    )
                    .blur(radius: 1.5)
            }

            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(tint.opacity(0.56))
                .symbolEffect(.pulse, options: .repeating)
                .offset(x: drift ? 72 : 50, y: drift ? -42 : -24)
        }
        .animation(.easeInOut(duration: 4.8).repeatForever(autoreverses: true), value: drift)
        .onAppear { drift = true }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct GamifiedLaunchOverlay: View {
    let onComplete: () -> Void

    @State private var progress = 0.0
    @State private var showBadges = false
    @State private var liftLogo = false

    var body: some View {
        ZStack {
            WayfarerTheme.pageBackground.ignoresSafeArea()

            AmbientTravelMotion(tint: WayfarerTheme.reef)
                .opacity(0.34)

            VStack(spacing: 24) {
                AnimatedLogoMark(size: 104, cornerRadius: 28)
                    .scaleEffect(liftLogo ? 1.0 : 0.82)
                    .offset(y: liftLogo ? -4 : 12)

                VStack(spacing: 8) {
                    Text("Wayfarer")
                        .font(.system(.largeTitle, design: .rounded, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [WayfarerTheme.ink, WayfarerTheme.ocean, WayfarerTheme.reef],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Preparing your travel command center")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 12) {
                    LaunchProgressRow(
                        title: "Trips synced",
                        systemImage: "airplane.departure",
                        tint: WayfarerTheme.ocean,
                        isUnlocked: progress > 0.25
                    )
                    LaunchProgressRow(
                        title: "Safety armed",
                        systemImage: "shield.lefthalf.filled",
                        tint: .red,
                        isUnlocked: progress > 0.55
                    )
                    LaunchProgressRow(
                        title: "Memories unlocked",
                        systemImage: "photo.stack.fill",
                        tint: WayfarerTheme.sunrise,
                        isUnlocked: progress > 0.82
                    )
                }
                .frame(maxWidth: 300)
                .opacity(showBadges ? 1 : 0)
                .offset(y: showBadges ? 0 : 14)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.75))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [WayfarerTheme.reef, WayfarerTheme.sunrise, WayfarerTheme.lavender],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(18, 240 * progress))
                }
                .frame(width: 240, height: 10)
                .shadow(color: WayfarerTheme.reef.opacity(0.25), radius: 12, x: 0, y: 6)
            }
            .padding(28)
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
                liftLogo = true
                showBadges = true
            }
            withAnimation(.easeInOut(duration: 1.35)) {
                progress = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.65) {
                onComplete()
            }
        }
        .accessibilityLabel("Wayfarer is preparing your trips, safety tools, and memories.")
    }
}

private struct LaunchProgressRow: View {
    let title: String
    let systemImage: String
    let tint: Color
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isUnlocked ? "checkmark.circle.fill" : systemImage)
                .font(.headline)
                .frame(width: 34, height: 34)
                .background(tint.opacity(isUnlocked ? 0.18 : 0.1), in: Circle())
                .foregroundStyle(isUnlocked ? tint : .secondary)
                .symbolEffect(.bounce, value: isUnlocked)

            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(WayfarerTheme.ink)

            Spacer()
        }
        .padding(10)
        .background(.white.opacity(isUnlocked ? 0.9 : 0.62), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(tint.opacity(isUnlocked ? 0.22 : 0.08), lineWidth: 1)
        )
    }
}

struct JourneyProgressRing: View {
    let progress: Double
    let title: String
    let subtitle: String
    var tint: Color = WayfarerTheme.reef

    @State private var animatedProgress = 0.0

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(tint.opacity(0.16), lineWidth: 9)
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        AngularGradient(colors: [tint, WayfarerTheme.sunrise, tint], center: .center),
                        style: StrokeStyle(lineWidth: 9, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                Text("\(Int((progress * 100).rounded()))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(WayfarerTheme.ink)
            }
            .frame(width: 58, height: 58)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(WayfarerTheme.ink)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = min(max(progress, 0), 1)
            }
        }
    }
}

struct AchievementBadgeView: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var tint: Color = WayfarerTheme.ocean
    var isUnlocked = true

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.headline)
                .frame(width: 40, height: 40)
                .background((isUnlocked ? tint : Color.secondary).opacity(0.14), in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(isUnlocked ? tint : .secondary)
                .symbolEffect(.bounce, value: isUnlocked)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(isUnlocked ? .primary : .secondary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(10)
        .background(Color(.tertiarySystemGroupedBackground).opacity(isUnlocked ? 0.92 : 0.55), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct MicroPromptCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var tint: Color = WayfarerTheme.sunrise

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline)
                .frame(width: 42, height: 42)
                .background(tint.opacity(0.14), in: Circle())
                .foregroundStyle(tint)
                .symbolEffect(.pulse, options: .repeating)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(12)
        .background(.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct AnimatedSearchBar: View {
    @Binding var text: String
    let placeholder: String

    @State private var isAnimating = false
    @FocusState private var isFocused: Bool

    private var isActive: Bool {
        isFocused || !text.isEmpty
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.headline)
                .foregroundStyle(isActive ? WayfarerTheme.ocean : .secondary)

            TextField(placeholder, text: $text)
                .font(.subheadline)
                .fontWeight(.semibold)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isFocused)
                .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    AngularGradient(
                        colors: [
                            WayfarerTheme.reef,
                            WayfarerTheme.sunrise,
                            WayfarerTheme.lavender,
                            WayfarerTheme.ocean,
                            WayfarerTheme.reef
                        ],
                        center: .center,
                        angle: .degrees(isAnimating ? 360 : 0)
                    ),
                    lineWidth: isActive ? 2.4 : 1.6
                )
                .opacity(isActive ? 1 : 0.72)
        }
        .shadow(color: WayfarerTheme.ocean.opacity(isActive ? 0.16 : 0.08), radius: isActive ? 16 : 8, x: 0, y: 8)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .onAppear {
            withAnimation(.linear(duration: 3.4).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}
