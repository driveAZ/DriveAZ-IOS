//
//  OldCacheManager.swift
//  DriveAZ
//
//  Created by Ben on 6/29/22.
//

import Foundation
import CoreData
import SwiftUI

class OldCacheManager {
    static let sharedInstance = OldCacheManager()

    var storedSafetyMessages: [SafetyMessage] = []
    lazy var persistentContainer: NSPersistentContainer = {
      let container = NSPersistentContainer(name: "SafetyMessages")
      container.loadPersistentStores { _, error in
        if let error = error as NSError? {
          // You should add your own error handling code here.
          fatalError("Unresolved error \(error), \(error.userInfo)")
        }
      }
      return container
    }()

    private init() {
        let fetchRequest: NSFetchRequest<SafetyMessage> = SafetyMessage.fetchRequest()
        let context = persistentContainer.viewContext
        do {
            let objects = try context.fetch(fetchRequest)
            print("cached objects: \(objects.count)")
        } catch {
            print("error getting cached objects")
        }
        print("")
    }

    func saveContext() {
      do {
        try persistentContainer.viewContext.save()
      } catch {
        print("Error saving managed object context: \(error)")
      }
    }

    func saveSafetyMessage(data: Data) {
        let newSafetyMessage = SafetyMessage(context: persistentContainer.viewContext)
        newSafetyMessage.data = data
        newSafetyMessage.id = UUID()
        saveContext()
    }

    func deleteSafetyMessage(at offsets: IndexSet) {
        offsets.forEach { _ in
//          let safetyMessage = self.safetyMessages[index]
//          self.managedObjectContext.delete(safetyMessage)
        }
        saveContext()
    }
}
