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

    init(apiClient: APIClientProtocol = APIClient()) {
        self.context = PersistenceManager.shared.container.newBackgroundContext()
        self.apiClient = apiClient
    }

    func fetchItems() {
        self.loadingData = true
        Task(priority: .utility, operation: {
            let cities = await apiClient.fetchCities()
            await MainActor.run { [weak self] in
                self?.loadingData = false
            }
        })
    }

    func storeItems() {

    }
}
