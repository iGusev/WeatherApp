//
//  Extensions.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 24.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    if lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude {
      return true
    } else {
      return false
    }
  }
}

extension NSDate {
  static func > (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate > rhs.timeIntervalSinceReferenceDate
  }

  static func < (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate < rhs.timeIntervalSinceReferenceDate
  }
}



