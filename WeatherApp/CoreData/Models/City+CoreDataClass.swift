//
//  City+CoreDataClass.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 18.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//
//

import Foundation
import CoreData

@objc(City)
public class City: NSManagedObject {
  
  convenience init?(json: [String : Any], in context: NSManagedObjectContext) {
    guard let entity = NSEntityDescription.entity(
      forEntityName: String(describing: City.self),
      in: context) else {return nil}
    self.init(entity: entity, insertInto: context)
    
    guard let objectId = json["id"] as? Int64,
          let coordinates = json["coord"] as? [String : Any] else { return}
    
    self.id = objectId
    self.name = json["name"] as? String ?? ""
    self.state = json["state"] as? String ?? ""
    self.country = json["country"] as? String ?? ""
    self.latitude = coordinates["lat"] as? Double ?? 0
    self.longitude = coordinates["lon"] as? Double ?? 0

  }
}
