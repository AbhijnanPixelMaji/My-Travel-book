//
//  Companion.swift
//  Wayfarer
//

import Foundation
import SwiftData

@Model
final class Companion {
    var name: String
    var role: String
    var phone: String
    var email: String
    var trip: Trip?

    init(name: String, role: String = "", phone: String = "", email: String = "") {
        self.name = name
        self.role = role
        self.phone = phone
        self.email = email
    }
}

extension Companion {
    var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        return parts.compactMap { $0.first.map(String.init) }.joined().uppercased()
    }
}
