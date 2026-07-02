//
//  MemoryEditorView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData

struct MemoryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate) private var trips: [Trip]

    private let memory: TravelMemory?

    @State private var title: String
    @State private var story: String
    @State private var date: Date
    @State private var locationName: String
    @State private var photoData: Data?
    @State private var selectedTrip: Trip?

    init(memory: TravelMemory? = nil) {
        self.memory = memory
        _title = State(initialValue: memory?.title ?? "")
        _story = State(initialValue: memory?.story ?? "")
        _date = State(initialValue: memory?.date ?? .now)
        _locationName = State(initialValue: memory?.locationName ?? "")
        _photoData = State(initialValue: memory?.photoData)
        _selectedTrip = State(initialValue: memory?.trip)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    PhotoPickerButton(title: "Add photo", imageData: $photoData)
                }
                Section("Moment") {
                    TextField("Title, e.g. Sunrise at the torii gates", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Where was this?", text: $locationName)
                }
                Section {
                    TextField(
                        "What made this moment worth keeping?",
                        text: $story,
                        axis: .vertical
                    )
                    .lineLimit(4...10)
                } header: {
                    Text("Story")
                }
                Section("Trip") {
                    Picker("Belongs to", selection: $selectedTrip) {
                        Text("None").tag(Trip?.none)
                        ForEach(trips) { trip in
                            Text(trip.name).tag(Optional(trip))
                        }
                    }
                }
                if memory != nil {
                    Section {
                        Button("Delete memory", role: .destructive) {
                            if let memory { modelContext.delete(memory) }
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(memory == nil ? "New memory" : "Edit memory")
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
        if let memory {
            memory.title = title
            memory.story = story
            memory.date = date
            memory.locationName = locationName
            memory.photoData = photoData
            memory.trip = selectedTrip
        } else {
            let newMemory = TravelMemory(
                title: title,
                story: story,
                date: date,
                locationName: locationName
            )
            newMemory.photoData = photoData
            modelContext.insert(newMemory)
            newMemory.trip = selectedTrip
        }
        dismiss()
    }
}
