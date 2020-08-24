//
//  Builder.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 24.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

/// Выполняет функцию первичной настройки модулей приложения
public class Builder {
  
  static let databaseService: DatabaseServiceProtocol = CoreDataStack()
  
  static private let networkService: NetworkServiceProtocol = NetworkService()
  static private let locationService: LocationServiceProtocol = LocationService()
  static private var iconService: IconServiceProtocol {
    let iconService = IconService(networkService: self.networkService)
    return iconService
  }
  
  /// Первичная настройка модулей приложения
  static func buildWeathers() -> UIViewController {
    let router: Router = Router()
    let weatherPresenter: WeatherPresenterProtocol = WeatherPresenter(
      router: router,
      networkService: self.networkService,
      databaseService: self.databaseService,
      locationService: self.locationService,
      iconService: self.iconService)
    let weatherVC = WeatherViewController(presenter: weatherPresenter)
    weatherPresenter.viewController = weatherVC
    router.presenter = weatherPresenter
    let rootVC = UINavigationController(rootViewController: weatherVC)
    rootVC.navigationBar.isHidden = true
    return rootVC
  }
  
  static func buildCities(with router: Router) -> UIViewController {
    let citiesPresenter = CitiesPresenter(router: router,
                                          networkService: self.networkService,
                                          databaseService: self.databaseService)
    let citiesVC = CitiesTableViewController(presenter: citiesPresenter)
    citiesPresenter.viewController = citiesVC
    citiesVC.modalPresentationStyle = .overCurrentContext
    return citiesVC
  }
  
}
