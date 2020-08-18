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
//  var forecastWeatherModels
//  var error: Error? {get set}

  func loadDataFromNetwork()
  func loadDataFromDatabase()
}

class WeatherPresenter: Presenter {
  var currentWeatherModel: CurrentWeatherViewModel?
  
  func loadDataFromNetwork() {
    
  }
  
  func loadDataFromDatabase() {
    
  }
  
  
}
