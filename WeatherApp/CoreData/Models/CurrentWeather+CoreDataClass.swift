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
  
  convenience init?(json: [String : Any],
       service: DatabaseServiceProtocol) {
    guard let coreDataStack = service as? CoreDataStack else {return nil}
    let context = coreDataStack.context
    guard let entity = NSEntityDescription.entity(
      forEntityName: String(describing: CurrentWeather.self),
      in: context) else {return nil}
    self.init(entity: entity, insertInto: context)
    
    guard let timeInterval = json["dt"] as? TimeInterval,
          let weather = json["weather"] as? [[String : Any]] else {return}
    self.date = Date(timeIntervalSince1970: timeInterval)
    self.temp = json["temp"] as? Double ?? 0
    self.feelsLike = json["feels_like"] as? Double ?? 0
    self.pressure = json["pressure"] as? Int16 ?? 0
    self.humidity = json["humidity"] as? Int16 ?? 0
    self.uvIndex = json["uvi"] as? Double ?? 0
    self.windSpeed = json["wind_speed"] as? Double ?? 0
    self.weatherIcon = weather[0]["icon"] as? String ?? ""
    self.weatherDescription = weather[0]["description"] as? String ?? ""
    print(self)
  }
}
