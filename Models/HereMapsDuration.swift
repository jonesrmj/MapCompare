//
//  HereMapsDuration.swift
//  MapCompare
//
//  Created by Ryan Jones on 8/2/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import Foundation

struct HereMapsResponse: Decodable {
    let routes: [HereMapsRoute]
    
    func getDuration() -> Int {
        return routes.first?.sections.first?.summary.duration ?? 0
    }
}

struct HereMapsRoute: Decodable {
    let sections: [HereMapsSection]
}

struct HereMapsSection: Decodable {
    let summary: HereMapsSummary
}

struct HereMapsSummary: Decodable {
    let duration: Int
}
