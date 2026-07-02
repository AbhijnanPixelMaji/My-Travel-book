//
//  MemoryDetailView.swift
//  Wayfarer
//

import SwiftUI
import UIKit

/// Full-page view of one memory — the photo with its story, set in serif like a travel journal.
struct MemoryDetailView: View {
    @Bindable var memory: TravelMemory
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let data = memory.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(memory.title)
                        .font(.title2)
                        .fontWeight(.medium)
                        .fontDesign(.serif)

                    HStack(spacing: 12) {
                        Label(memory.dateText, systemImage: "calendar")
                        if !memory.locationName.isEmpty {
                            Label(memory.locationName, systemImage: "mappin.and.ellipse")
                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                    if let trip = memory.trip {
                        TagChip(text: trip.name, systemImage: "suitcase.fill")
                    }

                    if !memory.story.isEmpty {
                        Text(memory.story)
                            .font(.body)
                            .fontDesign(.serif)
                            .lineSpacing(5)
                            .padding(.top, 4)
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle(memory.dateText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { isEditing = true }
            }
        }
        .sheet(isPresented: $isEditing) {
            MemoryEditorView(memory: memory)
        }
    }
}
