//
//  SampleData.swift
//  Wayfarer
//

import Foundation
import SwiftData

/// Seeds one example trip on first launch so the app never opens empty.
enum SampleData {
    @MainActor
    static func seedIfNeeded(context: ModelContext) {
        let tripCount = (try? context.fetchCount(FetchDescriptor<Trip>())) ?? 0
        if tripCount == 0 {
            insert(into: context)
        } else {
            insertDemoTripsIfNeeded(into: context)
        }
    }

    @MainActor
    static func insert(into context: ModelContext) {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: 12, to: calendar.startOfDay(for: .now)) ?? .now
        let end = calendar.date(byAdding: .day, value: 7, to: start) ?? start

        let trip = Trip(
            name: "Kyoto spring",
            destination: "Kyoto, Japan",
            startDate: start,
            endDate: end,
            status: .planned,
            notes: "Cherry blossom season — book everything early."
        )
        context.insert(trip)

        let day1 = start
        let day2 = calendar.date(byAdding: .day, value: 1, to: start) ?? start

        let items: [ItineraryItem] = [
            ItineraryItem(
                title: "Flight DEL → KIX",
                startTime: at(day1, hour: 8, minute: 40),
                durationMinutes: 420,
                category: .transport,
                locationName: "Indira Gandhi International Airport",
                bookedBy: "Me"
            ),
            ItineraryItem(
                title: "Check in — Hotel Granvia",
                startTime: at(day1, hour: 18, minute: 0),
                durationMinutes: 30,
                category: .stay,
                locationName: "Kyoto Station",
                bookedBy: "Priya"
            ),
            ItineraryItem(
                title: "Fushimi Inari shrine",
                startTime: at(day2, hour: 9, minute: 0),
                durationMinutes: 120,
                category: .activity,
                locationName: "Fushimi Ward",
                notes: "Go early to beat the crowd."
            ),
            ItineraryItem(
                title: "Lunch at Nishiki market",
                startTime: at(day2, hour: 12, minute: 30),
                durationMinutes: 90,
                category: .food,
                locationName: "Nishiki Market",
                bookedBy: "Priya"
            ),
        ]
        for item in items {
            context.insert(item)
            item.trip = trip
        }

        let places: [Place] = [
            Place(name: "Arashiyama bamboo grove", category: .nature, isMustSee: true),
            Place(name: "Kinkaku-ji", category: .culture, isMustSee: true),
            Place(name: "Ichiran Ramen", category: .food, notes: "Open till 22:00"),
        ]
        for place in places {
            context.insert(place)
            place.trip = trip
        }

        let companions: [Companion] = [
            Companion(name: "Priya Sharma", role: "Co-planner", phone: "+91 98100 00000"),
            Companion(name: "Kenji Watanabe", role: "Local guide", phone: "+81 90 0000 0000"),
        ]
        for companion in companions {
            context.insert(companion)
            companion.trip = trip
        }

        let flight = TravelDocument(
            title: "Boarding pass DEL → KIX",
            kind: .flight,
            reference: "NH-842 · Seat 32A"
        )
        let hotel = TravelDocument(
            title: "Hotel Granvia voucher",
            kind: .hotel,
            reference: "Conf. #88213"
        )
        let visa = TravelDocument(
            title: "Japan visa",
            kind: .visa,
            reference: "Passport K1234567",
            expiryDate: calendar.date(byAdding: .day, value: 84, to: .now)
        )
        for document in [flight, hotel, visa] {
            context.insert(document)
            document.trip = trip
        }

        let planB = ContingencyPlan(
            rank: .b,
            title: "Osaka overnight + morning rail",
            trigger: "Flight NH-842 canceled or delayed past 22:00",
            steps: "Book airport hotel in Osaka\nTake 07:10 Haruka express to Kyoto\nMove day 1 dinner to day 2\nTell Kenji the new pickup time"
        )
        let planC = ContingencyPlan(
            rank: .c,
            title: "Skip Kyoto day 1, refund tour",
            trigger: "Typhoon closes rail lines",
            steps: "Cancel day 1 walking tour for refund\nStay near the airport\nRe-plan day 1 sights into day 3"
        )
        for plan in [planB, planC] {
            context.insert(plan)
            plan.trip = trip
        }

        let memory = TravelMemory(
            title: "First glimpse of the torii gates",
            story: "We got to Fushimi Inari before sunrise and had the path almost to ourselves. The vermilion gates went on and on up the hill, and for a few minutes the only sound was our footsteps and the crows.",
            date: calendar.date(byAdding: .year, value: -1, to: .now) ?? .now,
            locationName: "Fushimi Inari, Kyoto"
        )
        context.insert(memory)
        memory.trip = trip

        context.insert(EmergencyContact(
            name: "Hotel Granvia front desk",
            relation: "Hotel",
            phone: "+81 75 344 8888"
        ))
        context.insert(EmergencyContact(
            name: "Kenji Watanabe",
            relation: "Local guide",
            phone: "+81 90 0000 0000"
        ))

        insertDemoTripsIfNeeded(into: context)
    }

    @MainActor
    private static func insertDemoTripsIfNeeded(into context: ModelContext) {
        let existingTrips = (try? context.fetch(FetchDescriptor<Trip>())) ?? []
        let existingNames = Set(existingTrips.map(\.name))
        let calendar = Calendar.current

        let demoTrips: [Trip] = [
            Trip(
                name: "Bali reset",
                destination: "Bali, Indonesia",
                startDate: calendar.date(byAdding: .month, value: -8, to: .now) ?? .now,
                endDate: calendar.date(byAdding: .day, value: -230, to: .now) ?? .now,
                status: .completed,
                notes: "Rice terraces, beach mornings, and a slower rhythm."
            ),
            Trip(
                name: "Paris postcards",
                destination: "Paris, France",
                startDate: calendar.date(byAdding: .month, value: -15, to: .now) ?? .now,
                endDate: calendar.date(byAdding: .day, value: -440, to: .now) ?? .now,
                status: .completed,
                notes: "Museums, long walks, and the best bakery list."
            ),
            Trip(
                name: "Iceland northern lights",
                destination: "Reykjavik, Iceland",
                startDate: calendar.date(byAdding: .month, value: 5, to: .now) ?? .now,
                endDate: calendar.date(byAdding: .day, value: 165, to: .now) ?? .now,
                status: .dreaming,
                notes: "Aurora hunt, waterfalls, and hot springs."
            ),
            Trip(
                name: "Dubai stopover",
                destination: "Dubai, UAE",
                startDate: calendar.date(byAdding: .month, value: 2, to: .now) ?? .now,
                endDate: calendar.date(byAdding: .day, value: 68, to: .now) ?? .now,
                status: .planned,
                notes: "Short stopover with family dinner and skyline views."
            ),
        ]

        for trip in demoTrips where !existingNames.contains(trip.name) {
            context.insert(trip)
            let document = TravelDocument(
                title: "\(trip.destination.components(separatedBy: ",").first ?? trip.name) booking",
                kind: trip.status == .completed ? .ticket : .flight,
                reference: "Demo"
            )
            context.insert(document)
            document.trip = trip
        }
    }

    private static func at(_ day: Date, hour: Int, minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }
}
