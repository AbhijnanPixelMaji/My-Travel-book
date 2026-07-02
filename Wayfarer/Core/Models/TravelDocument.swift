//
//  TravelDocument.swift
//  Wayfarer
//

import Foundation
import SwiftData

enum DocumentKind: String, Codable, CaseIterable, Identifiable {
    case flight
    case hotel
    case rail
    case ticket
    case insurance
    case passport
    case visa
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .flight: "Flight"
        case .hotel: "Hotel"
        case .rail: "Rail"
        case .ticket: "Ticket"
        case .insurance: "Insurance"
        case .passport: "Passport"
        case .visa: "Visa"
        case .other: "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .flight: "airplane"
        case .hotel: "bed.double.fill"
        case .rail: "tram.fill"
        case .ticket: "ticket.fill"
        case .insurance: "cross.case.fill"
        case .passport: "person.text.rectangle.fill"
        case .visa: "doc.text.fill"
        case .other: "doc.fill"
        }
    }
}

@Model
final class TravelDocument {
    var title: String
    var kind: DocumentKind
    var reference: String
    var expiryDate: Date?
    var notes: String
    @Attribute(.externalStorage) var scanData: Data?
    var trip: Trip?

    init(
        title: String,
        kind: DocumentKind = .ticket,
        reference: String = "",
        expiryDate: Date? = nil,
        notes: String = ""
    ) {
        self.title = title
        self.kind = kind
        self.reference = reference
        self.expiryDate = expiryDate
        self.notes = notes
    }
}

extension TravelDocument {
    var daysUntilExpiry: Int? {
        guard let expiryDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let expiry = calendar.startOfDay(for: expiryDate)
        return calendar.dateComponents([.day], from: today, to: expiry).day
    }

    /// Flags documents expiring within 90 days so the wallet can warn early.
    var isExpiringSoon: Bool {
        guard let days = daysUntilExpiry else { return false }
        return days <= 90
    }

    var expiryText: String? {
        guard let days = daysUntilExpiry else { return nil }
        if days < 0 { return "Expired" }
        if days == 0 { return "Expires today" }
        return "Expires in \(days) d"
    }
}
