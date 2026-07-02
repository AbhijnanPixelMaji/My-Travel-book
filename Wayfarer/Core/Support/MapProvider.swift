//
//  MapProvider.swift
//  Wayfarer
//

import Foundation
import MapKit
import SwiftUI

enum MapProvider: String, CaseIterable, Identifiable {
    case apple
    case google

    var id: String { rawValue }

    var label: String {
        switch self {
        case .apple: "Apple Maps"
        case .google: "Google Maps"
        }
    }

    var systemImage: String {
        switch self {
        case .apple: "map.fill"
        case .google: "globe"
        }
    }
}

enum MapLauncher {
    static func directionsURL(for item: MKMapItem, provider: MapProvider) -> URL? {
        switch provider {
        case .apple:
            let destination = item.placemark.coordinate
            return URL(string: "https://maps.apple.com/?daddr=\(destination.latitude),\(destination.longitude)")
        case .google:
            let destination = item.placemark.coordinate
            return URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(destination.latitude),\(destination.longitude)")
        }
    }

    static func searchURL(query: String, provider: MapProvider) -> URL? {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        switch provider {
        case .apple:
            return URL(string: "https://maps.apple.com/?q=\(encoded)")
        case .google:
            return URL(string: "https://www.google.com/maps/search/?api=1&query=\(encoded)")
        }
    }
}
