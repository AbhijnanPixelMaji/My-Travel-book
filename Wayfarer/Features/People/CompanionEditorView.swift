//
//  CompanionEditorView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData

struct CompanionEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let trip: Trip
    private let companion: Companion?

    @State private var name: String
    @State private var role: String
    @State private var phone: String
    @State private var email: String

    init(trip: Trip, companion: Companion? = nil) {
        self.trip = trip
        self.companion = companion
        _name = State(initialValue: companion?.name ?? "")
        _role = State(initialValue: companion?.role ?? "")
        _phone = State(initialValue: companion?.phone ?? "")
        _email = State(initialValue: companion?.email ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Person") {
                    TextField("Name", text: $name)
                    TextField("Role, e.g. Co-planner", text: $role)
                }
                Section("Contact") {
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                if companion != nil {
                    Section {
                        Button("Remove person", role: .destructive) {
                            if let companion { modelContext.delete(companion) }
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(companion == nil ? "Add person" : "Edit person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        if let companion {
            companion.name = name
            companion.role = role
            companion.phone = phone
            companion.email = email
        } else {
            let newCompanion = Companion(name: name, role: role, phone: phone, email: email)
            modelContext.insert(newCompanion)
            newCompanion.trip = trip
        }
        dismiss()
    }
}
