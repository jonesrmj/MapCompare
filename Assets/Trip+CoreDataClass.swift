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
  var title: String { return (originTitle ?? "None") + " -> " + (destinationTitle ?? "None") }
  var tripActualSeconds: Double { return tripEnd != nil && tripStart != nil ? tripEnd!.timeIntervalSince(tripStart!) : 0 }
  var tripActualTime: String { return TripModel.displayTimeFromSeconds(label: "", seconds: tripActualSeconds) }
  var appleDeltaSeconds: Double { return appleEstimatedSeconds - tripActualSeconds }
  var googleDeltaSeconds: Double { return googleEstimatedSeconds - tripActualSeconds }
  var hereDeltaSeconds: Double { return hereEstimatedSeconds - tripActualSeconds }
  var bingDeltaSeconds: Double { return bingEstimatedSeconds - tripActualSeconds }
  var mostAccurateProvider: String {
    var scores: [(provider: String, delta: Double)] = [("Apple", appleDeltaSeconds), ("Google", googleDeltaSeconds), ("Here", hereDeltaSeconds), ("Bing", bingDeltaSeconds)]
    scores.sort(by: {$0.delta < $1.delta})
    return scores.first != nil ? scores.first!.provider : "None"
  }
  
  func setPropertiesUsingTripModel(trip: TripModel) {
    let comma: Set<Character> = [","]
    var title = trip.originTitle
    title.removeAll(where: { comma.contains($0) } )
    self.originTitle = title
    self.originLat = trip.originLat
    self.originLong = trip.originLong
    title = trip.destinationTitle
    title.removeAll(where: { comma.contains($0) } )
    self.destinationTitle = title
    self.destinationLat = trip.destinationLat
    self.destinationLong = trip.destinationLong
    self.tripStart = trip.tripStart
    self.tripEnd = trip.tripEnd
    self.appleEstimatedSeconds = trip.appleEstimatedSeconds
    self.googleEstimatedSeconds = trip.googleEstimatedSeconds
    self.hereEstimatedSeconds = trip.hereEstimatedSeconds
    self.bingEstimatedSeconds = trip.bingEstimatedSeconds
  }
}
