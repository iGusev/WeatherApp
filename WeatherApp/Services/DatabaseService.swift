//
//  DatabaseService.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation

protocol DatabaseServiceProtocol {
  func save()
  func deleteOldWeatherData()
  func deleteCitiesData()
  func fetchRequest<T>() -> [T]?
}

