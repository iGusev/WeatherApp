//
//  ForecastWeather+CoreDataClass.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ForecastWeather)
public final class ForecastWeather: NSManagedObject {
  
  convenience init?(json: [String : Any], in context: NSManagedObjectContext) {
    guard let entity = NSEntityDescription.entity(
      forEntityName: String(describing: ForecastWeather.self),
      in: context) else {return nil}
    self.init(entity: entity, insertInto: context)
    
    guard let timeInterval = json["dt"] as? TimeInterval,
              let temperature = json["temp"] as? [String : Any],
              let weather = json["weather"] as? [[String : Any]] else {return}
    self.date = Date(timeIntervalSince1970: timeInterval)
    self.tempDay = temperature["day"] as? Double ?? 0
    self.tempNight = temperature["night"] as? Double ?? 0
    self.weatherIcon = weather[0]["icon"] as? String ?? ""
    
  }
  
}
