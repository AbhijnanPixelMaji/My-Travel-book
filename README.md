# Wayfarer

A personal travel command center for iOS: plan the trip, carry every document, and stay safe anywhere — even offline.

Built with SwiftUI + SwiftData, iOS 18.5+, no third-party dependencies.

## Open and run

1. Open `Wayfarer.xcodeproj` in Xcode.
2. Pick an iPhone simulator (or your device) and press Run.

On first launch the app seeds one sample trip ("Kyoto spring") so every screen has content to explore. Delete it whenever you like.

## Features

| Tab | What it does |
|---|---|
| Trips | Trip list with cover photos, countdowns, and status. Each trip has four sections: Itinerary (day-by-day timeline), Places (saved spots with photos and must-see stars), People (companions with call buttons), Plans (Plan A/B/C contingency manager with triggers and one-tap switching). The Memories album also lives here — photos with short stories, rendered like a travel journal, filterable by trip. |
| Explore | MapKit map with one-tap nearby search: food, cafés, ATM, pharmacy, hospital, police. Distance and directions per result. |
| Wallet | Tickets, vouchers, passport and visa scans, grouped by trip, with expiry warnings ("Expires in 84 d"). Everything is stored locally, so it works offline. |
| Safety | Hold-to-activate SOS, country-specific emergency numbers (offline directory), trusted local contacts with call buttons, and quick "find my embassy / hospital / police" map searches. |
| Profile | Traveler name, home country, and safety/storage preferences. |

## Code structure

```
Wayfarer/
├── WayfarerApp.swift            App entry point
├── App/
│   └── RootTabView.swift        Five-tab shell, seeds sample data
├── Core/
│   ├── Models/                  SwiftData @Model classes, one per file
│   │   ├── Trip.swift           Root model; owns everything below via cascade
│   │   ├── ItineraryItem.swift  A stop on the timeline (time, category, photo)
│   │   ├── Place.swift          A saved place (category, must-see, photo)
│   │   ├── Companion.swift      A travel companion
│   │   ├── TravelDocument.swift Ticket/voucher/passport with expiry logic
│   │   ├── ContingencyPlan.swift Plan B/C with trigger + steps
│   │   ├── TravelMemory.swift   A photo + short story for the album
│   │   └── EmergencyContact.swift Trusted local contact (global, not per trip)
│   └── Support/
│       ├── AppModelContainer.swift  Shared + preview model containers
│       ├── SampleData.swift         First-launch seed data
│       ├── LocationService.swift    CLLocationManager wrapper
│       ├── PhotoPickerButton.swift  Reusable photo-picking form row
│       └── ViewStyles.swift         Card style, tag chips, avatars
└── Features/                    One folder per feature; view + editor pairs
    ├── Trips/       TripsListView, TripCardView, TripDetailView, TripEditorView
    ├── Itinerary/   ItinerarySectionView, ItineraryItemEditorView
    ├── Places/      PlacesSectionView, PlaceEditorView
    ├── People/      PeopleSectionView, CompanionEditorView
    ├── Plans/       PlansSectionView, ContingencyPlanEditorView
    ├── Memories/    MemoriesAlbumView, MemoryDetailView, MemoryEditorView
    ├── Wallet/      WalletView, DocumentEditorView
    ├── Safety/      SafetyView, SOSButton, EmergencyDirectory, EmergencyContactEditorView
    ├── Explore/     ExploreMapView
    └── Profile/     ProfileView
```

Conventions:
- Editors follow one pattern everywhere: pass `nil` to create, pass a model to edit; `@State` copies are applied on Save.
- Views read models directly with `@Query` / `@Bindable`; there is no separate view-model layer because SwiftData already provides observable models.
- All enums used in models are `Codable` raw-value enums with `label` and `systemImage`, so pickers and rows render themselves.

## Roadmap (not yet implemented)

- Apple Watch companion (SOS from the wrist, next-event complication)
- Live location sharing with companions during SOS
- Flight-status triggers that suggest switching to Plan B automatically
- Document scanning with VisionKit and Face ID locking for passport scans
