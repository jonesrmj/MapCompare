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
    
    override init() {
      super.init()
    }
    
    func calcAverageDelta() {
      var appleDelta: Double = 0
      var googleDelta: Double = 0
      var hereDelta: Double = 0
      var bingDelta: Double = 0
      
      trips.forEach { (trip) in
        appleDelta += trip.appleDeltaSeconds
        googleDelta += trip.googleDeltaSeconds
        hereDelta += trip.hereDeltaSeconds
        bingDelta += trip.bingDeltaSeconds
      }
      
      let count = Double(trips.count)
      appleDelta = appleDelta / count
      googleDelta = googleDelta / count
      hereDelta = hereDelta / count
      bingDelta = bingDelta / count
      
      appleDeltaDisplay = String(appleDelta)
      googleDeltaDisplay = String(googleDelta)
      hereDeltaDisplay = String(hereDelta)
      bingDeltaDisplay = String(bingDelta)
    }
  }
}
