//
//  City.swift
//  UalaTest
//
//  Created by David Figueroa on 23/01/25.
//
//

import Foundation
import CoreLocation

struct City: Codable, Hashable {
    let country: String
    let name: String
    let id: Int32
    let coordinates: Coordinates
    var isFavorite: Bool = false

    enum CodingKeys: String, CodingKey {
        case country
        case name
        case id = "_id"
        case coordinates = "coord"
    }
}

struct Coordinates: Codable, Hashable {
    let lon: Double
    let lat: Double
}


struct Location: Identifiable {
    var id = UUID()
    var coordinate: CLLocationCoordinate2D
}
