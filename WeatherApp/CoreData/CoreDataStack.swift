//
//  CoreDataStack.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import CoreData

final class CoreDataStack {
  
// MARK: - Core Data stack

 lazy private var persistentContainer: NSPersistentContainer = {
     let container = NSPersistentContainer(name: "WeatherApp")
     container.loadPersistentStores(completionHandler: { (storeDescription, error) in
         if let error = error as NSError? {
             fatalError("Unresolved error \(error), \(error.userInfo)")
         }
     })
     return container
 }()

 // MARK: - Core Data Saving support

 func saveContext() {
    let context = self.persistentContainer.viewContext
     if context.hasChanges {
         do {
            try context.save()
         } catch {
            context.rollback()
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
         }
     }
 }
  
}
