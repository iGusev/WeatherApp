//
//  CitiesPresenter.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 19.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit
import CoreData

protocol CitiesPresenterProtocol {
  var error: Error? {get set}

  func loadCities()
  
  func searchCities(with query: String)
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  
  func tableView(_ tableView: UITableView,
                 reuseIdentifier: String,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell

}

final class CitiesPresenter: CitiesPresenterProtocol {
  
  private let networkService: NetworkServiceProtocol
  private let databaseService: DatabaseServiceProtocol
  private var fetchResultsController: NSFetchedResultsController<City>?
  
  var error: Error?
  
  weak var viewController: CitiesTableViewController?
  
  // MARK: - Init
  init(networkService: NetworkServiceProtocol,
       databaseService: DatabaseServiceProtocol) {
    self.networkService = networkService
    self.databaseService = databaseService
  }
  
  func loadCities() {
    self.performFetch()
    guard let fetchController = self.fetchResultsController,
          fetchController.fetchedObjects == nil ||
          fetchController.fetchedObjects!.count == 0 else {return}
    self.loadCitiesFromNetwork {
      self.performFetch()
    }
  }
  
  func searchCities(with query: String) {
    guard query.count > 0 else {
      self.performFetch()
      return
    }
    self.performFetch(with: query)
  }
  
  private func loadCitiesFromNetwork(completion: @escaping (() -> Void)) {
    self.networkService.getCities { result in
      switch result {
      case .success(let json):
        guard let cities: [[String : Any]] = json else {
          print(FetchingError.responseNotValid)
          return
        }
        
        guard let coreDataStack = self.databaseService as? CoreDataStack else {return}
        let privateContext = coreDataStack.makePrivateContext()
        let mainContext = coreDataStack.mainContext
        
        privateContext.perform {
          self.databaseService.deleteCitiesData()
          DispatchQueue.global().async {
            for city in cities {
              _ = City(json: city, in: privateContext)
            }

            DispatchQueue.main.async {
              guard privateContext.hasChanges else {return}
              do {
                try privateContext.save()
                mainContext.performAndWait {
                  do {
                    try mainContext.save()
                    completion()
                  } catch {
                  let nserror = error as NSError
                  fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                  }
                }
              } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
              }
            }
          }
        }
        
      case .failure(let error):
        self.error = error
      }
    }
  }
  
  private func performFetch(with query: String? = nil) {
    guard let coreDataStack = self.databaseService as? CoreDataStack else {return}
    let privateContext = coreDataStack.makePrivateContext()
    
    let fetchRequest = NSFetchRequest<City>(entityName: String(describing: City.self))
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    fetchRequest.predicate = NSPredicate(format: "name != %@", "-")
    
    if let query = query {
      fetchRequest.predicate = NSPredicate(format: "name contains[cd] %@", query)
    }
    
    let fetchController = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: privateContext,
      sectionNameKeyPath: nil,
      cacheName: nil)
    self.fetchResultsController = fetchController
    
    do {
      try fetchController.performFetch()
      DispatchQueue.main.async {
        self.viewController?.reloadData()
      }
    } catch {
      self.error = error
    }
  }
  
  // MARK: - Table view data source
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let fetchController = self.fetchResultsController,
          let sections = fetchController.sections else {return 0}
    return sections[section].numberOfObjects
  }

  func tableView(_ tableView: UITableView,
                 reuseIdentifier: String,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    guard let object = self.fetchResultsController?.object(at: indexPath) else {
         fatalError("Attempt to configure cell without a managed object")
     }
    
    cell.textLabel?.text = object.name
    cell.detailTextLabel?.text = object.country
    return cell
  }
}
