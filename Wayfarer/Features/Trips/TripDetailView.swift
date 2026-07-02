//
//  TripDetailView.swift
//  Wayfarer
//

import SwiftUI
import UIKit

struct TripDetailView: View {
    @Bindable var trip: Trip
    @State private var selectedSection: TripSection = .itinerary
    @State private var isEditingTrip = false

    private enum TripSection: String, CaseIterable, Identifiable {
        case itinerary = "Itinerary"
        case places = "Places"
        case people = "People"
        case plans = "Plans"

        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                Picker("Section", selection: $selectedSection) {
                    ForEach(TripSection.allCases) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)

                switch selectedSection {
                case .itinerary:
                    ItinerarySectionView(trip: trip)
                case .places:
                    PlacesSectionView(trip: trip)
                case .people:
                    PeopleSectionView(trip: trip)
                case .plans:
                    PlansSectionView(trip: trip)
                }
            }
            .padding()
        }
        .background(WayfarerTheme.pageBackground.ignoresSafeArea())
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { isEditingTrip = true }
            }
        }
        .sheet(isPresented: $isEditingTrip) {
            TripEditorView(trip: trip)
        }
    }

    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            headerCover
                .frame(height: 230)
                .frame(maxWidth: .infinity)
                .overlay {
                    LinearGradient(
                        colors: [.black.opacity(0.02), .black.opacity(0.72)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(trip.name)
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        Text(trip.destination)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.84))
                    }
                    Spacer()
                    TagChip(
                        text: trip.status.label,
                        systemImage: trip.status.systemImage,
                        tint: WayfarerTheme.color(for: trip.status)
                    )
                    .background(.ultraThinMaterial, in: Capsule())
                }

                HStack(spacing: 10) {
                    Label(trip.dateRangeText, systemImage: "calendar")
                    if let countdown = trip.countdownText {
                        Text(countdown)
                    }
                }
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.82))

                HStack(spacing: 10) {
                    WayfarerMetricTile(value: "\(trip.itineraryItems.count)", label: "Itinerary", systemImage: "list.bullet.clipboard", tint: WayfarerTheme.ocean)
                    WayfarerMetricTile(value: "\(trip.documents.count)", label: "Tickets", systemImage: "wallet.pass.fill", tint: WayfarerTheme.sunrise)
                    WayfarerMetricTile(value: "\(trip.companions.count)", label: "People", systemImage: "person.2.fill", tint: WayfarerTheme.lavender)
                }

                if !trip.notes.isEmpty {
                    Text(trip.notes)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(3)
                }
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 10)
    }

    @ViewBuilder
    private var headerCover: some View {
        if let data = trip.coverPhotoData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                WayfarerTheme.primaryGradient
                VStack(spacing: 10) {
                    Image(systemName: "globe.asia.australia.fill")
                        .font(.system(size: 48))
                    Text(trip.destination)
                        .font(.headline)
                }
                .foregroundStyle(.white.opacity(0.72))
            }
        }
    }
}
