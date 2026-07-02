//
//  MemoriesAlbumView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData
import UIKit

/// The memory album: a photo grid of moments with short stories.
struct MemoriesAlbumView: View {
    @Query(sort: \TravelMemory.date, order: .reverse) private var memories: [TravelMemory]
    @Query(sort: \Trip.startDate) private var trips: [Trip]
    @State private var isAddingMemory = false
    @State private var filterTrip: Trip?

    private var filteredMemories: [TravelMemory] {
        guard let filterTrip else { return memories }
        return memories.filter { $0.trip === filterTrip }
    }

    /// Only trips that actually have memories appear as filters.
    private var tripsWithMemories: [Trip] {
        trips.filter { !$0.memories.isEmpty }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                WayfarerPageHeader(
                    eyebrow: "Travel story",
                    title: "Memories",
                    subtitle: "A living album of places, people, and moments worth returning to.",
                    systemImage: "photo.stack.fill",
                    tint: WayfarerTheme.sunrise,
                    accent: WayfarerTheme.lavender,
                    trailingText: "\(memories.count)"
                )

                if tripsWithMemories.count > 1 {
                    filterBar
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(filteredMemories) { memory in
                        NavigationLink(value: memory) {
                            MemoryCardView(memory: memory)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if memories.isEmpty {
                    ContentUnavailableView(
                        "No memories yet",
                        systemImage: "photo.stack",
                        description: Text("Add a photo and a few lines about the moment — this becomes your travel album.")
                    )
                    .padding(.top, 60)
                }
            }
            .padding()
        }
        .background(WayfarerTheme.pageBackground.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: TravelMemory.self) { memory in
            MemoryDetailView(memory: memory)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isAddingMemory = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add memory")
            }
        }
        .sheet(isPresented: $isAddingMemory) {
            MemoryEditorView()
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "All", isSelected: filterTrip == nil) {
                    filterTrip = nil
                }
                ForEach(tripsWithMemories) { trip in
                    filterChip(label: trip.name, isSelected: filterTrip === trip) {
                        filterTrip = trip
                    }
                }
            }
        }
    }

    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.footnote)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground),
                    in: Capsule()
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

/// One tile in the album grid: the photo with title and date beneath.
struct MemoryCardView: View {
    let memory: TravelMemory

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                if let data = memory.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.accentColor.opacity(0.1)
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(Color.accentColor.opacity(0.5))
                }
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .clipped()

            VStack(alignment: .leading, spacing: 3) {
                Text(memory.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Text(memory.dateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationStack {
        MemoriesAlbumView()
    }
    .modelContainer(AppModelContainer.preview)
}
