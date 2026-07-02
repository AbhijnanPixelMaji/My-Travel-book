//
//  WalletView.swift
//  Wayfarer
//

import SwiftUI
import SwiftData
import UIKit

/// All travel documents across trips: tickets, vouchers, passports, visas.
struct WalletView: View {
    @Query(sort: \TravelDocument.title) private var documents: [TravelDocument]
    @Environment(\.modelContext) private var modelContext
    @State private var isAddingDocument = false
    @State private var editingDocument: TravelDocument?

    private var expiringDocuments: [TravelDocument] {
        documents.filter(\.isExpiringSoon)
    }

    /// Documents grouped by trip name, unassigned ones last.
    private var groupedByTrip: [(tripName: String, documents: [TravelDocument])] {
        let groups = Dictionary(grouping: documents) { $0.trip?.name ?? "Unassigned" }
        return groups
            .map { (tripName: $0.key, documents: $0.value) }
            .sorted {
                if $0.tripName == "Unassigned" { return false }
                if $1.tripName == "Unassigned" { return true }
                return $0.tripName < $1.tripName
            }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    WayfarerPageHeader(
                        eyebrow: "Secure vault",
                        title: "Wallet",
                        subtitle: "Every travel document ready when the gate, hotel, or border asks.",
                        systemImage: "wallet.pass.fill",
                        tint: WayfarerTheme.ocean,
                        accent: WayfarerTheme.reef,
                        trailingText: "\(documents.count) docs"
                    )

                    walletHero

                    walletReadinessPanel

                    if !expiringDocuments.isEmpty {
                        documentSection("Needs attention", documents: expiringDocuments, tint: .orange)
                    }

                    ForEach(groupedByTrip, id: \.tripName) { group in
                        documentSection(group.tripName, documents: group.documents, tint: WayfarerTheme.ocean)
                    }

                    if documents.isEmpty {
                        ContentUnavailableView(
                            "Your wallet is empty",
                            systemImage: "wallet.pass",
                            description: Text("Keep tickets, vouchers, and passport scans here - available offline.")
                        )
                        .padding(.top, 40)
                    }
                }
                .padding()
            }
            .background(WayfarerTheme.pageBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingDocument = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .accessibilityLabel("Add document")
                }
            }
            .sheet(isPresented: $isAddingDocument) {
                DocumentEditorView()
            }
            .sheet(item: $editingDocument) { document in
                DocumentEditorView(document: document)
            }
        }
    }

    private var walletHero: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Travel wallet")
                        .font(.caption)
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .foregroundStyle(.white.opacity(0.72))
                    Text("Every ticket, pass, and proof ready before the gate.")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(3)
                }
                Spacer()
                AnimatedLogoMark(size: 52, cornerRadius: 15)
            }

            HStack(spacing: 10) {
                WayfarerMetricTile(value: "\(documents.count)", label: "Saved", systemImage: "doc.text.fill", tint: WayfarerTheme.ocean)
                WayfarerMetricTile(value: "\(expiringDocuments.count)", label: "Alerts", systemImage: "exclamationmark.triangle.fill", tint: .orange)
                WayfarerMetricTile(value: "\(groupedByTrip.count)", label: "Trips", systemImage: "suitcase.rolling.fill", tint: WayfarerTheme.lavender)
            }
        }
        .padding(18)
        .background {
            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    colors: [WayfarerTheme.ink, WayfarerTheme.ocean, WayfarerTheme.reef],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                AmbientTravelMotion(tint: .white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .shadow(color: WayfarerTheme.ocean.opacity(0.22), radius: 18, x: 0, y: 12)
    }

    private var walletReadinessPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            JourneyProgressRing(
                progress: walletProgress,
                title: "Document readiness",
                subtitle: walletProgress >= 0.8 ? "Your travel wallet looks prepared." : "Add key documents before the next trip.",
                tint: WayfarerTheme.ocean
            )

            MicroPromptCard(
                title: expiringDocuments.isEmpty ? "Keep the habit light" : "Review expiring documents",
                subtitle: expiringDocuments.isEmpty ? "One ticket or passport scan now saves stress later." : "\(expiringDocuments.count) item\(expiringDocuments.count == 1 ? "" : "s") need attention.",
                systemImage: expiringDocuments.isEmpty ? "plus.viewfinder" : "exclamationmark.triangle.fill",
                tint: expiringDocuments.isEmpty ? WayfarerTheme.reef : .orange
            )
        }
        .padding(16)
        .elevatedCard(cornerRadius: 20)
    }

    private var walletProgress: Double {
        guard !documents.isEmpty else { return 0.08 }
        let safeDocuments = documents.filter { !$0.isExpiringSoon }.count
        return max(Double(safeDocuments) / Double(documents.count), 0.16)
    }

    private func documentSection(_ title: String, documents: [TravelDocument], tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(WayfarerTheme.ink)
                Spacer()
                Text("\(documents.count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(tint.opacity(0.14), in: Capsule())
                    .foregroundStyle(tint)
            }

            VStack(spacing: 10) {
                ForEach(documents) { document in
                    documentRow(document)
                }
            }
        }
        .padding(16)
        .elevatedCard(cornerRadius: 20)
    }

    private func documentRow(_ document: TravelDocument) -> some View {
        Button {
            editingDocument = document
        } label: {
            HStack(spacing: 12) {
                Image(systemName: document.kind.systemImage)
                    .font(.headline)
                    .frame(width: 44, height: 44)
                    .background(kindTint(document.kind).opacity(0.13), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(kindTint(document.kind))

                VStack(alignment: .leading, spacing: 2) {
                    Text(document.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text(document.reference.isEmpty ? document.kind.label : document.reference)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let expiry = document.expiryText {
                    Text(expiry)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(expiryTint(document).opacity(0.15), in: Capsule())
                        .foregroundStyle(expiryTint(document))
                } else if let data = document.scanData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(10)
            .background(Color(.tertiarySystemGroupedBackground).opacity(0.85), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                modelContext.delete(document)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func expiryTint(_ document: TravelDocument) -> Color {
        guard let days = document.daysUntilExpiry else { return .secondary }
        if days < 0 { return .red }
        if days <= 30 { return .orange }
        return .secondary
    }

    private func kindTint(_ kind: DocumentKind) -> Color {
        switch kind {
        case .flight: WayfarerTheme.ocean
        case .hotel: WayfarerTheme.lavender
        case .rail: .green
        case .ticket: WayfarerTheme.sunrise
        case .insurance: .red
        case .passport: WayfarerTheme.reef
        case .visa: .indigo
        case .other: .secondary
        }
    }
}

#Preview {
    WalletView()
        .modelContainer(AppModelContainer.preview)
}
