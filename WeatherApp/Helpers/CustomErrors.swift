//
//  CustomErrors.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 24.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation

/// Ошибка загрузки данных из сети
enum FetchingError: Error {
  case responseNotValid
}

extension FetchingError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .responseNotValid:
      return "Ответ сервера не поддерживается"
    }
  }
}

/// Ошибка в геолокации
enum LocationError: Error {
  case cannotGetCurrentLocation
}

extension LocationError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .cannotGetCurrentLocation:
      return "Не удалось получить текущую геопозицию"
    }
  }
}
