//
//  Place.swift
//  Wayfarer
//

import Foundation
import SwiftData

enum PlaceCategory: String, Codable, CaseIterable, Identifiable {
    case sight
    case food
    case nature
    case culture
    case shopping
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .sight: "Sight"
        case .food: "Food"
        case .nature: "Nature"
        case .culture: "Culture"
        case .shopping: "Shopping"
        case .other: "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .sight: "binoculars.fill"
        case .food: "fork.knife"
        case .nature: "leaf.fill"
        case .culture: "building.columns.fill"
        case .shopping: "bag.fill"
        case .other: "mappin"
        }
    }
}

@Model
final class Place {
    var name: String
    var category: PlaceCategory
    var address: String
    var notes: String
    var isMustSee: Bool
    @Attribute(.externalStorage) var photoData: Data?
    var trip: Trip?

    init(
        name: String,
        category: PlaceCategory = .sight,
        address: String = "",
        notes: String = "",
        isMustSee: Bool = false
    ) {
        self.name = name
        self.category = category
        self.address = address
        self.notes = notes
        self.isMustSee = isMustSee
    }
}
