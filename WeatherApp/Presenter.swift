//
//  Presenter.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation

protocol Presenter {
  var currentWeatherModel: CurrentWeatherViewModel? {get set}
  var forecastWeatherModels: [ForecastWeatherViewModel]? {get set}
//  var error: Error? {get set}

  func loadData()
}

class WeatherPresenter: Presenter {
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
  }
  
  func loadData() {
    
  }
  
}
