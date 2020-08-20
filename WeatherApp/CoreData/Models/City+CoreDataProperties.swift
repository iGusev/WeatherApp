//
//  City+CoreDataProperties.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 20.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//
//

import Foundation
import CoreData


extension City {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<City> {
        return NSFetchRequest<City>(entityName: "City")
    }

    @NSManaged public var country: String?
    @NSManaged public var id: Int64
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var state: String?

}
