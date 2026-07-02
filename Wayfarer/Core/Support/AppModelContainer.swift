//
//  AppModelContainer.swift
//  Wayfarer
//

import Foundation
import SwiftData

enum AppModelContainer {
    static let schema = Schema([
        Trip.self,
        ItineraryItem.self,
        Place.self,
        Companion.self,
        TravelDocument.self,
        ContingencyPlan.self,
        EmergencyContact.self,
        TravelMemory.self,
    ])

    static let shared: ModelContainer = {
        do {
            let configuration = ModelConfiguration(schema: schema)
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create the app model container: \(error)")
        }
    }()

    /// In-memory container pre-filled with sample data, for SwiftUI previews.
    @MainActor
    static let preview: ModelContainer = {
        do {
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            SampleData.insert(into: container.mainContext)
            return container
        } catch {
            fatalError("Could not create the preview model container: \(error)")
        }
    }()
}
