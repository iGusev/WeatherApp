//
//  CurrentWeather+CoreDataProperties.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//
//

import Foundation
import CoreData


extension CurrentWeather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentWeather> {
        return NSFetchRequest<CurrentWeather>(entityName: "CurrentWeather")
    }

    @NSManaged public var temp: Double
    @NSManaged public var feelsLike: Double
    @NSManaged public var pressure: Int16
    @NSManaged public var humidity: Int16
    @NSManaged public var uvindex: Double
    @NSManaged public var windSpeed: Double
    @NSManaged public var date: Date?
    @NSManaged public var weatherDescription: String?
    @NSManaged public var weatherIcon: String?

}
