//
//  Address.swift
//  MapCompare
//
//  Created by Ryan Jones on 8/8/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import Foundation
import MapKit

struct Address: Identifiable {
  var id = UUID()
  var title: String
  var subtitle: String
  
  init(title: String, subtitle: String) {
    self.title = title
    self.subtitle = subtitle
  }
}

