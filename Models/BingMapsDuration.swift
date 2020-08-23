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

//{
//    "resourceSets": [
//        {
//            "estimatedTotal": 1,
//            "resources": [
//                {
//                    "travelDistance": 636.877,
//                    "travelDuration": 22698,
//                    "travelDurationTraffic": 24272,
//                }
//            ]
//        }
//    ],
//    "statusCode": 200,
//    "statusDescription": "OK",
//    "traceId": "2af70124c9fb4c798db4c80fd9dec3b5|BN00002092|0.0.0.0|BN00001862, Leg0-BN0000182E"
//}
