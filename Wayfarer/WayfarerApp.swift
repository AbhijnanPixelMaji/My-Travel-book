//
//  WayfarerApp.swift
//  Wayfarer
//

import SwiftUI
import SwiftData

@main
struct WayfarerApp: App {
    var body: some Scene {
        WindowGroup {
            AuthGateView()
        }
        .modelContainer(AppModelContainer.shared)
    }
}
