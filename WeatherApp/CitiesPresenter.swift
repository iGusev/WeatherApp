//
//  CitiesPresenter.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 19.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation

protocol CitiesPresenterProtocol {
//  var forecastWeatherModels: [ForecastWeatherViewModel]? {get set}
////  var error: Error? {get set}

  func loadCities()

}

final class CitiesPresenter: CitiesPresenterProtocol {
  
  private let networkService: NetworkServiceProtocol
  private let databaseService: DatabaseServiceProtocol
  
  // MARK: - Init
  init(networkService: NetworkServiceProtocol,
       databaseService: DatabaseServiceProtocol) {
    self.networkService = networkService
    self.databaseService = databaseService
  }
  
  func loadCities() {
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
        
        privateContext.performAndWait {
          self.databaseService.deleteCitiesData()
          DispatchQueue.global().async {
            for city in cities {
              _ = City(json: city, in: privateContext)
            }

            DispatchQueue.main.async {
              guard privateContext.hasChanges else {return}
              do {
                try privateContext.save()
                mainContext.perform {
                  do {
                    try mainContext.save()
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
        print(error)
      }
    }
  }
  
}
