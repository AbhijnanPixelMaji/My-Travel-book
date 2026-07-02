//
//  RootTabView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData
import UIKit

private enum WayfarerTab: String, CaseIterable, Identifiable {
    case trips = "Trips"
    case explore = "Explore"
    case wallet = "Wallet"
    case safety = "Safety"
    case profile = "Profile"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .trips: "airplane.departure"
        case .explore: "map.circle.fill"
        case .wallet: "ticket.fill"
        case .safety: "shield.checkered"
        case .profile: "person.crop.circle.fill.badge.checkmark"
        }
    }

    var tint: Color {
        switch self {
        case .trips: WayfarerTheme.ocean
        case .explore: WayfarerTheme.reef
        case .wallet: WayfarerTheme.sunrise
        case .safety: .red
        case .profile: WayfarerTheme.lavender
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .trips: [Color(red: 0.00, green: 0.62, blue: 0.74), Color(red: 0.11, green: 0.36, blue: 0.92)]
        case .explore: [Color(red: 0.00, green: 0.72, blue: 0.50), Color(red: 0.22, green: 0.76, blue: 0.96)]
        case .wallet: [Color(red: 1.00, green: 0.65, blue: 0.12), Color(red: 0.96, green: 0.28, blue: 0.22)]
        case .safety: [Color(red: 1.00, green: 0.18, blue: 0.22), Color(red: 0.68, green: 0.05, blue: 0.22)]
        case .profile: [Color(red: 0.55, green: 0.36, blue: 0.98), Color(red: 0.95, green: 0.35, blue: 0.72)]
        }
    }
}

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: WayfarerTab = .trips

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TripsListView()
                .tag(WayfarerTab.trips)

            ExploreMapView()
                .tag(WayfarerTab.explore)

            WalletView()
                .tag(WayfarerTab.wallet)

            SafetyView()
                .tag(WayfarerTab.safety)

            ProfileView()
                .tag(WayfarerTab.profile)
        }
        .safeAreaInset(edge: .bottom) {
            ColorfulTabBar(selectedTab: $selectedTab)
        }
        .task {
            SampleData.seedIfNeeded(context: modelContext)
        }
    }
}

private struct ColorfulTabBar: View {
    @Binding var selectedTab: WayfarerTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(WayfarerTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                        selectedTab = tab
                    }
                } label: {
                    tabItem(tab)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.rawValue)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(
            Color(.systemGray5).opacity(0.68),
            in: RoundedRectangle(cornerRadius: 26)
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26))
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(.white.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.13), radius: 22, x: 0, y: 10)
        .padding(.horizontal, 14)
        .padding(.top, 4)
        .padding(.bottom, 6)
    }

    private func tabItem(_ tab: WayfarerTab) -> some View {
        let isSelected = selectedTab == tab

        return VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isSelected ? tab.gradientColors : tab.gradientColors.map { $0.opacity(0.82) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isSelected ? 45 : 39, height: isSelected ? 45 : 39)
                    .shadow(color: tab.tint.opacity(isSelected ? 0.34 : 0.16), radius: isSelected ? 10 : 5, x: 0, y: 5)

                Image(systemName: tab.systemImage)
                    .font(.system(size: isSelected ? 18 : 15, weight: .bold))
                    .foregroundStyle(.white)
                    .symbolEffect(.bounce, value: isSelected)
            }
            .frame(height: 45)

            Text(tab.rawValue)
                .font(.system(size: 10, weight: isSelected ? .bold : .semibold))
                .foregroundStyle(isSelected ? tab.tint : tab.tint.opacity(0.82))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
    }
}

#Preview {
    RootTabView()
        .modelContainer(AppModelContainer.preview)
}
