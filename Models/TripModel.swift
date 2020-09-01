//
//  TripModel.swift
//  MapCompare
//
//  Created by Ryan Jones on 8/12/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import Foundation

struct TripModel: Identifiable {
  var id = UUID()
  var originTitle: String
  var originLat: Double
  var originLong: Double
  var destinationTitle: String
  var destinationLat: Double
  var destinationLong: Double
  var tripStart: Date?
  var tripEnd: Date?
  var appleEstimatedSeconds: Double
  var googleEstimatedSeconds: Double
  var hereEstimatedSeconds: Double
  var bingEstimatedSeconds: Double
  
  var title: String { return originTitle != "" && destinationTitle != "" ? originTitle + " -> " + destinationTitle : "No Title" }
  var tripActualSeconds: Double { return tripEnd != nil && tripStart != nil ? tripEnd!.timeIntervalSince(tripStart!) : 0 }
  var tripActualTime: String { return TripModel.displayTimeFromSeconds(label: "", seconds: tripActualSeconds) }
  var appleDeltaSeconds: Double { return appleEstimatedSeconds - tripActualSeconds }
  var googleDeltaSeconds: Double { return googleEstimatedSeconds - tripActualSeconds }
  var hereDeltaSeconds: Double { return hereEstimatedSeconds - tripActualSeconds }
  var bingDeltaSeconds: Double { return bingEstimatedSeconds - tripActualSeconds }
  
  init(
    originTitle: String,
    originLat: Double,
    originLong: Double,
    destinationTitle: String,
    destinationLat: Double,
    destinationLong: Double,
    tripStart: Date,
    tripEnd: Date,
    appleEstimatedSeconds: Double,
    googleEstimatedSeconds: Double,
    hereEstimatedSeconds: Double,
    bingEstimatedSeconds: Double ) {
    
    self.originTitle = originTitle
    self.originLat = originLat
    self.originLong = originLong
    self.destinationTitle = destinationTitle
    self.destinationLat = destinationLat
    self.destinationLong = destinationLong
    self.tripStart = tripStart
    self.tripEnd = tripEnd
    self.appleEstimatedSeconds = appleEstimatedSeconds
    self.googleEstimatedSeconds = googleEstimatedSeconds
    self.hereEstimatedSeconds = hereEstimatedSeconds
    self.bingEstimatedSeconds = bingEstimatedSeconds
  }
  
  init() {
    originTitle = ""
    originLat = 0
    originLong = 0
    destinationTitle = ""
    destinationLat = 0
    destinationLong = 0
    tripStart = Date()
    tripEnd = Date()
    appleEstimatedSeconds = 0
    googleEstimatedSeconds = 0
    hereEstimatedSeconds = 0
    bingEstimatedSeconds = 0
  }

  static func displayTimeFromSeconds(label: String, seconds: Double) -> String {
    let (h,m,s) = (Int(seconds) / 3600, (Int(seconds) % 3600) / 60, (Int(seconds) % 3600) % 60)
    let prefix = !label.isEmpty ? "\(label): " : ""
    return "\(prefix)\(h) hrs \(m) min \(s) sec"
  }
}
