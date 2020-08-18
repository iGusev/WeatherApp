//
//  ForecastWeather+CoreDataProperties.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//
//

import Foundation
import CoreData


extension ForecastWeather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ForecastWeather> {
        return NSFetchRequest<ForecastWeather>(entityName: "ForecastWeather")
    }

    @NSManaged public var date: Date?
    @NSManaged public var tempDay: Double
    @NSManaged public var tempNight: Double
    @NSManaged public var weatherIcon: String?

}
