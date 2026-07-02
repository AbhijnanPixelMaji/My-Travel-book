//
//  ContingencyPlan.swift
//  Wayfarer
//

import Foundation
import SwiftData

enum PlanRank: String, Codable, CaseIterable, Identifiable {
    case b = "B"
    case c = "C"

    var id: String { rawValue }

    var label: String { "Plan \(rawValue)" }
}

@Model
final class ContingencyPlan {
    var rank: PlanRank
    var title: String
    /// The condition that should cause this plan to kick in, e.g. "Flight canceled".
    var trigger: String
    /// One step per line; the UI renders them as a checklist.
    var steps: String
    var isActive: Bool
    var trip: Trip?

    init(
        rank: PlanRank,
        title: String,
        trigger: String = "",
        steps: String = "",
        isActive: Bool = false
    ) {
        self.rank = rank
        self.title = title
        self.trigger = trigger
        self.steps = steps
        self.isActive = isActive
    }
}

extension ContingencyPlan {
    var stepList: [String] {
        steps
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
