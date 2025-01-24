//
//  PersistenceManager.swift
//  UalaTest
//
//  Created by David Figueroa on 22/01/25.
//

import CoreData

struct PersistenceManager {
    static let shared = PersistenceManager()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "UalaTest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
