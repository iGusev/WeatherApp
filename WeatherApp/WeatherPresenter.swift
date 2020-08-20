//
//  WeatherPresenter.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation

protocol WeatherPresenterProtocol {
  var currentWeatherModel: CurrentWeatherViewModel? {get set}
  var forecastWeatherModels: [ForecastWeatherViewModel]? {get set}
//  var error: Error? {get set}

  func loadData()
  func loadData(for location: String)
}

final class WeatherPresenter: WeatherPresenterProtocol {
  var currentWeatherModel: CurrentWeatherViewModel?
  var forecastWeatherModels: [ForecastWeatherViewModel]?
  
  private let networkService: NetworkServiceProtocol
  private let databaseService: DatabaseServiceProtocol
  private let locationService: LocationServiceProtocol
  
  // MARK: - Init
  init(networkService: NetworkServiceProtocol,
       databaseService: DatabaseServiceProtocol,
       locationService: LocationServiceProtocol) {
    self.networkService = networkService
    self.databaseService = databaseService
    self.locationService = locationService
    self.locationService.delegate = self
  }
  
  func loadData() {
    DispatchQueue.main.async {
      self.locationService.requestLocation()
    }
  }
  
  func loadData(for location: String) {
    
  }
  
  private func loadDataFor(latitude: Double, longitude: Double) {
    self.networkService.getWeather(latitude: latitude, longitude: longitude) { result in
      switch result {
      case .success(let json):
        guard let responseDictionary: [String : Any] = json,
              let forecasts: [[String : Any]] = responseDictionary["daily"] as? [[String : Any]],
              let currentWeather: [String : Any] = responseDictionary["current"] as? [String : Any]
          else {
            print(FetchingError.responseNotValid)
            return
          }
        
        
        guard let coreDataStack = self.databaseService as? CoreDataStack else {return}
        let privateContext = coreDataStack.makePrivateContext()
        let mainContext = coreDataStack.mainContext
        
        privateContext.performAndWait {
          self.databaseService.deleteOldWeatherData()
          DispatchQueue.global().async {
            for item in forecasts {
              _ = ForecastWeather(json: item, in: privateContext)
            }
            _ = CurrentWeather(json: currentWeather, in: privateContext)
            
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


extension WeatherPresenter: LocationDelegate {
  func didReceiveLocation() {
    if let location = self.locationService.location {
      self.loadDataFor(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    } else {
      print(LocationError.cannotGetCurrentLocation.localizedDescription)
    }
  }
}
