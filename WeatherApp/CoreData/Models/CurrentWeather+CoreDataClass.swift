//
//  CurrentWeather+CoreDataClass.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CurrentWeather)
public class CurrentWeather: NSManagedObject {
  
  convenience init?(json: [String : Any], in context: NSManagedObjectContext) {
    guard let entity = NSEntityDescription.entity(
      forEntityName: String(describing: CurrentWeather.self),
      in: context) else {return nil}
    self.init(entity: entity, insertInto: context)
    
    guard let data = json["current"] as? [String : Any],
          let timeInterval = data["dt"] as? TimeInterval,
          let weather = data["weather"] as? [[String : Any]] else {return}
    self.latitude = json["lat"] as? Double ?? 0
    self.longitude = json["lon"] as? Double ?? 0
    self.date = NSDate(timeIntervalSince1970: timeInterval)
    self.temp = data["temp"] as? Double ?? 0
    self.feelsLike = data["feels_like"] as? Double ?? 0
    self.pressure = data["pressure"] as? Int16 ?? 0
    self.humidity = data["humidity"] as? Int16 ?? 0
    self.uvIndex = data["uvi"] as? Double ?? 0
    self.windSpeed = data["wind_speed"] as? Double ?? 0
    self.weatherIcon = weather[0]["icon"] as? String ?? ""
    self.weatherDescription = weather[0]["description"] as? String ?? ""

  }
}
