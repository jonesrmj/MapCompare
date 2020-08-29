//
//  Trip+CoreDataClass.swift
//  MapCompare
//
//  Created by Ryan Jones on 8/29/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Trip)
public class Trip: NSManagedObject {
  var title: String { return originTitle ?? "None" + " -> " + (destinationTitle ?? "None") }
  var tripActualSeconds: Double { return tripEnd != nil && tripStart != nil ? tripEnd!.timeIntervalSince(tripStart!) : 0 }
  var tripActualTime: String { return TripModel.displayTimeFromSeconds(label: "", seconds: tripActualSeconds) }
  var appleDeltaSeconds: Double { return appleEstimatedSeconds - tripActualSeconds }
  var googleDeltaSeconds: Double { return googleEstimatedSeconds - tripActualSeconds }
  var hereDeltaSeconds: Double { return hereEstimatedSeconds - tripActualSeconds }
  var bingDeltaSeconds: Double { return bingEstimatedSeconds - tripActualSeconds }
  
  static func displayTimeFromSeconds(label: String, seconds: Double) -> String {
    let (h,m,s) = (Int(seconds) / 3600, (Int(seconds) % 3600) / 60, (Int(seconds) % 3600) % 60)
    let prefix = !label.isEmpty ? "\(label): " : ""
    return "\(prefix)\(h) hrs \(m) min \(s) sec"
  }
}
