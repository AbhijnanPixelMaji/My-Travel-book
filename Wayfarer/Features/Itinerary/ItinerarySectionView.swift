//
//  ItinerarySectionView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData

/// Day-by-day timeline shown inside the trip detail screen.
struct ItinerarySectionView: View {
    @Bindable var trip: Trip
    @Environment(\.modelContext) private var modelContext
    @State private var isAddingItem = false
    @State private var editingItem: ItineraryItem?

    private var itemsByDay: [(day: Date, items: [ItineraryItem])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: trip.itineraryItems) {
            calendar.startOfDay(for: $0.startTime)
        }
        return groups.keys.sorted().map { day in
            (day: day, items: groups[day, default: []].sorted { $0.startTime < $1.startTime })
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let activePlan = trip.activePlan {
                activePlanBanner(activePlan)
            }

            ForEach(itemsByDay, id: \.day) { group in
                VStack(alignment: .leading, spacing: 8) {
                    Text(dayTitle(for: group.day))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    ForEach(group.items) { item in
                        Button {
                            editingItem = item
                        } label: {
                            ItineraryItemRow(item: item)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                modelContext.delete(item)
                            } label: {
                                Label("Delete stop", systemImage: "trash")
                            }
                        }
                    }
                }
            }

            if trip.itineraryItems.isEmpty {
                ContentUnavailableView(
                    "No stops yet",
                    systemImage: "map",
                    description: Text("Add flights, meals, stays, and activities to build the day-by-day plan.")
                )
            }

            Button {
                isAddingItem = true
            } label: {
                Label("Add stop", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .sheet(isPresented: $isAddingItem) {
            ItineraryItemEditorView(trip: trip)
        }
        .sheet(item: $editingItem) { item in
            ItineraryItemEditorView(trip: trip, item: item)
        }
    }

    private func dayTitle(for day: Date) -> String {
        let calendar = Calendar.current
        let tripStart = calendar.startOfDay(for: trip.startDate)
        let dayNumber = (calendar.dateComponents([.day], from: tripStart, to: day).day ?? 0) + 1
        let dateText = day.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
        return "Day \(dayNumber) · \(dateText)"
    }

    private func activePlanBanner(_ plan: ContingencyPlan) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.triangle.branch")
            VStack(alignment: .leading, spacing: 2) {
                Text("\(plan.rank.label) is active")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(plan.title)
                    .font(.footnote)
            }
            Spacer()
        }
        .foregroundStyle(.orange)
        .padding(12)
        .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct ItineraryItemRow: View {
    let item: ItineraryItem

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(item.timeText)
                    .font(.footnote)
                    .fontWeight(.medium)
                Text(item.durationText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 60)

            Image(systemName: item.category.systemImage)
                .font(.subheadline)
                .frame(width: 34, height: 34)
                .background(Color.accentColor.opacity(0.12), in: Circle())
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if !item.locationName.isEmpty {
                    Text(item.locationName)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                if !item.bookedBy.isEmpty {
                    Text("Booked by \(item.bookedBy)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .cardStyle()
    }
}
