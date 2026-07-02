//
//  ViewStyles.swift
//  Wayfarer
//

import SwiftUI

enum WayfarerTheme {
    static let ocean = Color(red: 0.02, green: 0.35, blue: 0.42)
    static let reef = Color(red: 0.00, green: 0.55, blue: 0.58)
    static let sunrise = Color(red: 0.96, green: 0.43, blue: 0.24)
    static let sand = Color(red: 0.98, green: 0.93, blue: 0.83)
    static let ink = Color(red: 0.08, green: 0.12, blue: 0.16)
    static let lavender = Color(red: 0.45, green: 0.39, blue: 0.78)

    static var pageBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.93, green: 0.98, blue: 0.98),
                Color(.systemGroupedBackground),
                Color(red: 0.99, green: 0.95, blue: 0.90)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [ocean, reef],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func color(for status: TripStatus) -> Color {
        switch status {
        case .dreaming: lavender
        case .planned: ocean
        case .active: .green
        case .completed: sunrise
        }
    }
}

extension View {
    /// Standard rounded card used across list-style screens.
    func cardStyle() -> some View {
        self
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 14)
            )
    }

    /// Slightly richer card treatment for dashboard-style surfaces.
    func elevatedCard(cornerRadius: CGFloat = 18) -> some View {
        self
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.07), radius: 14, x: 0, y: 7)
    }
}

/// Small tinted capsule used for statuses and categories.
struct TagChip: View {
    let text: String
    var systemImage: String?
    var tint: Color = .accentColor

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption2)
            }
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tint.opacity(0.15), in: Capsule())
        .foregroundStyle(tint)
    }
}

struct WayfarerMetricTile: View {
    let value: String
    let label: String
    let systemImage: String
    var tint: Color = WayfarerTheme.ocean

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.14), in: Circle())
                .foregroundStyle(tint)

            Text(value)
                .font(.headline)
                .foregroundStyle(WayfarerTheme.ink)
                .lineLimit(1)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 14))
    }
}

/// Premium page heading for the main app surfaces.
struct WayfarerPageHeader: View {
    let eyebrow: String
    let title: String
    var subtitle: String?
    let systemImage: String
    var tint: Color = WayfarerTheme.ocean
    var accent: Color = WayfarerTheme.reef
    var trailingText: String?

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.95), accent.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.white.opacity(0.5), lineWidth: 1)
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .symbolEffect(.bounce, value: title)
            }
            .frame(width: 58, height: 58)
            .shadow(color: tint.opacity(0.24), radius: 14, x: 0, y: 8)

            VStack(alignment: .leading, spacing: 3) {
                Text(eyebrow)
                    .font(.caption2)
                    .fontWeight(.black)
                    .textCase(.uppercase)
                    .foregroundStyle(tint)
                    .tracking(0.7)

                Text(title)
                    .font(.system(.largeTitle, design: .rounded, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [WayfarerTheme.ink, tint, accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 8)

            if let trailingText {
                Text(trailingText)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(.white.opacity(0.82), in: Capsule())
                    .foregroundStyle(tint)
                    .overlay(
                        Capsule()
                            .stroke(tint.opacity(0.16), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 2)
        .accessibilityElement(children: .combine)
    }
}

/// Circle with a person's initials, used wherever companions appear.
struct InitialsAvatar: View {
    let initials: String
    var size: CGFloat = 40

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.38, weight: .medium))
            .frame(width: size, height: size)
            .background(Color.accentColor.opacity(0.15), in: Circle())
            .foregroundStyle(Color.accentColor)
    }
}
