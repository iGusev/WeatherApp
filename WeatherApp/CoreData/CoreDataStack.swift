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
  
  public lazy var mainContext: NSManagedObjectContext = {
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    context.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
    return context
  }()
  
  public func makePrivateContext() -> NSManagedObjectContext {
      let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
      context.parent = self.mainContext
      return context
  }

 // MARK: - Core Data Saving support

 func save() {
  self.mainContext.perform {
    if self.mainContext.hasChanges {
       do {
        try self.mainContext.save()
        self.mainContext.reset()
        print("Changes in context saved")
       } catch {
        self.mainContext.rollback()
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
       }
     }
    }
 }
  
  func deleteOldWeatherData() {
    let privateContext = self.makePrivateContext()
    privateContext.perform {
      let currentRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
        entityName: String(describing: CurrentWeather.self))
      let deleteCurrentRequest: NSBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: currentRequest)
      let forecastRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
        entityName: String(describing: ForecastWeather.self))
      let deleteForecastRequest: NSBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: forecastRequest)
      do {
        try privateContext.execute(deleteCurrentRequest)
        try privateContext.execute(deleteForecastRequest)
        try privateContext.save()
//        do {
//          try self.mainContext.save()
//        } catch {
//          let nserror = error as NSError
//          fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  func deleteCitiesData() {
    let privateContext = self.makePrivateContext()
    privateContext.perform {
      let citiesRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
        entityName: String(describing: City.self))
      let deleteRequest: NSBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: citiesRequest)
      do {
        try privateContext.execute(deleteRequest)
        try privateContext.save()
//        do {
//          try self.mainContext.save()
//        } catch {
//          let nserror = error as NSError
//          fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  func fetchRequest<T>() -> [T]? {
    guard let managedObject = T.self as? NSManagedObject.Type else {return nil}
    let request = managedObject.fetchRequest()
    let results = try? self.makePrivateContext().fetch(request) as? [T]
    return results
  }
  
}
