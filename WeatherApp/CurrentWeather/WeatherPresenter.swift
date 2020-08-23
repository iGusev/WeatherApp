//
//  WeatherPresenter.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

protocol WeatherPresenterProtocol {
  var currentWeatherModel: CurrentWeatherViewModel? {get set}
  var forecastWeatherModels: [ForecastWeatherViewModel] {get set}
  var error: Error? {get set}

  func loadData()
  func loadData(for city: City)
}

final class WeatherPresenter: WeatherPresenterProtocol {
  var currentWeatherModel: CurrentWeatherViewModel?
  var forecastWeatherModels: [ForecastWeatherViewModel] = []
  var error: Error?
  
  weak var viewController: WeatherViewController?
  
  private let networkService: NetworkServiceProtocol
  private let databaseService: DatabaseServiceProtocol
  private let locationService: LocationServiceProtocol
  private let iconService: IconServiceProtocol
  
  private var currentWeather: CurrentWeather?
  private var forecastWeathers: [ForecastWeather] = []
  private var isLoading: Bool = false
  
  private var dateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM"
    dateFormatter.timeZone = .current
    return dateFormatter
  }
  
  // MARK: - Init
  init(networkService: NetworkServiceProtocol,
       databaseService: DatabaseServiceProtocol,
       locationService: LocationServiceProtocol,
       iconService: IconServiceProtocol) {
    self.networkService = networkService
    self.databaseService = databaseService
    self.locationService = locationService
    self.iconService = iconService
    self.locationService.delegate = self
  }
  
  private func currentWeatherViewModel() {
    guard let weatherModel = self.currentWeather,
          let date = weatherModel.date else {return}
    let formattedDate = self.dateFormatter.string(from: date)
    self.currentWeatherModel = CurrentWeatherViewModel(
      temp: String(format: "%.0f", weatherModel.temp.rounded()),
      feelsLike: String(format: "%.0f", weatherModel.feelsLike.rounded()),
      pressure: String(weatherModel.pressure),
      humidity: String(weatherModel.humidity),
      uvIndex: String(format: "%.0f", weatherModel.uvIndex.rounded()),
      windSpeed: String(weatherModel.windSpeed),
      date: formattedDate,
      weatherDescription: weatherModel.weatherDescription ?? "",
      weatherIconURL: weatherModel.weatherIcon ?? "",
      weatherIcon: nil)
  }
  
  private func forecastWeatherViewModels() {
    for weather in self.forecastWeathers {
      guard let date = weather.date else {return}
      let formattedDate = self.dateFormatter.string(from: date)
      let forecastWeatherModel = ForecastWeatherViewModel(
        tempDay: String(format: "%.0f", weather.tempDay.rounded()),
        tempNight: String(format: "%.0f", weather.tempNight.rounded()),
        date: formattedDate,
        weatherIconURL: weather.weatherIcon ?? "",
        weatherIcon: nil)
      self.forecastWeatherModels.append(forecastWeatherModel)
    }
   }
  
  func loadData() {
    DispatchQueue.main.async {
      self.locationService.requestLocation()
      self.isLoading = true
    }
  }
  
  func loadData(for city: City) {
    guard !self.isLoading else {return}
    self.loadDataFor(latitude: city.latitude,
                     longitude: city.longitude) {
      self.currentWeatherViewModel()
      self.forecastWeatherViewModels()
      self.loadIcons()
      DispatchQueue.main.async {
         self.viewController?.updateView()
      }
      self.isLoading = false
    }
  }
  
  private func loadDataFor(latitude: Double,
                           longitude: Double,
                           completion: @escaping (() -> Void)) {
    self.networkService.getWeather(latitude: latitude, longitude: longitude)
    { [weak self] result in
      switch result {
      case .success(let json):
        guard let weather: [String : Any] = json,
              let forecasts: [[String : Any]] = weather["daily"] as? [[String : Any]]
          else {
            self?.error = FetchingError.responseNotValid
            return
          }
        
        guard let coreDataStack = self?.databaseService as? CoreDataStack else {return}
        let privateContext = coreDataStack.makePrivateContext()
        let mainContext = coreDataStack.mainContext
        
        privateContext.perform {
          self?.databaseService.deleteOldWeatherData()
          DispatchQueue.global().async {
            for item in forecasts {
              guard let forecastWeather = ForecastWeather(json: item, in: privateContext)
                else {return}
              self?.forecastWeathers.append(forecastWeather)
            }
            self?.currentWeather = CurrentWeather(json: weather, in: privateContext)
            
            DispatchQueue.main.async {
              guard privateContext.hasChanges else {return}
              do {
                try privateContext.save()
                 mainContext.performAndWait {
                  do {
                    try mainContext.save()
                  } catch {
                  let nserror = error as NSError
                  fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                  }
                }
                completion()
              } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
              }
            }
          }
        }
        
      case .failure(let error):
        self?.error = error
      }
    }
  }
  
  private func loadIcons() {
    guard let currentWeatherModel = self.currentWeatherModel else {return}
    
    let iconQueue = DispatchQueue(label: "iconQueue",
                                  qos: .userInitiated,
                                  attributes: .concurrent)
    let dispatchGroup: DispatchGroup = DispatchGroup()
    
    iconQueue.async() { [weak self] in
      dispatchGroup.enter()
      self?.iconService.icon(byUrl: currentWeatherModel.weatherIconURL) { [weak self] icon, error in
        if let error = error {
          self?.error = error
        } else if let icon = icon {
          self?.currentWeatherModel?.weatherIcon = icon
          dispatchGroup.leave()
        }
      }
      guard let forecastWeatherModels = self?.forecastWeatherModels else {return}
    
    for (index, forecastModel) in forecastWeatherModels.enumerated() {
      dispatchGroup.enter()
      self?.iconService.icon(byUrl: forecastModel.weatherIconURL) { [weak self] icon, error in
        if let error = error {
          self?.error = error
        } else if let icon = icon {
          self?.forecastWeatherModels[index].weatherIcon = icon
          
        }
          dispatchGroup.leave()
      }
    }
    dispatchGroup.notify(queue: .main) {
      self?.viewController?.updateView()
    }
    
    }
   
  }
}


extension WeatherPresenter: LocationDelegate {
  func didReceiveLocation() {
    guard !self.isLoading else {return}
    if let location = self.locationService.location {
      self.loadDataFor(latitude: location.coordinate.latitude,
                       longitude: location.coordinate.longitude) {
        self.currentWeatherViewModel()
        self.forecastWeatherViewModels()
        self.loadIcons()
        DispatchQueue.main.async {
           self.viewController?.updateView()
        }
        self.isLoading = false
      }
    } else {
      print(LocationError.cannotGetCurrentLocation.localizedDescription)
      self.isLoading = false
    }
  }
}
