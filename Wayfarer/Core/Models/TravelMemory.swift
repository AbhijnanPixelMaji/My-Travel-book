//
//  TravelMemory.swift
//  Wayfarer
//

import Foundation
import SwiftData

/// A photo with a short story — together they make the memory album.
@Model
final class TravelMemory {
    var title: String
    var story: String
    var date: Date
    var locationName: String
    @Attribute(.externalStorage) var photoData: Data?
    var trip: Trip?

    init(
        title: String,
        story: String = "",
        date: Date = .now,
        locationName: String = ""
    ) {
        self.title = title
        self.story = story
        self.date = date
        self.locationName = locationName
    }
}

extension TravelMemory {
    var dateText: String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}
