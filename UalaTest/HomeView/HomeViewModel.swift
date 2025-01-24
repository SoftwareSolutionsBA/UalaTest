//
//  HomeViewModel.swift
//  UalaTest
//
//  Created by David Figueroa on 23/01/25.
//

import Foundation
import CoreData

//@MainActor
class HomeViewModel: ObservableObject {
    let context: NSManagedObjectContext
    let apiClient: APIClientProtocol

    @Published var loadingData = false
    @Published var searchText: String = ""
    @Published var cities: [City] = []

    init(apiClient: APIClientProtocol = APIClient(),
         cities: [City] = []) {

        self.context = PersistenceManager.shared.container.newBackgroundContext()
        self.apiClient = apiClient
        self.cities = cities
    }

    func fetchItems() {
        self.loadingData = true
        Task(priority: .low, operation: {
            let result = await apiClient.fetchCities()
            await MainActor.run { [weak self] in
                self?.cities = result
                self?.loadingData = false
            }
        })
    }

    func storeItems() {

    }
}
