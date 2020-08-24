//
//  Router.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 23.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation

class Router {
  
  weak var presenter: WeatherPresenterProtocol?
  
  func returnToWeatherForecast(from viewController: CitiesTableViewController?,
                               for city: City) {
    guard let presenter = self.presenter else {return}
    presenter.loadData(for: city)
    viewController?.navigationController?.popViewController(animated: true)
  }
  
}
