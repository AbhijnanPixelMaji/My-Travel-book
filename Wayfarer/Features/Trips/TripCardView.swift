//
//  TripCardView.swift
//  Wayfarer
//

import SwiftUI
import UIKit

struct TripCardView: View {
    let trip: Trip

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            cover
                .frame(height: 190)
                .frame(maxWidth: .infinity)
                .overlay {
                    LinearGradient(
                        colors: [.black.opacity(0.04), .black.opacity(0.62)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    TagChip(
                        text: trip.status.label,
                        systemImage: trip.status.systemImage,
                        tint: WayfarerTheme.color(for: trip.status)
                    )
                    .background(.ultraThinMaterial, in: Capsule())
                    Spacer()
                    if let countdown = trip.countdownText {
                        Text(countdown)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.white.opacity(0.9), in: Capsule())
                            .foregroundStyle(WayfarerTheme.ocean)
                    }
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(trip.name)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(trip.destination)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.86))
                        .lineLimit(1)
                }

                HStack(spacing: 12) {
                    Label(trip.dateRangeText, systemImage: "calendar")
                    Label("\(trip.itineraryItems.count) plans", systemImage: "list.bullet.clipboard")
                }
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.78))
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.09), radius: 14, x: 0, y: 8)
    }

    @ViewBuilder
    private var cover: some View {
        if let data = trip.coverPhotoData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                WayfarerTheme.primaryGradient
                VStack(spacing: 10) {
                    Image(systemName: "map.fill")
                        .font(.largeTitle)
                    Text(trip.destination)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white.opacity(0.76))
            }
        }
    }
}
