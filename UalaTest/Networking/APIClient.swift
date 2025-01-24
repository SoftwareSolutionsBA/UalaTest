//
//  APIClient.swift
//  UalaTest
//
//  Created by David Figueroa on 23/01/25.
//

import Foundation

protocol APIClientProtocol {
    func fetchCities() async -> [City]
}

struct APIClient: APIClientProtocol {
    let session: URLSession

    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }

    func fetchCities() async -> [City] {
        let service: CitiesGistService = .getCities
        guard let fullURL = service.fullURL else { return [] }

        if let result = try? await session.data(from: fullURL) {
            let jsonDecoder = JSONDecoder()
            let cities = try? jsonDecoder.decode([City].self, from: result.0)
            return cities ?? []
        }

        return []
    }
}
