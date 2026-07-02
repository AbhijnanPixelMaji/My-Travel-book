//
//  EmergencyContact.swift
//  Wayfarer
//

import Foundation
import SwiftData

@Model
final class EmergencyContact {
    var name: String
    /// Who this person is to the traveler, e.g. "Hotel front desk", "Local guide".
    var relation: String
    var phone: String
    var notes: String

    init(name: String, relation: String = "", phone: String = "", notes: String = "") {
        self.name = name
        self.relation = relation
        self.phone = phone
        self.notes = notes
    }
}
