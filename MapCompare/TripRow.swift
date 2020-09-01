//
//  TripRow.swift
//  MapCompare
//
//  Created by Ryan Jones on 8/12/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import SwiftUI

struct TripRow: View {
  let trip: Trip
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "M/dd/yy h:mma"
    formatter.amSymbol = "am"
    formatter.pmSymbol = "pm"
    return formatter
  }()
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(trip.title)
        .font(.subheadline)
      HStack {
        Text(String(trip.tripActualTime))
          .font(.caption)
        Spacer()
        Text(Self.dateFormatter.string(from: trip.tripStart!))
          .font(.caption)
      }
    }
  }
}
