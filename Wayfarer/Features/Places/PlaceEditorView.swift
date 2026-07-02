//
//  PlaceEditorView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData

struct PlaceEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let trip: Trip
    private let place: Place?

    @State private var name: String
    @State private var category: PlaceCategory
    @State private var address: String
    @State private var notes: String
    @State private var isMustSee: Bool
    @State private var photoData: Data?

    init(trip: Trip, place: Place? = nil) {
        self.trip = trip
        self.place = place
        _name = State(initialValue: place?.name ?? "")
        _category = State(initialValue: place?.category ?? .sight)
        _address = State(initialValue: place?.address ?? "")
        _notes = State(initialValue: place?.notes ?? "")
        _isMustSee = State(initialValue: place?.isMustSee ?? false)
        _photoData = State(initialValue: place?.photoData)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Place") {
                    TextField("Name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(PlaceCategory.allCases) { category in
                            Label(category.label, systemImage: category.systemImage)
                                .tag(category)
                        }
                    }
                    Toggle("Must-see", isOn: $isMustSee)
                }
                Section("Details") {
                    TextField("Address or area", text: $address)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(2...5)
                    PhotoPickerButton(title: "Add photo", imageData: $photoData)
                }
                if place != nil {
                    Section {
                        Button("Delete place", role: .destructive) {
                            if let place { modelContext.delete(place) }
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(place == nil ? "New place" : "Edit place")
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
        if let place {
            place.name = name
            place.category = category
            place.address = address
            place.notes = notes
            place.isMustSee = isMustSee
            place.photoData = photoData
        } else {
            let newPlace = Place(
                name: name,
                category: category,
                address: address,
                notes: notes,
                isMustSee: isMustSee
            )
            newPlace.photoData = photoData
            modelContext.insert(newPlace)
            newPlace.trip = trip
        }
        dismiss()
    }
}
