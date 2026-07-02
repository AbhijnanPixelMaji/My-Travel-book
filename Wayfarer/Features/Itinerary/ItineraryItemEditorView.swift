//
//  ItineraryItemEditorView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData

struct ItineraryItemEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let trip: Trip
    private let item: ItineraryItem?

    @State private var title: String
    @State private var startTime: Date
    @State private var durationMinutes: Int
    @State private var category: ItineraryCategory
    @State private var locationName: String
    @State private var bookedBy: String
    @State private var notes: String
    @State private var photoData: Data?

    init(trip: Trip, item: ItineraryItem? = nil) {
        self.trip = trip
        self.item = item
        let defaultStart = Calendar.current.date(
            bySettingHour: 9, minute: 0, second: 0,
            of: trip.startDate
        ) ?? trip.startDate
        _title = State(initialValue: item?.title ?? "")
        _startTime = State(initialValue: item?.startTime ?? defaultStart)
        _durationMinutes = State(initialValue: item?.durationMinutes ?? 60)
        _category = State(initialValue: item?.category ?? .activity)
        _locationName = State(initialValue: item?.locationName ?? "")
        _bookedBy = State(initialValue: item?.bookedBy ?? "")
        _notes = State(initialValue: item?.notes ?? "")
        _photoData = State(initialValue: item?.photoData)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Stop") {
                    TextField("Title", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(ItineraryCategory.allCases) { category in
                            Label(category.label, systemImage: category.systemImage)
                                .tag(category)
                        }
                    }
                    TextField("Location", text: $locationName)
                }
                Section("When") {
                    DatePicker("Starts", selection: $startTime)
                    Stepper(
                        "Duration: \(durationText)",
                        value: $durationMinutes,
                        in: 15...720,
                        step: 15
                    )
                }
                Section("Details") {
                    TextField("Booked by", text: $bookedBy)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(2...5)
                    PhotoPickerButton(title: "Add photo", imageData: $photoData)
                }
                if item != nil {
                    Section {
                        Button("Delete stop", role: .destructive) {
                            if let item { modelContext.delete(item) }
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(item == nil ? "New stop" : "Edit stop")
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

    private var durationText: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if hours > 0 && minutes > 0 { return "\(hours) h \(minutes) min" }
        if hours > 0 { return "\(hours) h" }
        return "\(minutes) min"
    }

    private func save() {
        if let item {
            item.title = title
            item.startTime = startTime
            item.durationMinutes = durationMinutes
            item.category = category
            item.locationName = locationName
            item.bookedBy = bookedBy
            item.notes = notes
            item.photoData = photoData
        } else {
            let newItem = ItineraryItem(
                title: title,
                startTime: startTime,
                durationMinutes: durationMinutes,
                category: category,
                locationName: locationName,
                bookedBy: bookedBy,
                notes: notes
            )
            newItem.photoData = photoData
            modelContext.insert(newItem)
            newItem.trip = trip
        }
        dismiss()
    }
}
