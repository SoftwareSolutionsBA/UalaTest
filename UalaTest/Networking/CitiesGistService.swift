//
//  CitiesGistService.swift
//  UalaTest
//
//  Created by David Figueroa on 23/01/25.
//

import Foundation

enum CitiesGistService {
    case getCities
}

extension CitiesGistService {

    var API_KEY: String {
        return ""
    }

    var baseURL: String {
        switch self {
        case .getCities:
            return "https://gist.githubusercontent.com"
        }
    }

    var path: String {
        switch self {
        case .getCities:
            return "/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json"
        }
    }

    var fullURL: URL? {
        return URL(string: baseURL + path)
    }

    var method: String {
        switch self {
        case .getCities:
            return "GET"
        }
    }

    var parameters: [String : Any] {
        switch self {
        case .getCities:
            return [:]
        }
    }

    var headers: [String : String]? {
        return nil
    }
}
