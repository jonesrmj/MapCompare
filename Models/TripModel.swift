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
  var title: String
  var tripStart: Date
  var tripEnd: Date
  var appleEstimatedSeconds: Int
  var googleEstimatedSeconds: Int
  var hereEstimatedSeconds: Int
  var bingEstimatedSeconds: Int
  var tripActualSeconds: Int
  var appleDeltaSeconds: Int
  var googleDeltaSeconds: Int
  var hereDeltaSeconds: Int
  var bingDeltaSeconds: Int
  
  init(
    title: String,
    tripStart: Date,
    tripEnd: Date,
    appleEstimatedSeconds: Int,
    googleEstimatedSeconds: Int,
    hereEstimatedSeconds: Int,
    bingEstimatedSeconds: Int ) {
    
    self.title = title
    self.tripStart = tripStart
    self.tripEnd = tripEnd
    self.appleEstimatedSeconds = appleEstimatedSeconds
    self.googleEstimatedSeconds = googleEstimatedSeconds
    self.hereEstimatedSeconds = hereEstimatedSeconds
    self.bingEstimatedSeconds = bingEstimatedSeconds
    
    tripActualSeconds = 0
    appleDeltaSeconds = 0
    googleDeltaSeconds = 0
    hereDeltaSeconds = 0
    bingDeltaSeconds = 0
    
    calcTrip()
  }
  
  init() {
    title = ""
    tripStart = Date()
    tripEnd = Date()
    appleEstimatedSeconds = 0
    googleEstimatedSeconds = 0
    hereEstimatedSeconds = 0
    bingEstimatedSeconds = 0
    
    tripActualSeconds = 0
    appleDeltaSeconds = 0
    googleDeltaSeconds = 0
    hereDeltaSeconds = 0
    bingDeltaSeconds = 0

    calcTrip()
  }
  
  mutating private func calcTrip() {
    let difference = tripEnd.timeIntervalSince(tripStart)
    let interval = Int(difference)
    tripActualSeconds = interval
    
    appleDeltaSeconds = appleEstimatedSeconds - tripActualSeconds
    googleDeltaSeconds = googleEstimatedSeconds - tripActualSeconds
    hereDeltaSeconds = hereEstimatedSeconds - tripActualSeconds
    bingDeltaSeconds = bingEstimatedSeconds - tripActualSeconds
  }
}
