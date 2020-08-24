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
  func fetchObjects<T>(with type: T.Type, completion: @escaping (([T]) -> Void))
}

enum DatabaseError: Error {
  case invalidInitialization
}

extension DatabaseError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .invalidInitialization:
      return "Не удалось инициализировать базу данных"
    }
  }
}

