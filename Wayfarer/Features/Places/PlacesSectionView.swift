//
//  PlacesSectionView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData
import UIKit

/// Saved places grid inside the trip detail screen.
struct PlacesSectionView: View {
    @Bindable var trip: Trip
    @Environment(\.modelContext) private var modelContext
    @State private var isAddingPlace = false
    @State private var editingPlace: Place?

    private var sortedPlaces: [Place] {
        trip.places.sorted {
            if $0.isMustSee != $1.isMustSee { return $0.isMustSee }
            return $0.name < $1.name
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(sortedPlaces) { place in
                    Button {
                        editingPlace = place
                    } label: {
                        placeCard(place)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            modelContext.delete(place)
                        } label: {
                            Label("Delete place", systemImage: "trash")
                        }
                    }
                }
            }

            if trip.places.isEmpty {
                ContentUnavailableView(
                    "No places saved",
                    systemImage: "mappin.and.ellipse",
                    description: Text("Save the sights, restaurants, and spots you don't want to miss.")
                )
            }

            Button {
                isAddingPlace = true
            } label: {
                Label("Add place", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .sheet(isPresented: $isAddingPlace) {
            PlaceEditorView(trip: trip)
        }
        .sheet(item: $editingPlace) { place in
            PlaceEditorView(trip: trip, place: place)
        }
    }

    private func placeCard(_ place: Place) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                if let data = place.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.accentColor.opacity(0.1)
                    Image(systemName: place.category.systemImage)
                        .font(.title2)
                        .foregroundStyle(Color.accentColor.opacity(0.6))
                }
            }
            .frame(height: 90)
            .frame(maxWidth: .infinity)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(place.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 4)
                    if place.isMustSee {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                    }
                }
                Text(place.category.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
