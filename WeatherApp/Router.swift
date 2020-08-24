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
  
  /// Возвращение на экран погоды для выбранного города
  /// - Parameters:
  ///   - viewController: view controller текущего экрана
  ///   - city: выбранный город
  public func returnToWeatherForecast(from viewController: CitiesTableViewController?,
                                      for city: City) {
    guard let presenter = self.presenter else {return}
    presenter.loadData(for: city)
    viewController?.navigationController?.popViewController(animated: true)
  }
  
  /// Переход на экран выбора города
  /// - Parameters:
  ///   - viewController: view controller текущего экрана
  public func chooseCity(from viewController: WeatherViewController?) {
    let citiesVC = Builder.buildCities(with: self)
    let navigationController = viewController?.navigationController
    navigationController?.navigationBar.isHidden = false
    navigationController?.pushViewController(citiesVC, animated: true)
  }
  
}
