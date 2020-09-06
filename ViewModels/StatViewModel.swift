//
//  StatViewModel.swift
//  MapCompare
//
//  Created by Ryan Jones on 9/6/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import Foundation
import SwiftUI

extension StatView {
  class StatViewModel: NSObject, ObservableObject {
    @Published var appleDeltaDisplay: String = ""
    @Published var googleDeltaDisplay: String = ""
    @Published var hereDeltaDisplay: String = ""
    @Published var bingDeltaDisplay: String = ""
    
    @Published var appleCountDisplay: String = ""
    @Published var googleCountDisplay: String = ""
    @Published var hereCountDisplay: String = ""
    @Published var bingCountDisplay: String = ""
    
    func calcStats(trips: [Trip]) {
      var appleDelta: Double = 0
      var googleDelta: Double = 0
      var hereDelta: Double = 0
      var bingDelta: Double = 0
      
      var appleCount: Int = 0
      var googleCount: Int = 0
      var hereCount: Int = 0
      var bingCount: Int = 0
      
      trips.forEach { (trip) in
        appleDelta += trip.appleDeltaSeconds
        googleDelta += trip.googleDeltaSeconds
        hereDelta += trip.hereDeltaSeconds
        bingDelta += trip.bingDeltaSeconds
        
        let winner = trip.mostAccurateProvider
        
        switch winner {
          case "Apple" : appleCount += 1
          case "Google" : googleCount += 1
          case "Here" : hereCount += 1
          default : bingCount += 1
        }
      }
      
      let count = Double(trips.count)
      appleDelta = appleDelta / count
      googleDelta = googleDelta / count
      hereDelta = hereDelta / count
      bingDelta = bingDelta / count
      
      appleDeltaDisplay = TripModel.displayTimeFromSeconds(label: "", seconds: appleDelta)
      googleDeltaDisplay = TripModel.displayTimeFromSeconds(label: "", seconds: googleDelta)
      hereDeltaDisplay = TripModel.displayTimeFromSeconds(label: "", seconds: hereDelta)
      bingDeltaDisplay = TripModel.displayTimeFromSeconds(label: "", seconds: bingDelta)
      
      appleCountDisplay = String(appleCount)
      googleCountDisplay = String(googleCount)
      hereCountDisplay = String(hereCount)
      bingCountDisplay = String(bingCount)
    }
  }
}
