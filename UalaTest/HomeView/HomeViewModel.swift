//
//  HomeViewModel.swift
//  UalaTest
//
//  Created by David Figueroa on 23/01/25.
//

import Foundation
import CoreData
import Combine

class HomeViewModel: ObservableObject {
    let context: NSManagedObjectContext
    let apiClient: APIClientProtocol

    @Published var loadingData = false
    @Published var notFound = false
    @Published var isFilteringItems = false
    @Published var searchText: String = "" {
        didSet {
            guard searchText.count >= 2 else { return }
            isFilteringItems = true
        }
    }
    @Published var cities: [City] = []
    @Published var displayedCities: [City] = []

    private var cancellables = Set<AnyCancellable>()

    init(apiClient: APIClientProtocol = APIClient(),
         cities: [City] = []) {

        self.context = PersistenceManager.shared.container.newBackgroundContext()
        self.apiClient = apiClient
        self.cities = cities

        $searchText.debounce(for: .seconds(0.3), scheduler: RunLoop.main).sink { [weak self] searchText in
            self?.filterItems(searchText)
            self?.isFilteringItems = false
        }.store(in: &cancellables)
    }

    func fetchItems() {
        self.loadingData = true
        Task(priority: .low, operation: {
            let result = await apiClient.fetchCities()
            await MainActor.run { [weak self] in
                self?.cities = result
                self?.displayedCities = result
                self?.loadingData = false
            }
        })
    }

    func storeItems() {

    }

    private func filterItems(_ searchText: String) {
        guard searchText.count >= 1 else {
            displayedCities = cities
            notFound = false
            return
        }

        displayedCities = cities.filter({ city in
            city.name.lowercased().contains(searchText.lowercased())
        })
        notFound = displayedCities.count == 0
    }
}
