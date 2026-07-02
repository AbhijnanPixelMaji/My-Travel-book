//
//  PhotoPickerButton.swift
//  Wayfarer
//

import SwiftUI
import PhotosUI

/// Reusable "pick a photo" form row that writes the raw image data into a binding.
struct PhotoPickerButton: View {
    let title: String
    @Binding var imageData: Data?
    @State private var selection: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            HStack {
                PhotosPicker(selection: $selection, matching: .images) {
                    Label(imageData == nil ? title : "Change photo", systemImage: "photo")
                }
                if imageData != nil {
                    Spacer()
                    Button("Remove", role: .destructive) {
                        imageData = nil
                        selection = nil
                    }
                }
            }
        }
        .onChange(of: selection) { _, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }
}
