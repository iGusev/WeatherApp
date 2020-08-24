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

  func loadCities()
  
  func refreshCitiesList()
  
  func searchCities(with query: String)
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  func tableView(_ tableView: UITableView,
                 reuseIdentifier: String,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)

}

final class CitiesPresenter: CitiesPresenterProtocol {
  
  private let router: Router
  
  private let networkService: NetworkServiceProtocol
  private let databaseService: DatabaseServiceProtocol
  private var fetchResultsController: NSFetchedResultsController<City>?
  
  private var search: DispatchWorkItem = DispatchWorkItem(block: {})
  private var isLoading: Bool = false
  
  weak var viewController: CitiesTableViewController?
  
  // MARK: - Init
  init(router: Router,
       networkService: NetworkServiceProtocol,
       databaseService: DatabaseServiceProtocol) {
    self.networkService = networkService
    self.databaseService = databaseService
    self.router = router
  }
  
  //MARK: - Public methods
  /// Загрузка городов из базы данных, при отсутствии - из сети
  public func loadCities() {
    
    self.performFetch() {
      guard self.fetchResultsController?.fetchedObjects == nil ||
            self.fetchResultsController?.fetchedObjects!.count == 0 else {return}
      
      self.loadCitiesFromNetwork {
        self.viewController?.showActivityIndicator(false)
        self.viewController?.showDownloadAlert(true)
        self.performFetch()
        self.isLoading = false
      }
    }
  }
  
  /// Обновление списка городов
  public func refreshCitiesList() {
    self.loadCitiesFromNetwork {
      self.performFetch()
      self.isLoading = false
    }
  }
  
  /// Поиск по городам
  /// - Parameter query: запрос
  public func searchCities(with query: String) {
    self.search.cancel()
    self.search = DispatchWorkItem() {
      self.performFetch(with: query)
    }
    DispatchQueue.global().asyncAfter(wallDeadline: .now() + 0.5,
                                      execute: self.search)
  }
  
  //MARK: - Data load from network
  private func loadCitiesFromNetwork(completion: @escaping (() -> Void)) {
    guard !self.isLoading else {return}
    self.isLoading = true
    self.networkService.getCities { result in
      
      switch result {
      case .success(let json):
        
        guard let cities: [[String : Any]] = json else {
          self.viewController?.showAlert(error: FetchingError.responseNotValid)
          self.viewController?.showActivityIndicator(false)
          self.viewController?.showDownloadAlert(false)
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
                    print("Changes saved to CoreData")
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
        self.viewController?.showAlert(error: error)
        self.viewController?.showActivityIndicator(false)
        self.viewController?.showDownloadAlert(false)
        self.isLoading = false
      }
    }
  }
  
  //MARK: - Data load from database
  private func performFetch(with query: String? = nil,
                            completion: (() -> Void)? = nil) {
    DispatchQueue.global().async {
      guard let coreDataStack = self.databaseService as? CoreDataStack else {return}
      
      let privateContext = coreDataStack.makePrivateContext()
      
      let fetchRequest = NSFetchRequest<City>(entityName: String(describing: City.self))
      fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
      fetchRequest.predicate = NSPredicate(format: "name != %@", "-")
      
      if let query = query, query.count > 0 {
        fetchRequest.predicate = NSPredicate(format: "name contains[cd] %@", query)
      }
      
      let fetchController = NSFetchedResultsController(
        fetchRequest: fetchRequest,
        managedObjectContext: privateContext,
        sectionNameKeyPath: nil,
        cacheName: nil)
      self.fetchResultsController = fetchController
      
      do {
        DispatchQueue.main.async {
          self.viewController?.showDownloadAlert(false)
          self.viewController?.showActivityIndicator(true)
        }
        
        try fetchController.performFetch()
        let animated = (fetchController.fetchedObjects!.count == 0 && query == nil)
        
        DispatchQueue.main.async {
          self.viewController?.reloadData(animated: animated)
        }
        
        if let completion = completion {
          completion()
        }
        
      } catch {
        self.viewController?.showAlert(error: error)
        self.viewController?.showActivityIndicator(false)
        self.viewController?.showDownloadAlert(false)
        self.isLoading = false
      }
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
  
  // MARK: - Table view delegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.isSelected = false
    guard let city = self.fetchResultsController?.object(at: indexPath) else {return}
    self.router.returnToWeatherForecast(from: self.viewController,
                                        for: city)
  }
}
