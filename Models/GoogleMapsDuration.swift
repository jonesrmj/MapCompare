//
//  RouteStep.swift
//  MapCompare
//
//  Created by Ryan Jones on 8/2/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import Foundation

enum CodingKeys: String, CodingKey {
    case Text = "text"
    case Value = "value"
}

struct GoogleMapsResponse: Decodable {
    let routes: [GoogleMapsRoutes]
    
    func getDuration() -> Int {
        return routes.first?.legs.first?.duration.value ?? 0
    }
}

struct GoogleMapsRoutes: Decodable {
    let legs: [GoogleMapsLegs]
}

struct GoogleMapsLegs: Decodable {
    let duration: GoogleMapsDuration
}

struct GoogleMapsDuration: Decodable {
    let text: String
    let value: Int
}
