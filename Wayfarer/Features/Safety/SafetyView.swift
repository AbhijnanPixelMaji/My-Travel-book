//
//  SafetyView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData

/// Emergency hub: SOS, country emergency numbers, and trusted local contacts.
struct SafetyView: View {
    @AppStorage("currentCountry") private var currentCountry = "India"
    @AppStorage("preferredMapProvider") private var preferredMapProvider = MapProvider.apple.rawValue
    @Query(sort: \EmergencyContact.name) private var contacts: [EmergencyContact]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @State private var showSOSOptions = false
    @State private var isAddingContact = false
    @State private var editingContact: EmergencyContact?

    private var numbers: EmergencyNumbers {
        EmergencyDirectory.numbers(for: currentCountry)
    }

    private var selectedProvider: MapProvider {
        MapProvider(rawValue: preferredMapProvider) ?? .apple
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    WayfarerPageHeader(
                        eyebrow: "Protected travel",
                        title: "Safety",
                        subtitle: "SOS, trusted contacts, and local emergency numbers within reach.",
                        systemImage: "shield.lefthalf.filled",
                        tint: .red,
                        accent: WayfarerTheme.sunrise,
                        trailingText: currentCountry
                    )

                    safetyHero
                    safetyReadinessPanel
                    emergencyNumbersPanel
                    contactsPanel
                    nearbyHelpPanel
                    devicePanel
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 1.00, green: 0.95, blue: 0.94),
                        Color(.systemGroupedBackground),
                        Color(red: 0.92, green: 0.98, blue: 0.97)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingContact = true
                    } label: {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.title3)
                    }
                    .accessibilityLabel("Add contact")
                }
            }
            .confirmationDialog(
                "Emergency - \(currentCountry)",
                isPresented: $showSOSOptions,
                titleVisibility: .visible
            ) {
                Button("Call police (\(numbers.police))", role: .destructive) { call(numbers.police) }
                Button("Call ambulance (\(numbers.ambulance))", role: .destructive) { call(numbers.ambulance) }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $isAddingContact) {
                EmergencyContactEditorView()
            }
            .sheet(item: $editingContact) { contact in
                EmergencyContactEditorView(contact: contact)
            }
        }
    }

    private var safetyHero: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Safety mode")
                        .font(.caption)
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .foregroundStyle(.white.opacity(0.72))
                    Text("Fast help, trusted people, and local emergency numbers.")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(3)
                }
                Spacer()
                Image(systemName: "shield.lefthalf.filled")
                    .font(.title2)
                    .frame(width: 52, height: 52)
                    .background(Color.blue.opacity(0.5), in: RoundedRectangle(cornerRadius: 15))
                    .foregroundStyle(.white)
                    .symbolEffect(.pulse, options: .repeating)
            }

            SOSButton {
                showSOSOptions = true
            }
            .padding(.top, 2)

            Text("Hold SOS to open emergency calling options for \(currentCountry).")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.78))
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background {
            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    colors: [.red, WayfarerTheme.sunrise, WayfarerTheme.ink],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                AmbientTravelMotion(tint: .white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 26))
        }
        .shadow(color: .red.opacity(0.2), radius: 18, x: 0, y: 12)
    }

    private var safetyReadinessPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            JourneyProgressRing(
                progress: safetyProgress,
                title: "Safety readiness",
                subtitle: safetyProgress >= 0.75 ? "Emergency basics are in place." : "Add one trusted contact to feel more prepared.",
                tint: .red
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                AchievementBadgeView(
                    title: "Local Ready",
                    subtitle: currentCountry,
                    systemImage: "globe.asia.australia.fill",
                    tint: WayfarerTheme.reef,
                    isUnlocked: true
                )
                AchievementBadgeView(
                    title: "Safety Circle",
                    subtitle: contacts.isEmpty ? "Add a contact" : "\(contacts.count) trusted",
                    systemImage: "person.2.badge.shield.checkmark.fill",
                    tint: .red,
                    isUnlocked: !contacts.isEmpty
                )
            }
        }
        .padding(16)
        .elevatedCard(cornerRadius: 20)
    }

    private var safetyProgress: Double {
        var score = 0.35
        if !contacts.isEmpty { score += 0.35 }
        if !currentCountry.isEmpty { score += 0.2 }
        if selectedProvider == .google || selectedProvider == .apple { score += 0.1 }
        return min(score, 1)
    }

    private var emergencyNumbersPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Emergency numbers", systemImage: "phone.connection.fill")
                    .font(.headline)
                    .foregroundStyle(WayfarerTheme.ink)
                Spacer()
            }

            Picker("Country", selection: $currentCountry) {
                ForEach(EmergencyDirectory.all) { entry in
                    Text(entry.country).tag(entry.country)
                }
            }
            .pickerStyle(.menu)
            .padding(12)
            .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))

            HStack(spacing: 10) {
                callCard(label: "Police", number: numbers.police, icon: "shield.lefthalf.filled", tint: .blue)
                callCard(label: "Ambulance", number: numbers.ambulance, icon: "cross.case.fill", tint: .red)
                callCard(label: "Fire", number: numbers.fire, icon: "flame.fill", tint: .orange)
            }
        }
        .padding(16)
        .elevatedCard(cornerRadius: 20)
    }

    private var contactsPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Trusted contacts", systemImage: "person.2.fill")
                    .font(.headline)
                    .foregroundStyle(WayfarerTheme.ink)
                Spacer()
                Button {
                    isAddingContact = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .accessibilityLabel("Add contact")
            }

            if contacts.isEmpty {
                Text("Add hotel desks, guides, family, or local friends before you travel.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
            } else {
                VStack(spacing: 10) {
                    ForEach(contacts) { contact in
                        contactRow(contact)
                    }
                }
            }
        }
        .padding(16)
        .elevatedCard(cornerRadius: 20)
    }

    private var nearbyHelpPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Nearby help", systemImage: "location.magnifyingglass")
                    .font(.headline)
                    .foregroundStyle(WayfarerTheme.ink)
                Spacer()
                Text(selectedProvider.label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(WayfarerTheme.ocean)
            }

            VStack(spacing: 10) {
                mapSearchRow(label: "Find my embassy", query: "embassy", icon: "building.columns.fill", tint: WayfarerTheme.lavender)
                mapSearchRow(label: "Nearest hospital", query: "hospital", icon: "cross.fill", tint: .red)
                mapSearchRow(label: "Nearest police station", query: "police station", icon: "shield.fill", tint: .blue)
            }
        }
        .padding(16)
        .elevatedCard(cornerRadius: 20)
    }

    private var devicePanel: some View {
        HStack(spacing: 12) {
            Image(systemName: "applewatch")
                .font(.title3)
                .frame(width: 44, height: 44)
                .background(WayfarerTheme.ink.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(WayfarerTheme.ink)
            VStack(alignment: .leading, spacing: 2) {
                Text("Apple Watch SOS")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("Set up emergency features in the Watch app.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .elevatedCard(cornerRadius: 20)
    }

    private func callCard(label: String, number: String, icon: String, tint: Color) -> some View {
        Button {
            call(number)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.headline)
                    .frame(width: 34, height: 34)
                    .background(tint.opacity(0.14), in: Circle())
                    .foregroundStyle(tint)
                Text(label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(number)
                    .font(.headline)
                    .foregroundStyle(tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private func callRow(label: String, number: String, icon: String) -> some View {
        Button {
            call(number)
        } label: {
            HStack {
                Label(label, systemImage: icon)
                    .foregroundStyle(.primary)
                Spacer()
                Text(number)
                    .fontWeight(.medium)
                    .foregroundStyle(.red)
            }
        }
    }

    private func contactRow(_ contact: EmergencyContact) -> some View {
        Button {
            editingContact = contact
        } label: {
            HStack(spacing: 12) {
                InitialsAvatar(initials: initials(for: contact.name), size: 42)
                VStack(alignment: .leading, spacing: 2) {
                    Text(contact.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    if !contact.relation.isEmpty {
                        Text(contact.relation)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        }
                    }
                Spacer()
                if !contact.phone.isEmpty {
                    Button {
                        call(contact.phone)
                    } label: {
                        Image(systemName: "phone.fill")
                            .foregroundStyle(.green)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Call \(contact.name)")
                }
            }
            .padding(10)
            .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                modelContext.delete(contact)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func mapSearchRow(label: String, query: String, icon: String, tint: Color) -> some View {
        Button {
            if let url = MapLauncher.searchURL(query: query, provider: selectedProvider) {
                openURL(url)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.headline)
                    .frame(width: 40, height: 40)
                    .background(tint.opacity(0.13), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(tint)
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func call(_ number: String) {
        let digits = number.filter { !$0.isWhitespace }
        if let url = URL(string: "tel://\(digits)") {
            openURL(url)
        }
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ").prefix(2)
        let joined = parts.compactMap { $0.first.map(String.init) }.joined().uppercased()
        return joined.isEmpty ? "?" : joined
    }
}

#Preview {
    SafetyView()
        .modelContainer(AppModelContainer.preview)
}
