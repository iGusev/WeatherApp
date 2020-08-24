//
//  CoreDataStack.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {

  /// Возвращает объекты из базы CoreData
  /// - Parameter type: тип возвращаемого объекта
  /// - Returns: массив объектов заданного типа
  func fetchObjects<T>(with type: T.Type) -> [T]? {
    let request: NSFetchRequest<NSFetchRequestResult>
    let entityName = String(describing: T.self)
    request = NSFetchRequest(entityName: entityName)

    let fetchedResult = try? request.execute() as? [T]
    return fetchedResult
  }
  
}

protocol DatabaseServiceProtocol {
  func save()
  func deleteOldWeatherData()
  func deleteCitiesData()
  func fetchObjects<T>(with type: T.Type, completion: @escaping (([T]) -> Void))
}

final class CoreDataStack: DatabaseServiceProtocol {
  
  public lazy var mainContext: NSManagedObjectContext = {
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    context.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
    return context
  }()
  
  lazy private var persistentContainer: NSPersistentContainer = {
   let container = NSPersistentContainer(name: "WeatherApp")
   container.loadPersistentStores(completionHandler: { (storeDescription, error) in
       if let error = error as NSError? {
           fatalError("Unresolved error \(error), \(error.userInfo)")
       }
   })
   return container
  }()
  
  /// Возвращает приватный контекст для CoreData
  /// - Returns: контекст
  public func makePrivateContext() -> NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.parent = self.mainContext
    return context
  }
  
  // MARK: - Core Data Saving support
  /// Сохраняет изменения в главном контексте в базу
  public func save() {
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
  
  /// Удаляет ранее загруженные данные погоды
  public func deleteOldWeatherData() {
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
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  /// Удаляет ранее загруженные данные городов
  public func deleteCitiesData() {
    let privateContext = self.makePrivateContext()
    privateContext.perform {
      let citiesRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
        entityName: String(describing: City.self))
      let deleteRequest: NSBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: citiesRequest)
      do {
        try privateContext.execute(deleteRequest)
        try privateContext.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  /// Возвращает объекты из базы CoreData
  /// - Parameters:
  ///   - type: тип возвращаемого объекта
  ///   - completion: блок с массивом объектов из базы
  public func fetchObjects<T>(with type: T.Type, completion: @escaping (([T]) -> Void)) {
    let context = self.makePrivateContext()
    context.perform {
      let results = context.fetchObjects(with: T.self)
      guard let unwrapped = results else {return}
      completion(unwrapped)
    }
  }

}
