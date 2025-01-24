//
//  HomeViewModel.swift
//  UalaTest
//
//  Created by David Figueroa on 23/01/25.
//

import Foundation
import CoreData

class HomeViewModel: ObservableObject {
    let context: NSManagedObjectContext

    init() {
        self.context = PersistenceManager.shared.container.newBackgroundContext()
    }

    func fetchItems() {

    }

    func storeItems() {

    }
}
