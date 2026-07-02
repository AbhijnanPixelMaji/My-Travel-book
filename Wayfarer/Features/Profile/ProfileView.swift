//
//  ProfileView.swift
//  Wayfarer
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("travelerName") private var travelerName = ""
    @AppStorage("travelerEmail") private var travelerEmail = ""
    @AppStorage("homeCountry") private var homeCountry = "India"
    @AppStorage("preferredMapProvider") private var preferredMapProvider = MapProvider.apple.rawValue
    @AppStorage("keepDocumentsOffline") private var keepDocumentsOffline = true
    @AppStorage("shareLocationInSOS") private var shareLocationInSOS = true

    private var initials: String {
        let parts = travelerName.split(separator: " ").prefix(2)
        let joined = parts.compactMap { $0.first.map(String.init) }.joined().uppercased()
        return joined.isEmpty ? "?" : joined
    }

    private var displayName: String {
        travelerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Traveler" : travelerName
    }

    private var selectedProvider: MapProvider {
        MapProvider(rawValue: preferredMapProvider) ?? .apple
    }

    private var profileScore: Double {
        var score = 0.25
        if !travelerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { score += 0.25 }
        if !travelerEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { score += 0.2 }
        if keepDocumentsOffline { score += 0.15 }
        if shareLocationInSOS { score += 0.15 }
        return min(score, 1)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    WayfarerPageHeader(
                        eyebrow: "Personal hub",
                        title: "Profile",
                        subtitle: "Your preferences, privacy controls, and travel identity.",
                        systemImage: "person.crop.circle.fill",
                        tint: WayfarerTheme.lavender,
                        accent: WayfarerTheme.reef,
                        trailingText: "\(Int(profileScore * 100))%"
                    )

                    profileHero
                    profileCompletionCard
                    identityCard
                    preferencesCard
                    privacyCard
                    aboutCard
                    signOutCard
                }
                .padding()
            }
            .background(WayfarerTheme.pageBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var profileHero: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 76, height: 76)
                    InitialsAvatar(initials: initials, size: 66)
                        .background(.white.opacity(0.9), in: Circle())
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Traveler profile")
                        .font(.caption)
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .foregroundStyle(.white.opacity(0.72))
                    Text(displayName)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text(travelerEmail.isEmpty ? "Personalize your travel command center" : travelerEmail)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(2)
                }

                Spacer()
                AnimatedLogoMark(size: 48, cornerRadius: 14)
            }

            HStack(spacing: 10) {
                WayfarerMetricTile(value: homeCountry, label: "Home", systemImage: "house.fill", tint: WayfarerTheme.reef)
                WayfarerMetricTile(value: selectedProvider == .apple ? "Apple" : "Google", label: "Maps", systemImage: selectedProvider.systemImage, tint: WayfarerTheme.sunrise)
            }
        }
        .padding(18)
        .background {
            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    colors: [WayfarerTheme.lavender, WayfarerTheme.ocean, WayfarerTheme.reef],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                AmbientTravelMotion(tint: .white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 26))
        }
        .shadow(color: WayfarerTheme.lavender.opacity(0.22), radius: 18, x: 0, y: 12)
    }

    private var profileCompletionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            JourneyProgressRing(
                progress: profileScore,
                title: "Profile readiness",
                subtitle: profileScore >= 0.9 ? "Your profile is ready for smoother travel days." : "Complete small settings now so trips feel easier later.",
                tint: WayfarerTheme.lavender
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                AchievementBadgeView(
                    title: "Offline Ready",
                    subtitle: keepDocumentsOffline ? "Enabled" : "Turn on storage",
                    systemImage: "wifi.slash",
                    tint: WayfarerTheme.ocean,
                    isUnlocked: keepDocumentsOffline
                )
                AchievementBadgeView(
                    title: "SOS Sharing",
                    subtitle: shareLocationInSOS ? "Location ready" : "Enable for SOS",
                    systemImage: "location.fill.viewfinder",
                    tint: .red,
                    isUnlocked: shareLocationInSOS
                )
            }
        }
        .padding(16)
        .elevatedCard(cornerRadius: 20)
    }

    private var identityCard: some View {
        settingsCard(title: "Identity", icon: "person.text.rectangle.fill", tint: WayfarerTheme.lavender) {
            VStack(spacing: 12) {
                profileField(title: "Name", text: $travelerName, icon: "person.fill", keyboard: .default)
                profileField(title: "Email", text: $travelerEmail, icon: "envelope.fill", keyboard: .emailAddress)
            }
        }
    }

    private var preferencesCard: some View {
        settingsCard(title: "Travel preferences", icon: "slider.horizontal.3", tint: WayfarerTheme.ocean) {
            VStack(spacing: 14) {
                HStack(spacing: 12) {
                    Image(systemName: "globe.asia.australia.fill")
                        .font(.headline)
                        .frame(width: 42, height: 42)
                        .background(WayfarerTheme.reef.opacity(0.14), in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(WayfarerTheme.reef)

                    Picker("Home country", selection: $homeCountry) {
                        ForEach(EmergencyDirectory.all) { entry in
                            Text(entry.country).tag(entry.country)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .profileRowBackground()

                VStack(alignment: .leading, spacing: 8) {
                    Label("Open places in", systemImage: "map.fill")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Picker("Open places in", selection: $preferredMapProvider) {
                        ForEach(MapProvider.allCases) { provider in
                            Label(provider.label, systemImage: provider.systemImage)
                                .tag(provider.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(12)
                .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private var privacyCard: some View {
        settingsCard(title: "Safety and storage", icon: "lock.shield.fill", tint: .red) {
            VStack(spacing: 10) {
                premiumToggle(
                    title: "Keep documents offline",
                    subtitle: "Tickets and scans stay available in airplane mode.",
                    icon: "externaldrive.fill.badge.checkmark",
                    tint: WayfarerTheme.ocean,
                    isOn: $keepDocumentsOffline
                )
                premiumToggle(
                    title: "Share location in SOS",
                    subtitle: "Attach your current location when emergency help matters.",
                    icon: "location.fill.viewfinder",
                    tint: .red,
                    isOn: $shareLocationInSOS
                )
            }
        }
    }

    private var aboutCard: some View {
        settingsCard(title: "Wayfarer", icon: "sparkles", tint: WayfarerTheme.sunrise) {
            VStack(spacing: 10) {
                infoRow(title: "Version", value: "1.0", icon: "number")
                infoRow(title: "Built with", value: "SwiftUI + SwiftData", icon: "swift")
                infoRow(title: "Account", value: travelerEmail.isEmpty ? "Local profile" : "Signed in", icon: "checkmark.seal.fill")
            }
        }
    }

    private var signOutCard: some View {
        Button(role: .destructive) {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                isAuthenticated = false
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.headline)
                    .frame(width: 42, height: 42)
                    .background(.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.red)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sign out")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                    Text("Return to the welcome screen.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(14)
            .elevatedCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    private func settingsCard<Content: View>(
        title: String,
        icon: String,
        tint: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundStyle(WayfarerTheme.ink)
                Spacer()
            }
            content()
        }
        .padding(16)
        .elevatedCard(cornerRadius: 20)
    }

    private func profileField(title: String, text: Binding<String>, icon: String, keyboard: UIKeyboardType) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .frame(width: 42, height: 42)
                .background(WayfarerTheme.lavender.opacity(0.14), in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(WayfarerTheme.lavender)

            TextField(title, text: text)
                .font(.subheadline)
                .fontWeight(.semibold)
                .keyboardType(keyboard)
                .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
                .autocorrectionDisabled(keyboard == .emailAddress)
        }
        .profileRowBackground()
    }

    private func premiumToggle(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .frame(width: 42, height: 42)
                .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(tint)

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

            Toggle(title, isOn: isOn)
                .labelsHidden()
                .tint(tint)
        }
        .profileRowBackground()
    }

    private func infoRow(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .frame(width: 42, height: 42)
                .background(WayfarerTheme.sunrise.opacity(0.14), in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(WayfarerTheme.sunrise)
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .profileRowBackground()
    }
}

private extension View {
    func profileRowBackground() -> some View {
        self
            .padding(12)
            .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    ProfileView()
}
