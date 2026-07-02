//
//  PlansSectionView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData

/// Plan A/B/C contingency manager inside the trip detail screen.
struct PlansSectionView: View {
    @Bindable var trip: Trip
    @Environment(\.modelContext) private var modelContext
    @State private var isAddingPlan = false
    @State private var editingPlan: ContingencyPlan?
    @State private var planSwitched = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            planACard

            ForEach(PlanRank.allCases) { rank in
                if let plan = trip.plan(for: rank) {
                    planCard(plan)
                }
            }

            if trip.contingencyPlans.count < PlanRank.allCases.count {
                Button {
                    isAddingPlan = true
                } label: {
                    Label("Add backup plan", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .sensoryFeedback(.success, trigger: planSwitched)
        .sheet(isPresented: $isAddingPlan) {
            ContingencyPlanEditorView(trip: trip)
        }
        .sheet(item: $editingPlan) { plan in
            ContingencyPlanEditorView(trip: trip, plan: plan)
        }
    }

    /// Plan A is simply the main itinerary; it is shown here for orientation.
    private var planACard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Plan A")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                if trip.activePlan == nil {
                    TagChip(text: "Active", systemImage: "checkmark", tint: .green)
                }
            }
            Text("Your main itinerary")
                .font(.footnote)
                .foregroundStyle(.secondary)
            if trip.activePlan != nil {
                Button("Switch back to Plan A") {
                    setActivePlan(nil)
                }
                .font(.footnote)
                .padding(.top, 4)
            }
        }
        .cardStyle()
    }

    private func planCard(_ plan: ContingencyPlan) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(plan.rank.label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                if plan.isActive {
                    TagChip(text: "Active", systemImage: "checkmark", tint: .green)
                }
                Button {
                    editingPlan = plan
                } label: {
                    Image(systemName: "pencil")
                        .font(.footnote)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Edit \(plan.rank.label)")
            }

            Text(plan.title)
                .font(.subheadline)

            if !plan.trigger.isEmpty {
                Label(plan.trigger, systemImage: "exclamationmark.triangle")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }

            if !plan.stepList.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(plan.stepList, id: \.self) { step in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "circle")
                                .font(.system(size: 7))
                                .padding(.top, 5)
                            Text(step)
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                }
            }

            if !plan.isActive {
                Button("Switch to \(plan.rank.label)") {
                    setActivePlan(plan)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .padding(.top, 4)
            }
        }
        .cardStyle()
    }

    private func setActivePlan(_ plan: ContingencyPlan?) {
        for existing in trip.contingencyPlans {
            existing.isActive = (existing === plan)
        }
        planSwitched.toggle()
    }
}
