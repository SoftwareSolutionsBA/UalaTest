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

        fetchItems()
    }

    func fetchItems() {
        self.loadingData = true
        Task(priority: .low, operation: {
            let result = await apiClient.fetchCities()
            let aux = result.count == 0 ? fetchStoredItems().map({ City(country: $0.country ?? "",
                                                                        name: $0.name ?? "",
                                                                        id: $0.id,
                                                                        coordinates: Coordinates(lon: $0.lon, lat: $0.lat)) }) : []
            await MainActor.run { [weak self] in
                self?.cities = result.count == 0 ? aux : result
                self?.displayedCities = result.count == 0 ? aux : result
                self?.loadingData = false
                result.count > 0 ? self?.storeItems(cities: result) : ()
            }
        })
    }

    func storeItems(cities: [City]) {
        let storedItems = fetchStoredItems()
        var itemsToBeStored = [CityObject]()
        for city in cities {
            if !storedItems.contains(where: { $0.id == city.id }) {
                let object = CityObject(context: context)
                object.id = city.id
                object.name = city.name
                object.country = city.country
                object.lat = city.coordinates.lat
                object.lon = city.coordinates.lon
                object.isFavorite = city.isFavorite
                itemsToBeStored.append(object)
            }
        }
        try? context.save()
    }

    func fetchStoredItems() -> [CityObject] {
        let fetchRequest: NSFetchRequest<CityObject> = CityObject.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            print("Error fetching data: \(error)")
            return []
        }

    }

    func showOnlyFavorites(_ favorites: Bool) {
        if favorites {
            displayedCities = displayedCities.filter({ city in
                city.isFavorite == true
            })
        } else {
            displayedCities = cities
        }
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
