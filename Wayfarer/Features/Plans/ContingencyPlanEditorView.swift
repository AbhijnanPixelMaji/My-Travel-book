//
//  ContingencyPlanEditorView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData

struct ContingencyPlanEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let trip: Trip
    private let plan: ContingencyPlan?

    @State private var rank: PlanRank
    @State private var title: String
    @State private var trigger: String
    @State private var steps: String

    init(trip: Trip, plan: ContingencyPlan? = nil) {
        self.trip = trip
        self.plan = plan
        let firstFreeRank = PlanRank.allCases.first { trip.plan(for: $0) == nil } ?? .b
        _rank = State(initialValue: plan?.rank ?? firstFreeRank)
        _title = State(initialValue: plan?.title ?? "")
        _trigger = State(initialValue: plan?.trigger ?? "")
        _steps = State(initialValue: plan?.steps ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Plan") {
                    Picker("Rank", selection: $rank) {
                        ForEach(PlanRank.allCases) { rank in
                            Text(rank.label).tag(rank)
                        }
                    }
                    .pickerStyle(.segmented)
                    TextField("Title, e.g. Osaka overnight", text: $title)
                }
                Section {
                    TextField("e.g. Flight canceled", text: $trigger, axis: .vertical)
                } header: {
                    Text("Trigger")
                } footer: {
                    Text("The situation that should make you switch to this plan.")
                }
                Section {
                    TextField("One step per line", text: $steps, axis: .vertical)
                        .lineLimit(4...10)
                } header: {
                    Text("Steps")
                }
                if plan != nil {
                    Section {
                        Button("Delete plan", role: .destructive) {
                            if let plan { modelContext.delete(plan) }
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(plan == nil ? "New backup plan" : "Edit plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        if let plan {
            plan.rank = rank
            plan.title = title
            plan.trigger = trigger
            plan.steps = steps
        } else {
            let newPlan = ContingencyPlan(rank: rank, title: title, trigger: trigger, steps: steps)
            modelContext.insert(newPlan)
            newPlan.trip = trip
        }
        dismiss()
    }
}
