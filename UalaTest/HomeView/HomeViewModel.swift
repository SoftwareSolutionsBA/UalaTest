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
            result.count > 0 ? storeItems(cities: result) : ()

            let storedObjects = fetchStoredItems().map({ City(country: $0.country ?? "",
                                                              name: $0.name ?? "",
                                                              id: $0.id,
                                                              coordinates: Coordinates(lon: $0.lon, lat: $0.lat),
                                                              isFavorite: $0.isFavorite) })

            await MainActor.run { [weak self] in
                self?.cities = storedObjects.count > 0 ? storedObjects : result
                self?.displayedCities = storedObjects.count > 0 ? storedObjects : result
                self?.loadingData = false
            }
        })
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

    // MARK: PERSISTENCE CORE DATA
    func storeItems(cities: [City]) {
        Task(priority: .utility, operation: {
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
        })
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

    func toggleFavorite(_ id: Int32) {
        if let index = displayedCities.firstIndex(where: { $0.id == id }) {
            displayedCities[index].isFavorite.toggle()
        }
        if let index = cities.firstIndex(where: { $0.id == id }) {
            cities[index].isFavorite.toggle()
        }

        Task(priority: .low, operation: {
            let fetchRequest: NSFetchRequest<CityObject> = CityObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
            let result = try context.fetch(fetchRequest).first
            result?.isFavorite.toggle()
            try? result?.managedObjectContext?.save()
        })
    }
}
