//
//  CoreDataStack.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import CoreData

final class CoreDataStack: DatabaseServiceProtocol {
  
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
  
  public var context: NSManagedObjectContext {
    return self.persistentContainer.viewContext
  }

 // MARK: - Core Data Saving support

 func save() {
  if self.context.hasChanges {
     do {
      try self.context.save()
      print("Changes in context saved")
     } catch {
      self.context.rollback()
      let nserror = error as NSError
      fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
     }
   }
 }
  
}
