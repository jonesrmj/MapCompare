//
//  BingMapsDuration.swift
//  MapCompare
//
//  Created by Ryan Jones on 8/22/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import Foundation

struct BingMapsResponse: Decodable {
  let resourceSets: [BingMapsResourceSet]
  
  func getDuration() -> Int {
    return resourceSets.first?.resources.first?.travelDurationTraffic ?? 0
  }
}

struct BingMapsResourceSet: Decodable {
  let resources: [BingMapsResource]
}

struct BingMapsResource: Decodable {
  let travelDurationTraffic: Int
}
