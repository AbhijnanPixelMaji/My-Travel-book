//
//  DocumentEditorView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData

struct DocumentEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate) private var trips: [Trip]

    private let document: TravelDocument?

    @State private var title: String
    @State private var kind: DocumentKind
    @State private var reference: String
    @State private var hasExpiry: Bool
    @State private var expiryDate: Date
    @State private var notes: String
    @State private var scanData: Data?
    @State private var selectedTrip: Trip?

    init(document: TravelDocument? = nil) {
        self.document = document
        _title = State(initialValue: document?.title ?? "")
        _kind = State(initialValue: document?.kind ?? .ticket)
        _reference = State(initialValue: document?.reference ?? "")
        _hasExpiry = State(initialValue: document?.expiryDate != nil)
        _expiryDate = State(initialValue: document?.expiryDate ?? .now)
        _notes = State(initialValue: document?.notes ?? "")
        _scanData = State(initialValue: document?.scanData)
        _selectedTrip = State(initialValue: document?.trip)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Document") {
                    TextField("Title", text: $title)
                    Picker("Type", selection: $kind) {
                        ForEach(DocumentKind.allCases) { kind in
                            Label(kind.label, systemImage: kind.systemImage)
                                .tag(kind)
                        }
                    }
                    TextField("Reference or number", text: $reference)
                }
                Section("Trip") {
                    Picker("Belongs to", selection: $selectedTrip) {
                        Text("None").tag(Trip?.none)
                        ForEach(trips) { trip in
                            Text(trip.name).tag(Optional(trip))
                        }
                    }
                }
                Section("Expiry") {
                    Toggle("Has expiry date", isOn: $hasExpiry)
                    if hasExpiry {
                        DatePicker("Expires", selection: $expiryDate, displayedComponents: .date)
                    }
                }
                Section("Scan") {
                    PhotoPickerButton(title: "Add scan or photo", imageData: $scanData)
                }
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(2...5)
                }
                if document != nil {
                    Section {
                        Button("Delete document", role: .destructive) {
                            if let document { modelContext.delete(document) }
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(document == nil ? "New document" : "Edit document")
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
        if let document {
            document.title = title
            document.kind = kind
            document.reference = reference
            document.expiryDate = hasExpiry ? expiryDate : nil
            document.notes = notes
            document.scanData = scanData
            document.trip = selectedTrip
        } else {
            let newDocument = TravelDocument(
                title: title,
                kind: kind,
                reference: reference,
                expiryDate: hasExpiry ? expiryDate : nil,
                notes: notes
            )
            newDocument.scanData = scanData
            modelContext.insert(newDocument)
            newDocument.trip = selectedTrip
        }
        dismiss()
    }
}
