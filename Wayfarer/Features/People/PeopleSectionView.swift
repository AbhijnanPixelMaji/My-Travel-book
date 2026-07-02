//
//  PeopleSectionView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData

/// Travel companions list inside the trip detail screen.
struct PeopleSectionView: View {
    @Bindable var trip: Trip
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @State private var isAddingCompanion = false
    @State private var editingCompanion: Companion?

    private var sortedCompanions: [Companion] {
        trip.companions.sorted { $0.name < $1.name }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(sortedCompanions) { companion in
                Button {
                    editingCompanion = companion
                } label: {
                    companionRow(companion)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button(role: .destructive) {
                        modelContext.delete(companion)
                    } label: {
                        Label("Remove person", systemImage: "trash")
                    }
                }
            }

            if trip.companions.isEmpty {
                ContentUnavailableView(
                    "No one added yet",
                    systemImage: "person.2",
                    description: Text("Add the people traveling with you and who's booking what.")
                )
            }

            Button {
                isAddingCompanion = true
            } label: {
                Label("Add person", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .sheet(isPresented: $isAddingCompanion) {
            CompanionEditorView(trip: trip)
        }
        .sheet(item: $editingCompanion) { companion in
            CompanionEditorView(trip: trip, companion: companion)
        }
    }

    private func companionRow(_ companion: Companion) -> some View {
        HStack(spacing: 12) {
            InitialsAvatar(initials: companion.initials)
            VStack(alignment: .leading, spacing: 2) {
                Text(companion.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if !companion.role.isEmpty {
                    Text(companion.role)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if !companion.phone.isEmpty {
                Button {
                    call(companion.phone)
                } label: {
                    Image(systemName: "phone.fill")
                        .frame(width: 34, height: 34)
                        .background(Color.green.opacity(0.12), in: Circle())
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Call \(companion.name)")
            }
        }
        .cardStyle()
    }

    private func call(_ number: String) {
        let digits = number.filter { !$0.isWhitespace }
        if let url = URL(string: "tel://\(digits)") {
            openURL(url)
        }
    }
}
