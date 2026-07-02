//
//  ItineraryItem.swift
//  Wayfarer
//

import Foundation
import SwiftData

enum ItineraryCategory: String, Codable, CaseIterable, Identifiable {
    case activity
    case food
    case transport
    case stay
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .activity: "Activity"
        case .food: "Food"
        case .transport: "Transport"
        case .stay: "Stay"
        case .other: "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .activity: "figure.walk"
        case .food: "fork.knife"
        case .transport: "tram.fill"
        case .stay: "bed.double.fill"
        case .other: "mappin"
        }
    }
}

@Model
final class ItineraryItem {
    var title: String
    var startTime: Date
    var durationMinutes: Int
    var category: ItineraryCategory
    var locationName: String
    var bookedBy: String
    var notes: String
    @Attribute(.externalStorage) var photoData: Data?
    var trip: Trip?

    init(
        title: String,
        startTime: Date,
        durationMinutes: Int = 60,
        category: ItineraryCategory = .activity,
        locationName: String = "",
        bookedBy: String = "",
        notes: String = ""
    ) {
        self.title = title
        self.startTime = startTime
        self.durationMinutes = durationMinutes
        self.category = category
        self.locationName = locationName
        self.bookedBy = bookedBy
        self.notes = notes
    }
}

extension ItineraryItem {
    var timeText: String {
        startTime.formatted(date: .omitted, time: .shortened)
    }

    var durationText: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if hours > 0 && minutes > 0 { return "\(hours) h \(minutes) min" }
        if hours > 0 { return "\(hours) h" }
        return "\(minutes) min"
    }
}
