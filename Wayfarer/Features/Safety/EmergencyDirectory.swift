//
//  EmergencyDirectory.swift
//  Wayfarer
//

import Foundation

struct EmergencyNumbers: Identifiable {
    let country: String
    let police: String
    let ambulance: String
    let fire: String

    var id: String { country }
}

/// Country-specific emergency numbers, available offline.
enum EmergencyDirectory {
    static let all: [EmergencyNumbers] = [
        EmergencyNumbers(country: "Australia", police: "000", ambulance: "000", fire: "000"),
        EmergencyNumbers(country: "France", police: "17", ambulance: "15", fire: "18"),
        EmergencyNumbers(country: "Germany", police: "110", ambulance: "112", fire: "112"),
        EmergencyNumbers(country: "India", police: "112", ambulance: "108", fire: "101"),
        EmergencyNumbers(country: "Indonesia", police: "110", ambulance: "118", fire: "113"),
        EmergencyNumbers(country: "Italy", police: "112", ambulance: "118", fire: "115"),
        EmergencyNumbers(country: "Japan", police: "110", ambulance: "119", fire: "119"),
        EmergencyNumbers(country: "Singapore", police: "999", ambulance: "995", fire: "995"),
        EmergencyNumbers(country: "Spain", police: "112", ambulance: "112", fire: "112"),
        EmergencyNumbers(country: "Thailand", police: "191", ambulance: "1669", fire: "199"),
        EmergencyNumbers(country: "United Arab Emirates", police: "999", ambulance: "998", fire: "997"),
        EmergencyNumbers(country: "United Kingdom", police: "999", ambulance: "999", fire: "999"),
        EmergencyNumbers(country: "United States", police: "911", ambulance: "911", fire: "911"),
    ]

    static func numbers(for country: String) -> EmergencyNumbers {
        all.first { $0.country == country }
            ?? EmergencyNumbers(country: country, police: "112", ambulance: "112", fire: "112")
    }
}
