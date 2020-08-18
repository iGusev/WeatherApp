//
//  LocationService.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceProtocol: NSObject {
  var location: CLLocation? {get set}
  func requestLocation()
}

final class LocationService: NSObject, LocationServiceProtocol {
  /// Переменная для хранения текущего местоположения
  public var location: CLLocation? = nil
  
  override init() {
    super.init()
    self.configureLocationManager()
  }
  
  private let locationManager = CLLocationManager()
  
  /// Запрос местоположения
  public func requestLocation() {
    self.locationManager.requestLocation()
  }
  
  private func configureLocationManager() {
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    self.locationManager.startMonitoringSignificantLocationChanges()
    self.locationManager.requestWhenInUseAuthorization()
  }
}

extension LocationService: CLLocationManagerDelegate {
  /// Выполняет сдвиг карты и добавление точки в маршрут при изменении местоположения
  ///
  /// - Parameters:
  ///   - manager: CLLocation менеджер
  ///   - locations: список местоположений в хронологическом порядке
  public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.location = locations.last
  }
  
  /// Выводит описание ошибки при возникновении ошибки определения местоположения
  ///
  /// - Parameters:
  ///   - manager: CLLocation менеджер
  ///   - error: ошибка
  public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}
