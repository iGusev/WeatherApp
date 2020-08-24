//
//  WeatherPresenter.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

final class DateFormatters {
  static let weatherDate: DateFormatter = {
    let formatter = DateFormatter()
//        formatter.calendar = Calendar(identifier: .iso8601)
    formatter.dateFormat = "dd.MM"
    return formatter
  }()
}

extension NSDate {
  var stringValue: String {
    let formatter = DateFormatters.weatherDate
    return formatter.string(from: self as Date)
  }

  static func > (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate > rhs.timeIntervalSinceReferenceDate
  }

  static func < (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate < rhs.timeIntervalSinceReferenceDate
  }
}


protocol WeatherPresenterProtocol: class {
  var currentWeatherModel: CurrentWeatherViewModel? {get set}
  var forecastWeatherModels: [ForecastWeatherViewModel] {get set}
  var error: Error? {get set}

  func loadData()
  func loadData(for city: City)
  func locationButtonOnTap()
}

final class WeatherPresenter: WeatherPresenterProtocol {
  var currentWeatherModel: CurrentWeatherViewModel?
  var forecastWeatherModels: [ForecastWeatherViewModel] = []
  var error: Error?
  
  weak var viewController: WeatherViewController?
  
  private let router: Router
  
  private let networkService: NetworkServiceProtocol
  private let databaseService: DatabaseServiceProtocol
  private let locationService: LocationServiceProtocol
  private let iconService: IconServiceProtocol
  
  private var isLoading: Bool = false
  private var load: DispatchWorkItem = DispatchWorkItem(block: {})
  
  private var dateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM"
    dateFormatter.timeZone = .current
    return dateFormatter
  }
  
  // MARK: - Init
  init(router: Router,
       networkService: NetworkServiceProtocol,
       databaseService: DatabaseServiceProtocol,
       locationService: LocationServiceProtocol,
       iconService: IconServiceProtocol) {
    self.router = router
    self.networkService = networkService
    self.databaseService = databaseService
    self.locationService = locationService
    self.iconService = iconService
    self.locationService.delegate = self
  }
  
  private func currentWeatherViewModel(for city: String? = nil) {
    self.databaseService.fetchObjects(with: CurrentWeather.self) { results in
      guard results.count > 0,
        let weatherModel = results.first,
        let date = weatherModel.date else {return}
      let formattedDate = self.dateFormatter.string(from: date as Date)
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
          weatherIcon: nil,
          city: city)
      self.loadCurrentWeatherIcon()
      self.viewController?.updateView()
    }
  }
  
  private func forecastWeatherViewModels() {
    self.databaseService.fetchObjects(with: ForecastWeather.self) { results in
      guard results.count > 0 else {return}
      self.forecastWeatherModels = []
      let weathers = results
      let sortedWeathers = weathers.sorted(by: {$0.date! < $1.date!})
      for weather in sortedWeathers {
        guard let date = weather.date else {return}
        let formattedDate = self.dateFormatter.string(from: date as Date)
        let forecastWeatherModel = ForecastWeatherViewModel(
          tempDay: String(format: "%.0f", weather.tempDay.rounded()),
          tempNight: String(format: "%.0f", weather.tempNight.rounded()),
          date: formattedDate,
          weatherIconURL: weather.weatherIcon ?? "",
          weatherIcon: nil)
        self.forecastWeatherModels.append(forecastWeatherModel)
      }
      self.loadForecastWeatherIcons()
      self.viewController?.updateView()
    }
   }
  
  func loadData() {
    DispatchQueue.main.async {
      self.viewController?.showActivityIndicator(true)
      self.locationService.requestLocation()
      self.isLoading = true
    }
  }
  
  func loadData(for city: City) {
    guard !self.isLoading, let cityName = city.name else {return}
    self.viewController?.showActivityIndicator(true)
    self.loadDataFor(
      latitude: city.latitude,
      longitude: city.longitude) {
      self.currentWeatherViewModel(for: cityName)
      self.forecastWeatherViewModels()
      self.isLoading = false
    }
  }
  
  func locationButtonOnTap() {
    guard !self.isLoading else {return}
    let citiesPresenter = CitiesPresenter(router: self.router,
                                          networkService: self.networkService,
                                          databaseService: self.databaseService)
    let citiesVC = CitiesTableViewController(presenter: citiesPresenter)
    citiesPresenter.viewController = citiesVC
    citiesVC.modalPresentationStyle = .overCurrentContext
    let navigationController = self.viewController?.navigationController
    navigationController?.navigationBar.isHidden = false
    navigationController?.pushViewController(citiesVC, animated: true)
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
            self?.viewController?.showAlert(error: FetchingError.responseNotValid) { _ in
              self?.viewController?.showActivityIndicator(false)
              self?.servicesNotAvailable()
            }
            return
          }
        
        guard let coreDataStack = self?.databaseService as? CoreDataStack else {return}
        let privateContext = coreDataStack.makePrivateContext()
        let mainContext = coreDataStack.mainContext
        
        privateContext.perform {
          self?.databaseService.deleteOldWeatherData()
          DispatchQueue.global().async {
            for item in forecasts {
              _ = ForecastWeather(json: item, in: privateContext)
            }
            _ = CurrentWeather(json: weather, in: privateContext)

            guard privateContext.hasChanges else {return}
            do {
              try privateContext.save()
              DispatchQueue.main.async {
               mainContext.performAndWait {
                do {
                  try mainContext.save()
                  print("Changes saved to CoreData")
                } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
              }
              completion()
              }
            } catch {
              let nserror = error as NSError
              fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
          }
        }
        
      case .failure(let error):
        self?.viewController?.showAlert(error: error) { _ in
          self?.viewController?.showActivityIndicator(false)
          self?.servicesNotAvailable()
        }
      }
    }
  }
  
  private func loadCurrentWeatherIcon() {
    guard let currentWeatherModel = self.currentWeatherModel else {return}
    
    let iconQueue = DispatchQueue(label: "iconQueue",
                                  qos: .userInitiated,
                                  attributes: .concurrent)
    let dispatchGroup: DispatchGroup = DispatchGroup()
    
    iconQueue.async() { [weak self] in
      guard let self = self else {return}
      dispatchGroup.enter()
      self.iconService.icon(byUrl: currentWeatherModel.weatherIconURL) { [weak self] icon, error in
        if let error = error {
          self?.viewController?.showAlert(error: error)
        } else if let icon = icon {
          self?.currentWeatherModel?.weatherIcon = icon
          dispatchGroup.leave()
        }
      }

      dispatchGroup.notify(queue: .main) {
        self.viewController?.updateView()
      }
    }
  }
  
  private func loadForecastWeatherIcons() {
    let iconQueue = DispatchQueue(label: "iconQueue",
                                  qos: .userInitiated,
                                  attributes: .concurrent)
    let dispatchGroup: DispatchGroup = DispatchGroup()
    
    iconQueue.async() { [weak self] in
      guard let self = self else {return}
      for (index, forecastModel) in self.forecastWeatherModels.enumerated() {
        dispatchGroup.enter()
        self.iconService.icon(byUrl: forecastModel.weatherIconURL) { [weak self] icon, error in
          if let error = error {
            self?.viewController?.showAlert(error: error)
          } else if let icon = icon {
            self?.forecastWeatherModels[index].weatherIcon = icon
          }
          dispatchGroup.leave()
        }
      }
      
      dispatchGroup.notify(queue: .main) {
        self.viewController?.updateView()
      }
    }
  }
  
  private func servicesNotAvailable() {
    self.databaseService.fetchObjects(with: CurrentWeather.self) { results in
      //Если есть данные в базе
      if results.count > 0 {
        self.currentWeatherViewModel(for: "Сохраненное местоположение")
        self.forecastWeatherViewModels()
      } else {
        //Если в базе нет данных
        let formattedDate = self.dateFormatter.string(from: Date())
        self.viewController?.updateViewWithEmptyData(today: formattedDate)
        self.viewController?.showNoDataAlert()
      }
    }
    self.isLoading = false
  }
}


extension WeatherPresenter: LocationDelegate {
  func didReceiveLocation() {
    self.load.cancel()
    self.load = DispatchWorkItem() {
      if let location = self.locationService.location {
        self.loadDataFor(latitude: location.coordinate.latitude,
                         longitude: location.coordinate.longitude) {
          self.currentWeatherViewModel()
          self.forecastWeatherViewModels()
          self.isLoading = false
        }
      } else {
        self.viewController?.showAlert(error: LocationError.cannotGetCurrentLocation) { _ in
          self.servicesNotAvailable()
        }
      }
    }
    DispatchQueue.global().asyncAfter(wallDeadline: .now() + 0.1,
                                      execute: self.load)
  }
}

//MARK: - CollectionView methods
extension WeatherPresenter {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
  }
}
