//
//  TripEditorView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData
import PhotosUI

/// Creates a new trip or edits an existing one, depending on what is passed in.
struct TripEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let trip: Trip?
    @State private var name: String
    @State private var destination: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var status: TripStatus
    @State private var notes: String
    @State private var coverPhotoData: Data?
    @State private var photoSelection: PhotosPickerItem?

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(trip: Trip? = nil) {
        self.trip = trip
        _name = State(initialValue: trip?.name ?? "")
        _destination = State(initialValue: trip?.destination ?? "")
        _startDate = State(initialValue: trip?.startDate ?? .now)
        _endDate = State(initialValue: trip?.endDate ?? Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now)
        _status = State(initialValue: trip?.status ?? .planned)
        _notes = State(initialValue: trip?.notes ?? "")
        _coverPhotoData = State(initialValue: trip?.coverPhotoData)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    heroCard
                    essentialsCard
                    statusCard
                    datesCard
                    photoCard
                    notesCard
                    saveButton
                }
                .padding()
            }
            .background(WayfarerTheme.pageBackground.ignoresSafeArea())
            .navigationTitle(trip == nil ? "New trip" : "Edit trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Cancel")
                }
            }
            .onChange(of: photoSelection) { _, newValue in
                guard let newValue else { return }
                Task {
                    if let data = try? await newValue.loadTransferable(type: Data.self) {
                        coverPhotoData = data
                    }
                }
            }
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            coverPreview
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .overlay {
                    LinearGradient(
                        colors: [.black.opacity(0.05), .black.opacity(0.68)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    TagChip(text: trip == nil ? "Create journey" : "Update journey", systemImage: "sparkles", tint: WayfarerTheme.sunrise)
                        .background(.ultraThinMaterial, in: Capsule())
                    Spacer()
                    AnimatedLogoMark(size: 44, cornerRadius: 12)
                }

                Text(name.isEmpty ? "Where are we going?" : name)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(destination.isEmpty ? "Add a destination to make it real." : destination)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.82))
                    .lineLimit(2)
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .shadow(color: WayfarerTheme.ocean.opacity(0.18), radius: 18, x: 0, y: 12)
    }

    @ViewBuilder
    private var coverPreview: some View {
        if let coverPhotoData, let uiImage = UIImage(data: coverPhotoData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            ZStack(alignment: .topTrailing) {
                WayfarerTheme.primaryGradient
                AmbientTravelMotion(tint: .white)
                VStack(spacing: 10) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 42))
                    Text(destination.isEmpty ? "Trip cover" : destination)
                        .font(.headline)
                        .lineLimit(1)
                }
                .foregroundStyle(.white.opacity(0.75))
            }
        }
    }

    private var essentialsCard: some View {
        editorCard(title: "Essentials", icon: "pencil.and.list.clipboard", tint: WayfarerTheme.ocean) {
            VStack(spacing: 12) {
                editorField(title: "Trip name", text: $name, icon: "suitcase.rolling.fill", tint: WayfarerTheme.ocean)
                editorField(title: "Destination", text: $destination, icon: "mappin.and.ellipse", tint: WayfarerTheme.reef)
            }
        }
    }

    private var statusCard: some View {
        editorCard(title: "Stage", icon: "flag.checkered", tint: WayfarerTheme.sunrise) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(TripStatus.allCases) { option in
                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                            status = option
                        }
                    } label: {
                        statusTile(option)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func statusTile(_ option: TripStatus) -> some View {
        let isSelected = status == option
        let tint = WayfarerTheme.color(for: option)

        return HStack(spacing: 10) {
            Image(systemName: option.systemImage)
                .font(.headline)
                .frame(width: 36, height: 36)
                .background(isSelected ? tint : tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 11))
                .foregroundStyle(isSelected ? .white : tint)
            Text(option.label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? tint : .primary)
            Spacer()
        }
        .padding(10)
        .background(
            isSelected ? tint.opacity(0.14) : Color(.tertiarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 15)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? tint.opacity(0.45) : .clear, lineWidth: 1.5)
        )
    }

    private var datesCard: some View {
        editorCard(title: "Dates", icon: "calendar.badge.clock", tint: WayfarerTheme.lavender) {
            VStack(spacing: 12) {
                DatePicker("Starts", selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding(12)
                    .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                DatePicker("Ends", selection: $endDate, in: startDate..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding(12)
                    .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private var photoCard: some View {
        editorCard(title: "Cover photo", icon: "photo.on.rectangle.angled", tint: WayfarerTheme.reef) {
            VStack(alignment: .leading, spacing: 12) {
                if let coverPhotoData, let uiImage = UIImage(data: coverPhotoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                HStack {
                    PhotosPicker(selection: $photoSelection, matching: .images) {
                        Label(coverPhotoData == nil ? "Add cover photo" : "Change photo", systemImage: "photo.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(WayfarerTheme.reef.opacity(0.14), in: Capsule())
                            .foregroundStyle(WayfarerTheme.reef)
                    }

                    Spacer()

                    if coverPhotoData != nil {
                        Button(role: .destructive) {
                            coverPhotoData = nil
                            photoSelection = nil
                        } label: {
                            Label("Remove", systemImage: "trash")
                                .font(.footnote)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
    }

    private var notesCard: some View {
        editorCard(title: "Notes", icon: "text.quote", tint: WayfarerTheme.sunrise) {
            TextField("Anything to remember", text: $notes, axis: .vertical)
                .font(.subheadline)
                .lineLimit(4...7)
                .padding(12)
                .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private var saveButton: some View {
        Button(action: save) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text(trip == nil ? "Create trip" : "Save changes")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(canSave ? WayfarerTheme.primaryGradient : LinearGradient(colors: [.gray.opacity(0.4), .gray.opacity(0.25)], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 18))
            .foregroundStyle(.white)
            .shadow(color: WayfarerTheme.ocean.opacity(canSave ? 0.24 : 0), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .disabled(!canSave)
    }

    private func editorCard<Content: View>(
        title: String,
        icon: String,
        tint: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundStyle(WayfarerTheme.ink)
                Spacer()
            }
            content()
        }
        .padding(16)
        .elevatedCard(cornerRadius: 20)
    }

    private func editorField(title: String, text: Binding<String>, icon: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .frame(width: 42, height: 42)
                .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(tint)
            TextField(title, text: text)
                .font(.subheadline)
                .fontWeight(.semibold)
                .textInputAutocapitalization(.words)
        }
        .padding(12)
        .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private func save() {
        if let trip {
            trip.name = name
            trip.destination = destination
            trip.startDate = startDate
            trip.endDate = endDate
            trip.status = status
            trip.notes = notes
            trip.coverPhotoData = coverPhotoData
        } else {
            let newTrip = Trip(
                name: name,
                destination: destination,
                startDate: startDate,
                endDate: endDate,
                status: status,
                notes: notes
            )
            newTrip.coverPhotoData = coverPhotoData
            modelContext.insert(newTrip)
        }
        dismiss()
    }
}

#Preview {
    TripEditorView()
        .modelContainer(AppModelContainer.preview)
}
