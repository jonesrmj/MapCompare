//
//  Trip+CoreDataProperties.swift
//  MapCompare
//
//  Created by Ryan Jones on 8/29/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//
//

import Foundation
import CoreData


extension Trip {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
    return NSFetchRequest<Trip>(entityName: "Trip")
  }
  
  @NSManaged public var originTitle: String?
  @NSManaged public var originLat: Double
  @NSManaged public var originLong: Double
  @NSManaged public var destinationTitle: String?
  @NSManaged public var destinationLat: Double
  @NSManaged public var destinationLong: Double
  @NSManaged public var tripStart: Date?
  @NSManaged public var tripEnd: Date?
  @NSManaged public var appleEstimatedSeconds: Double
  @NSManaged public var googleEstimatedSeconds: Double
  @NSManaged public var hereEstimatedSeconds: Double
  @NSManaged public var bingEstimatedSeconds: Double
}
