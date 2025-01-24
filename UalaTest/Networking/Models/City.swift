//
//  City.swift
//  UalaTest
//
//  Created by David Figueroa on 23/01/25.
//
//

import Foundation

struct City: Codable, Hashable {
    let country: String
    let name: String
    let id: Int32
//    let lon: Double
//    let lat: Double

    enum CodingKeys: String, CodingKey {
        case country
        case name
        case id = "_id"
//        case lon
//        case lat
    }
}
