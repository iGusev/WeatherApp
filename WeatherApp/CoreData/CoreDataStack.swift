//
//  CoreDataStack.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
  
  func fetchObjects<T>(with type: T.Type) -> [T]? {
    let request: NSFetchRequest<NSFetchRequestResult>
    let entityName = String(describing: T.self)
    request = NSFetchRequest(entityName: entityName)

    let fetchedResult = try? request.execute() as? [T]
//    let result = (fetchedResult?[0])! as! CurrentWeather
//    print(result.feelsLike)
    return fetchedResult
  }
}

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
  
  func fetchObjects<T>(with type: T.Type, completion: @escaping (([T]) -> Void)) {
    let context = self.makePrivateContext()
    context.perform {
      let results = context.fetchObjects(with: T.self)
//    }
    
//    for result in results! {
//      let weather = result as? CurrentWeather
//      print(weather?.feelsLike)
//    }
    guard let unwrapped = results else {return}
//    print(unwrapped[0])
//    let weather = unwrapped[0] as? CurrentWeather
//    print(weather?.feelsLike)
    completion(unwrapped)
  }
//    guard let managedObject = T.self as? NSManagedObject.Type else {return nil}
//    let request = managedObject.fetchRequest()
////    let type = managedObject
////    let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: String(describing: T.self))
////    let request: NSFetchRequest<managedObject.Type> = NSFetchRequest(entityName: String(describing: T.self))
//    print(request)
//    let results = try? self.makePrivateContext().fetch(request) as? [T]
//    for result in results! {
//      let weather = result as? CurrentWeather
//      print(weather?.feelsLike)
//    }
//    return results
  }

}
