//
//  WayfarerAppIntents.swift
//  Wayfarer
//

import AppIntents
import Foundation
import SwiftData

struct WayfarerShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .teal

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: NextTripIntent(),
            phrases: [
                "What's my next trip in \(.applicationName)",
                "Show my next trip in \(.applicationName)",
                "Ask \(.applicationName) about my next trip"
            ],
            shortTitle: "Next Trip",
            systemImageName: "airplane.departure"
        )

        AppShortcut(
            intent: NextItineraryIntent(),
            phrases: [
                "What's my itinerary in \(.applicationName)",
                "Show my next itinerary in \(.applicationName)",
                "Ask \(.applicationName) what is planned next"
            ],
            shortTitle: "Trip Itinerary",
            systemImageName: "list.bullet.clipboard"
        )

        AppShortcut(
            intent: AddEmergencyContactIntent(),
            phrases: [
                "Add an emergency contact in \(.applicationName)",
                "Tell \(.applicationName) to add an emergency contact",
                "Save emergency contact in \(.applicationName)"
            ],
            shortTitle: "Add SOS Contact",
            systemImageName: "person.crop.circle.badge.plus"
        )
    }
}

struct NextTripIntent: AppIntent {
    static var title: LocalizedStringResource = "Ask About Next Trip"
    static var description = IntentDescription("Summarizes your next upcoming or active trip.")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = AppModelContainer.shared.mainContext
        let trips = try context.fetch(FetchDescriptor<Trip>(sortBy: [SortDescriptor(\.startDate)]))
        guard let trip = WayfarerIntentFormatter.nextTrip(from: trips) else {
            return .result(dialog: "You do not have any upcoming trips saved yet.")
        }

        let detail = WayfarerIntentFormatter.tripSummary(trip)
        return .result(dialog: IntentDialog(stringLiteral: detail))
    }
}

struct NextItineraryIntent: AppIntent {
    static var title: LocalizedStringResource = "Ask About Itinerary"
    static var description = IntentDescription("Reads the next few itinerary items from your active or upcoming trip.")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = AppModelContainer.shared.mainContext
        let trips = try context.fetch(FetchDescriptor<Trip>(sortBy: [SortDescriptor(\.startDate)]))
        guard let trip = WayfarerIntentFormatter.nextTrip(from: trips) else {
            return .result(dialog: "You do not have an upcoming trip with itinerary items yet.")
        }

        let upcomingItems = trip.itineraryItems
            .filter { $0.startTime >= Calendar.current.startOfDay(for: .now) }
            .sorted { $0.startTime < $1.startTime }
            .prefix(4)

        guard !upcomingItems.isEmpty else {
            return .result(dialog: "\(trip.name) is saved, but there are no upcoming itinerary items yet.")
        }

        let itemText = upcomingItems
            .map { item in
                let place = item.locationName.isEmpty ? "" : " at \(item.locationName)"
                return "\(item.title)\(place), \(item.startTime.formatted(date: .abbreviated, time: .shortened))"
            }
            .joined(separator: ". ")

        return .result(dialog: IntentDialog(stringLiteral: "For \(trip.name), next up: \(itemText)."))
    }
}

struct AddEmergencyContactIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Emergency Contact"
    static var description = IntentDescription("Adds a trusted emergency contact to your Wayfarer safety screen.")
    static var openAppWhenRun = false

    @Parameter(title: "Name")
    var name: String

    @Parameter(title: "Phone Number")
    var phoneNumber: String

    @Parameter(title: "Relationship", default: "")
    var relationship: String

    @Parameter(title: "Notes", default: "")
    var notes: String

    init() {
        name = ""
        phoneNumber = ""
        relationship = ""
        notes = ""
    }

    init(name: String, phoneNumber: String, relationship: String = "", notes: String = "") {
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
        self.notes = notes
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPhone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanName.isEmpty, !cleanPhone.isEmpty else {
            return .result(dialog: "I need both a name and phone number to add an emergency contact.")
        }

        let contact = EmergencyContact(
            name: cleanName,
            relation: relationship.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: cleanPhone,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        let context = AppModelContainer.shared.mainContext
        context.insert(contact)
        try context.save()

        return .result(dialog: "Added \(cleanName) as an emergency contact.")
    }
}

private enum WayfarerIntentFormatter {
    static func nextTrip(from trips: [Trip]) -> Trip? {
        let today = Calendar.current.startOfDay(for: .now)
        return trips.first { trip in
            trip.status == .active || (trip.status != .completed && trip.endDate >= today)
        }
    }

    static func tripSummary(_ trip: Trip) -> String {
        let itemCount = trip.itineraryItems.count
        let documentCount = trip.documents.count
        let countdown = trip.countdownText.map { ", \($0)" } ?? ""
        return "\(trip.name) is your next trip to \(trip.destination), \(trip.dateRangeText)\(countdown). It has \(itemCount) itinerary items and \(documentCount) saved documents."
    }
}
