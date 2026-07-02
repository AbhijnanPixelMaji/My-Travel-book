//
//  ExploreMapView.swift
//  Wayfarer
//

import SwiftUI
import MapKit
import SwiftData

enum NearbyCategory: String, CaseIterable, Identifiable {
    case food = "Food"
    case cafe = "Cafés"
    case atm = "ATM"
    case pharmacy = "Pharmacy"
    case hospital = "Hospital"
    case police = "Police"

    var id: String { rawValue }

    var query: String {
        switch self {
        case .food: "restaurant"
        case .cafe: "cafe"
        case .atm: "atm"
        case .pharmacy: "pharmacy"
        case .hospital: "hospital"
        case .police: "police station"
        }
    }

    var systemImage: String {
        switch self {
        case .food: "fork.knife"
        case .cafe: "cup.and.saucer.fill"
        case .atm: "banknote"
        case .pharmacy: "pills.fill"
        case .hospital: "cross.fill"
        case .police: "shield.fill"
        }
    }
}

/// Map tab: find what you need around you, one tap per category.
struct ExploreMapView: View {
    @AppStorage("preferredMapProvider") private var preferredMapProvider = MapProvider.apple.rawValue
    @AppStorage("hasDroppedNextDestination") private var hasDroppedNextDestination = false
    @AppStorage("nextDestinationLatitude") private var nextDestinationLatitude = 35.0116
    @AppStorage("nextDestinationLongitude") private var nextDestinationLongitude = 135.7681
    @Query(sort: \Trip.startDate) private var trips: [Trip]
    @Environment(\.openURL) private var openURL
    @State private var position: MapCameraPosition = .region(.wayfarerDemoRegion)
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var results: [MKMapItem] = []
    @State private var selectedCategory: NearbyCategory?
    @State private var isSearching = false
    @State private var isDroppingDestination = false
    @State private var locationService = LocationService()

    var body: some View {
        NavigationStack {
            MapReader { proxy in
                Map(position: $position) {
                    UserAnnotation()

                    ForEach(tripMarkers) { marker in
                        Annotation(marker.trip.name, coordinate: marker.coordinate) {
                            TripMapMarkerView(trip: marker.trip)
                        }
                    }

                    if hasDroppedNextDestination {
                        Annotation("Next destination", coordinate: droppedCoordinate) {
                            NextDestinationMarker()
                        }
                    }

                    ForEach(results, id: \.self) { item in
                        Marker(item: item)
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .onMapCameraChange { context in
                    visibleRegion = context.region
                }
                .gesture(
                    SpatialTapGesture()
                        .onEnded { event in
                            guard isDroppingDestination else { return }
                            if let coordinate = proxy.convert(event.location, from: .local) {
                                dropNextDestination(at: coordinate)
                            }
                        }
                )
                .safeAreaInset(edge: .top) {
                    VStack(spacing: 8) {
                        WayfarerPageHeader(
                            eyebrow: "Live map",
                            title: "Explore",
                            subtitle: "Drop next destinations and see every saved trip on the world.",
                            systemImage: "map.fill",
                            tint: WayfarerTheme.reef,
                            accent: WayfarerTheme.sunrise,
                            trailingText: "\(tripMarkers.count) pins"
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        .background(.ultraThinMaterial)

                        providerControl
                        destinationDropBar
                        categoryBar
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    bottomBar
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                locationService.requestPermission()
                if !trips.isEmpty {
                    position = .region(.wayfarerDemoRegion)
                }
            }
        }
    }

    private var droppedCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: nextDestinationLatitude, longitude: nextDestinationLongitude)
    }

    private var tripMarkers: [TripMapMarker] {
        trips.compactMap { trip in
            guard let coordinate = trip.demoMapCoordinate else { return nil }
            return TripMapMarker(trip: trip, coordinate: coordinate)
        }
    }

    private var selectedProvider: MapProvider {
        MapProvider(rawValue: preferredMapProvider) ?? .apple
    }

    private var providerControl: some View {
        Picker("Map app", selection: $preferredMapProvider) {
            ForEach(MapProvider.allCases) { provider in
                Label(provider.label, systemImage: provider.systemImage)
                    .tag(provider.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.top, 8)
        .background(.thinMaterial)
    }

    private var destinationDropBar: some View {
        HStack(spacing: 10) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    isDroppingDestination.toggle()
                }
            } label: {
                Label(isDroppingDestination ? "Tap map to drop" : "Drop next destination", systemImage: isDroppingDestination ? "hand.tap.fill" : "mappin.and.ellipse")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(
                        isDroppingDestination ? AnyShapeStyle(WayfarerTheme.sunrise) : AnyShapeStyle(WayfarerTheme.primaryGradient),
                        in: Capsule()
                    )
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    position = .region(.wayfarerDemoRegion)
                }
            } label: {
                Image(systemName: "map.fill")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .frame(width: 36, height: 36)
                    .background(Color(.secondarySystemBackground), in: Circle())
                    .foregroundStyle(WayfarerTheme.ocean)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Show all trips")

            if hasDroppedNextDestination {
                Button {
                    hasDroppedNextDestination = false
                    isDroppingDestination = false
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .frame(width: 36, height: 36)
                        .background(.red.opacity(0.12), in: Circle())
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove next destination marker")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
    }

    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(NearbyCategory.allCases) { category in
                    Button {
                        select(category)
                    } label: {
                        Label(category.rawValue, systemImage: category.systemImage)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                selectedCategory == category ? Color.accentColor : Color(.secondarySystemBackground),
                                in: Capsule()
                            )
                            .foregroundStyle(selectedCategory == category ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
                if isSearching {
                    ProgressView()
                        .padding(.leading, 4)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.thinMaterial)
    }

    private var resultsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(results, id: \.self) { item in
                    resultCard(item)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(.thinMaterial)
    }

    @ViewBuilder
    private var bottomBar: some View {
        VStack(spacing: 10) {
            if hasDroppedNextDestination {
                droppedDestinationCard
            }
            if !results.isEmpty {
                resultsBar
            }
        }
    }

    private var droppedDestinationCard: some View {
        HStack(spacing: 12) {
            NextDestinationMarker()
                .frame(width: 46, height: 46)
            VStack(alignment: .leading, spacing: 2) {
                Text("Next destination")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(String(format: "%.4f, %.4f", droppedCoordinate.latitude, droppedCoordinate.longitude))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                openDroppedDestination()
            } label: {
                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.headline)
                    .frame(width: 42, height: 42)
                    .background(WayfarerTheme.ocean.opacity(0.13), in: Circle())
                    .foregroundStyle(WayfarerTheme.ocean)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open directions to next destination")
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.55), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    private func resultCard(_ item: MKMapItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name ?? "Unknown")
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            HStack(spacing: 8) {
                if let distance = distanceText(to: item) {
                    Text(distance)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Button {
                    openDirections(to: item)
                } label: {
                    Label(selectedProvider.label, systemImage: selectedProvider.systemImage)
                        .labelStyle(.titleAndIcon)
                }
                .font(.caption)
                .fontWeight(.medium)
            }
        }
        .padding(10)
        .frame(width: 180, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func select(_ category: NearbyCategory) {
        if selectedCategory == category {
            selectedCategory = nil
            results = []
            return
        }
        selectedCategory = category
        Task { await search(for: category) }
    }

    private func search(for category: NearbyCategory) async {
        isSearching = true
        defer { isSearching = false }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = category.query
        if let visibleRegion {
            request.region = visibleRegion
        }
        let search = MKLocalSearch(request: request)
        let response = try? await search.start()
        results = response?.mapItems ?? []
    }

    private func distanceText(to item: MKMapItem) -> String? {
        guard
            let userLocation = locationService.lastLocation,
            let itemLocation = item.placemark.location
        else { return nil }
        let meters = userLocation.distance(from: itemLocation)
        if meters < 1000 {
            return "\(Int(meters)) m"
        }
        return String(format: "%.1f km", meters / 1000)
    }

    private func openDirections(to item: MKMapItem) {
        if let url = MapLauncher.directionsURL(for: item, provider: selectedProvider) {
            openURL(url)
        }
    }

    private func dropNextDestination(at coordinate: CLLocationCoordinate2D) {
        nextDestinationLatitude = coordinate.latitude
        nextDestinationLongitude = coordinate.longitude
        hasDroppedNextDestination = true
        isDroppingDestination = false
    }

    private func openDroppedDestination() {
        let item = MKMapItem(placemark: MKPlacemark(coordinate: droppedCoordinate))
        item.name = "Next destination"
        openDirections(to: item)
    }
}

#Preview {
    ExploreMapView()
        .modelContainer(AppModelContainer.preview)
}

private struct TripMapMarker: Identifiable {
    let trip: Trip
    let coordinate: CLLocationCoordinate2D

    var id: PersistentIdentifier { trip.id }
}

private struct TripMapMarkerView: View {
    let trip: Trip

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                Circle()
                    .fill(WayfarerTheme.color(for: trip.status))
                    .frame(width: 38, height: 38)
                    .shadow(color: WayfarerTheme.color(for: trip.status).opacity(0.35), radius: 10, x: 0, y: 5)
                Image(systemName: trip.status == .completed ? "checkmark.seal.fill" : "suitcase.rolling.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            Text(trip.destination.components(separatedBy: ",").first ?? trip.name)
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(.regularMaterial, in: Capsule())
        }
    }
}

private struct NextDestinationMarker: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [WayfarerTheme.sunrise, WayfarerTheme.lavender],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Image(systemName: "flag.checkered.circle.fill")
                .font(.title2)
                .foregroundStyle(.white)
        }
        .frame(width: 42, height: 42)
        .shadow(color: WayfarerTheme.sunrise.opacity(0.35), radius: 12, x: 0, y: 6)
    }
}

private extension MKCoordinateRegion {
    static let wayfarerDemoRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.5, longitude: 55.0),
        span: MKCoordinateSpan(latitudeDelta: 86, longitudeDelta: 140)
    )
}

private extension Trip {
    var demoMapCoordinate: CLLocationCoordinate2D? {
        let text = "\(name) \(destination)".lowercased()
        if text.contains("kyoto") || text.contains("japan") {
            return CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681)
        }
        if text.contains("bali") || text.contains("indonesia") {
            return CLLocationCoordinate2D(latitude: -8.3405, longitude: 115.0920)
        }
        if text.contains("paris") || text.contains("france") {
            return CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        }
        if text.contains("iceland") || text.contains("reykjavik") {
            return CLLocationCoordinate2D(latitude: 64.1466, longitude: -21.9426)
        }
        if text.contains("dubai") || text.contains("uae") {
            return CLLocationCoordinate2D(latitude: 25.2048, longitude: 55.2708)
        }
        return nil
    }
}
