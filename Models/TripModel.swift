//
//  TripModel.swift
//  MapCompare
//
//  Created by Ryan Jones on 8/12/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import Foundation
import Combine

class TripModel: Identifiable, Decodable, Encodable, ObservableObject {
  enum CodingKeys: CodingKey {
    case originTitle, originLat, originLong, destinationTitle, destinationLat, destinationLong, tripStart, tripEnd, appleEstimatedSeconds, googleEstimatedSeconds, hereEstimatedSeconds, bingEstimatedSeconds
  }
  
  var id = UUID()
  @Published var originTitle: String
  @Published var originLat: Double
  @Published var originLong: Double
  @Published var destinationTitle: String
  @Published var destinationLat: Double
  @Published var destinationLong: Double
  @Published var tripStart: Date?
  @Published var tripEnd: Date?
  @Published var appleEstimatedSeconds: Double
  @Published var googleEstimatedSeconds: Double
  @Published var hereEstimatedSeconds: Double
  @Published var bingEstimatedSeconds: Double
  
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
    appleEstimatedSeconds = 0
    googleEstimatedSeconds = 0
    hereEstimatedSeconds = 0
    bingEstimatedSeconds = 0
  }
  
  required init(from decoder: Decoder) throws {
     let container = try decoder.container(keyedBy: CodingKeys.self)
     
     originTitle = try container.decode(String.self, forKey: .originTitle)
     originLat = try container.decode(Double.self, forKey: .originLat)
     originLong = try container.decode(Double.self, forKey: .originLong)
     destinationTitle = try container.decode(String.self, forKey: .destinationTitle)
     destinationLat = try container.decode(Double.self, forKey: .destinationLat)
     destinationLong = try container.decode(Double.self, forKey: .destinationLong)
     tripStart = try container.decode(Date?.self, forKey: .tripStart)
     tripEnd = try container.decode(Date?.self, forKey: .tripEnd)
     appleEstimatedSeconds = try container.decode(Double.self, forKey: .appleEstimatedSeconds)
     googleEstimatedSeconds = try container.decode(Double.self, forKey: .googleEstimatedSeconds)
     hereEstimatedSeconds = try container.decode(Double.self, forKey: .hereEstimatedSeconds)
     bingEstimatedSeconds = try container.decode(Double.self, forKey: .bingEstimatedSeconds)
   }
   
   func encode(to encoder: Encoder) throws {
     var container = encoder.container(keyedBy: CodingKeys.self)
     
     try container.encode(originTitle, forKey: .originTitle)
     try container.encode(originLat, forKey: .originLat)
     try container.encode(originLong, forKey: .originLong)
     try container.encode(destinationTitle, forKey: .destinationTitle)
     try container.encode(destinationLat, forKey: .destinationLat)
     try container.encode(destinationLong, forKey: .destinationLong)
     try container.encode(tripStart, forKey: .tripStart)
     try container.encode(tripEnd, forKey: .tripEnd)
     try container.encode(appleEstimatedSeconds, forKey: .appleEstimatedSeconds)
     try container.encode(googleEstimatedSeconds, forKey: .googleEstimatedSeconds)
     try container.encode(hereEstimatedSeconds, forKey: .hereEstimatedSeconds)
     try container.encode(bingEstimatedSeconds, forKey: .bingEstimatedSeconds)
   }
  
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "M/dd/yy h:mm:ssa"
    formatter.amSymbol = "am"
    formatter.pmSymbol = "pm"
    return formatter
  }()

  static func displayTimeFromSeconds(label: String, seconds: Double) -> String {
    let (h,m,s) = (Int(seconds) / 3600, (Int(seconds) % 3600) / 60, (Int(seconds) % 3600) % 60)
    let prefix = !label.isEmpty ? "\(label): " : ""
    return "\(prefix)\(h) hrs \(m) min \(s) sec"
  }
}
