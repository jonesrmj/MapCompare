//
//  StatView.swift
//  MapCompare
//
//  Created by Ryan Jones on 9/6/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import Foundation
import SwiftUI

struct StatView: View {
  @Environment(\.managedObjectContext) var managedObjectContext
  @Environment(\.presentationMode) var presentation
  
  @State var viewModel = StatViewModel()
  @Binding var isStatsPresented: Bool
  
  @FetchRequest(
    entity: Trip.entity(),
    sortDescriptors: [
      NSSortDescriptor(keyPath: \Trip.tripStart, ascending: false)
    ]
  ) var trips: FetchedResults<Trip>
  
  var body: some View {
    NavigationView {
      VStack {
        VStack(alignment: .leading, spacing: 10.0) {
          HStack() {
            Text("Apple Count:")
            Spacer()
            Text(viewModel.appleCountDisplay)
          }
          HStack() {
            Text("Google Count:")
            Spacer()
            Text(viewModel.googleCountDisplay)
          }
          HStack() {
            Text("Here Count:")
            Spacer()
            Text(viewModel.hereCountDisplay)
          }
          HStack() {
            Text("Bing Count:")
            Spacer()
            Text(viewModel.bingCountDisplay)
          }
        }
        
        Divider()
        
        VStack(alignment: .leading, spacing: 10.0) {
          HStack() {
            Text("Apple Average:")
            Spacer()
            Text(viewModel.appleDeltaDisplay)
          }
          HStack() {
            Text("Google Average:")
            Spacer()
            Text(viewModel.googleDeltaDisplay)
          }
          HStack() {
            Text("Here Average:")
            Spacer()
            Text(viewModel.hereDeltaDisplay)
          }
          HStack() {
            Text("Bing Average:")
            Spacer()
            Text(viewModel.bingDeltaDisplay)
          }
        }
        
        Spacer()
      }
      .navigationBarTitle("Stats:", displayMode: .inline)
      .navigationBarItems(leading: HStack {
        Button(action: {
          self.isStatsPresented.toggle()
        }) {
          Text("Close")
        }
      })
      .padding(20.0)
      .onAppear(perform: calcStats)
    }
  }
  
  func calcStats() {
    viewModel.calcStats(trips: trips.compactMap { trip in trip })
  }
}
