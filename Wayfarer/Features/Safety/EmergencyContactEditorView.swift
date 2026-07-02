//
//  EmergencyContactEditorView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData

struct EmergencyContactEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let contact: EmergencyContact?

    @State private var name: String
    @State private var relation: String
    @State private var phone: String
    @State private var notes: String

    init(contact: EmergencyContact? = nil) {
        self.contact = contact
        _name = State(initialValue: contact?.name ?? "")
        _relation = State(initialValue: contact?.relation ?? "")
        _phone = State(initialValue: contact?.phone ?? "")
        _notes = State(initialValue: contact?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Contact") {
                    TextField("Name", text: $name)
                    TextField("Who they are, e.g. Hotel desk", text: $relation)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                if contact != nil {
                    Section {
                        Button("Delete contact", role: .destructive) {
                            if let contact { modelContext.delete(contact) }
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(contact == nil ? "New contact" : "Edit contact")
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
        if let contact {
            contact.name = name
            contact.relation = relation
            contact.phone = phone
            contact.notes = notes
        } else {
            modelContext.insert(
                EmergencyContact(name: name, relation: relation, phone: phone, notes: notes)
            )
        }
        dismiss()
    }
}
