//
//  Trip.swift
//  Wayfarer
//

import Foundation
import SwiftData

enum TripStatus: String, Codable, CaseIterable, Identifiable {
    case dreaming
    case planned
    case active
    case completed

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dreaming: "Dreaming"
        case .planned: "Planned"
        case .active: "On trip"
        case .completed: "Completed"
        }
    }

    var systemImage: String {
        switch self {
        case .dreaming: "sparkles"
        case .planned: "calendar"
        case .active: "airplane.departure"
        case .completed: "checkmark.circle"
        }
    }
}

@Model
final class Trip {
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var status: TripStatus
    var notes: String
    @Attribute(.externalStorage) var coverPhotoData: Data?

    @Relationship(deleteRule: .cascade, inverse: \ItineraryItem.trip)
    var itineraryItems: [ItineraryItem] = []

    @Relationship(deleteRule: .cascade, inverse: \Place.trip)
    var places: [Place] = []

    @Relationship(deleteRule: .cascade, inverse: \Companion.trip)
    var companions: [Companion] = []

    @Relationship(deleteRule: .cascade, inverse: \TravelDocument.trip)
    var documents: [TravelDocument] = []

    @Relationship(deleteRule: .cascade, inverse: \ContingencyPlan.trip)
    var contingencyPlans: [ContingencyPlan] = []

    @Relationship(deleteRule: .cascade, inverse: \TravelMemory.trip)
    var memories: [TravelMemory] = []

    init(
        name: String,
        destination: String,
        startDate: Date,
        endDate: Date,
        status: TripStatus = .planned,
        notes: String = ""
    ) {
        self.name = name
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.notes = notes
    }
}

extension Trip {
    var dateRangeText: String {
        let start = startDate.formatted(.dateTime.day().month(.abbreviated))
        let end = endDate.formatted(.dateTime.day().month(.abbreviated))
        return "\(start) – \(end)"
    }

    var daysUntilStart: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let start = calendar.startOfDay(for: startDate)
        return calendar.dateComponents([.day], from: today, to: start).day ?? 0
    }

    var countdownText: String? {
        switch status {
        case .active: "On trip now"
        case .completed, .dreaming: nil
        case .planned: daysUntilStart > 0 ? "in \(daysUntilStart) days" : nil
        }
    }

    /// Every calendar day between start and end, used for itinerary grouping.
    var days: [Date] {
        let calendar = Calendar.current
        var result: [Date] = []
        var day = calendar.startOfDay(for: startDate)
        let last = calendar.startOfDay(for: endDate)
        while day <= last {
            result.append(day)
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return result
    }

    var activePlan: ContingencyPlan? {
        contingencyPlans.first { $0.isActive }
    }

    func plan(for rank: PlanRank) -> ContingencyPlan? {
        contingencyPlans.first { $0.rank == rank }
    }
}
