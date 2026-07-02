//
//  TripsListView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData
import UIKit

struct TripsListView: View {
    @Query(sort: \Trip.startDate) private var trips: [Trip]
    @Query(sort: \TravelMemory.date, order: .reverse) private var memories: [TravelMemory]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var isAddingTrip = false

    private var filteredTrips: [Trip] {
        guard !searchText.isEmpty else { return trips }
        return trips.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.destination.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var upcomingTrips: [Trip] { filteredTrips.filter { $0.status != .completed } }
    private var completedTrips: [Trip] { filteredTrips.filter { $0.status == .completed } }
    private var activeTrips: [Trip] { trips.filter { $0.status == .active } }
    private var plannedTrips: [Trip] { trips.filter { $0.status == .planned } }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    WayfarerPageHeader(
                        eyebrow: "Travel command",
                        title: "Wayfarer",
                        subtitle: "Trips, tickets, memories, and backup plans in one calm place.",
                        systemImage: "airplane.departure",
                        tint: WayfarerTheme.ocean,
                        accent: WayfarerTheme.sunrise,
                        trailingText: "\(trips.count) trips"
                    )

                    dashboardHeader

                    AnimatedSearchBar(text: $searchText, placeholder: "Search trips, cities, plans")

                    JourneyMotivationPanel(
                        trips: trips,
                        memories: memories,
                        plannedTrips: plannedTrips,
                        completedTrips: completedTrips
                    )

                    if !completedTrips.isEmpty {
                        TravelHistoryTrailView(trips: completedTrips)
                    }

                    memoriesAlbumCard

                    ForEach(upcomingTrips) { trip in
                        tripLink(trip)
                    }
                    if !completedTrips.isEmpty {
                        Text("Past journeys")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.top, 8)
                        ForEach(completedTrips) { trip in
                            tripLink(trip)
                        }
                    }
                    if filteredTrips.isEmpty {
                        ContentUnavailableView(
                            searchText.isEmpty ? "Start your first trip" : "No matches",
                            systemImage: "airplane.departure",
                            description: Text(
                                searchText.isEmpty
                                    ? "Save the itinerary, tickets, people, and backup plans in one place."
                                    : "No trip matches \"\(searchText)\"."
                            )
                        )
                        .padding(.top, 60)
                    }
                }
                .padding()
            }
            .background(WayfarerTheme.pageBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Trip.self) { trip in
                TripDetailView(trip: trip)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingTrip = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.caption)
                                .fontWeight(.black)
                            Text("Trip")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(WayfarerTheme.primaryGradient, in: Capsule())
                        .foregroundStyle(.white)
                        .shadow(color: WayfarerTheme.ocean.opacity(0.25), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("New trip")
                }
            }
            .sheet(isPresented: $isAddingTrip) {
                TripEditorView()
            }
        }
    }

    private var dashboardHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Travel desk")
                        .font(.caption)
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .foregroundStyle(.white.opacity(0.72))
                    Text(nextTripTitle)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text(nextTripSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(2)
                }

                Spacer()

                AnimatedLogoMark(size: 48, cornerRadius: 13)
            }

            HStack(spacing: 10) {
                WayfarerMetricTile(value: "\(plannedTrips.count)", label: "Planned", systemImage: "calendar.badge.clock", tint: WayfarerTheme.ocean)
                WayfarerMetricTile(value: "\(activeTrips.count)", label: "Active", systemImage: "location.fill", tint: .green)
                WayfarerMetricTile(value: "\(completedTrips.count)", label: "Visited", systemImage: "checkmark.seal.fill", tint: WayfarerTheme.sunrise)
            }
        }
        .padding(18)
        .background {
            ZStack(alignment: .topTrailing) {
                WayfarerTheme.primaryGradient
                AmbientTravelMotion(tint: .white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .shadow(color: WayfarerTheme.ocean.opacity(0.22), radius: 18, x: 0, y: 12)
    }

    private var nextTripTitle: String {
        upcomingTrips.first.map { $0.name } ?? "Plan the next story"
    }

    private var nextTripSubtitle: String {
        if let trip = upcomingTrips.first {
            return "\(trip.destination) • \(trip.dateRangeText)"
        }
        return "Tickets, plans, people, memories, and SOS details in one calm place."
    }

    /// Entry to the memory album, with the latest photos peeking out.
    private var memoriesAlbumCard: some View {
        NavigationLink {
            MemoriesAlbumView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "photo.stack.fill")
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(WayfarerTheme.lavender.opacity(0.13), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(WayfarerTheme.lavender)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Memories")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(memories.isEmpty
                        ? "Your travel album starts here"
                        : "\(memories.count) moment\(memories.count == 1 ? "" : "s") saved")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: -10) {
                    ForEach(memories.prefix(3)) { memory in
                        memoryThumbnail(memory)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
            .cardStyle()
        }
        .buttonStyle(.plain)
    }

    private func memoryThumbnail(_ memory: TravelMemory) -> some View {
        ZStack {
            if let data = memory.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.accentColor.opacity(0.15)
                Image(systemName: "photo")
                    .font(.caption)
                    .foregroundStyle(Color.accentColor.opacity(0.6))
            }
        }
        .frame(width: 34, height: 34)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color(.secondarySystemGroupedBackground), lineWidth: 2))
    }

    private func tripLink(_ trip: Trip) -> some View {
        NavigationLink(value: trip) {
            TripCardView(trip: trip)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                modelContext.delete(trip)
            } label: {
                Label("Delete trip", systemImage: "trash")
            }
        }
    }
}

private struct JourneyMotivationPanel: View {
    let trips: [Trip]
    let memories: [TravelMemory]
    let plannedTrips: [Trip]
    let completedTrips: [Trip]

    private var readinessProgress: Double {
        guard let trip = plannedTrips.first ?? trips.first else { return 0.12 }
        let possible = 4.0
        var score = 0.0
        if !trip.itineraryItems.isEmpty { score += 1 }
        if !trip.documents.isEmpty { score += 1 }
        if !trip.companions.isEmpty { score += 1 }
        if trip.activePlan != nil { score += 1 }
        return max(score / possible, 0.12)
    }

    private var explorerLevel: Int {
        max(1, completedTrips.count + memories.count / 3 + trips.count / 2)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Explorer level \(explorerLevel)", systemImage: "trophy.fill")
                    .font(.headline)
                    .foregroundStyle(WayfarerTheme.ink)
                Spacer()
                TagChip(text: "Momentum", systemImage: "bolt.fill", tint: WayfarerTheme.sunrise)
            }

            JourneyProgressRing(
                progress: readinessProgress,
                title: "Trip readiness",
                subtitle: readinessProgress >= 0.75 ? "You are nearly launch-ready." : "Add one small item to make the next trip feel calmer.",
                tint: WayfarerTheme.reef
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                AchievementBadgeView(
                    title: "Memory Keeper",
                    subtitle: memories.isEmpty ? "Save your first moment" : "\(memories.count) moments saved",
                    systemImage: "photo.stack.fill",
                    tint: WayfarerTheme.lavender,
                    isUnlocked: !memories.isEmpty
                )
                AchievementBadgeView(
                    title: "Trail Builder",
                    subtitle: completedTrips.isEmpty ? "Complete a journey" : "\(completedTrips.count) places visited",
                    systemImage: "point.topleft.down.curvedto.point.bottomright.up",
                    tint: WayfarerTheme.sunrise,
                    isUnlocked: !completedTrips.isEmpty
                )
            }
        }
        .padding(16)
        .elevatedCard(cornerRadius: 20)
    }
}

private struct TravelHistoryTrailView: View {
    let trips: [Trip]

    private var orderedTrips: [Trip] {
        trips.sorted { $0.startDate > $1.startDate }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Travel trail", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                    .font(.headline)
                    .foregroundStyle(WayfarerTheme.ink)
                Spacer()
                Text("\(trips.count) stop\(trips.count == 1 ? "" : "s")")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(WayfarerTheme.sunrise)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(orderedTrips.prefix(8).enumerated()), id: \.element.id) { index, trip in
                        historyStop(trip, index: index, isLast: index == min(orderedTrips.count, 8) - 1)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(16)
        .elevatedCard(cornerRadius: 20)
    }

    private func historyStop(_ trip: Trip, index: Int, isLast: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(index == 0 ? WayfarerTheme.sunrise : WayfarerTheme.ocean)
                        .frame(width: 28, height: 28)
                    Text("\(index + 1)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [WayfarerTheme.ocean.opacity(0.65), WayfarerTheme.sunrise.opacity(0.65)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 72, height: 3)
                        .overlay {
                            HStack(spacing: 10) {
                                Circle().fill(.white).frame(width: 5, height: 5)
                                Circle().fill(.white).frame(width: 5, height: 5)
                            }
                        }
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(trip.destination)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Text(trip.startDate.formatted(.dateTime.month(.abbreviated).year()))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: isLast ? 100 : 92, alignment: .leading)
        }
    }
}

#Preview {
    TripsListView()
        .modelContainer(AppModelContainer.preview)
}
