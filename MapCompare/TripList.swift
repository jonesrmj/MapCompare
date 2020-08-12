//
//  TripList.swift
//  MapCompare
//
//  Created by Ryan Jones on 8/12/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import SwiftUI

struct TripList: View {
  @State var trips: [TripModel] = []
  @State var isPresented = false
  
  var body: some View {
    NavigationView {
      List {
        ForEach(trips, id:\.id) {
          TripRow(trip: $0)
        }
        .onDelete(perform: deleteTrip)
      }
      .sheet(isPresented: $isPresented)  {
        ContentView { trip in
          self.addTrip(trip: trip)
          self.isPresented = false
        }
      }
      .navigationBarTitle(Text("Trips"))
        .navigationBarItems(trailing:
          Button(action: { self.isPresented.toggle() }) {
            Image(systemName: "plus")
          }
      )
    }
  }
  
  func deleteTrip(at offsets: IndexSet) {
    self.trips.remove(atOffsets: offsets)
  }
  
  func addTrip(trip: TripModel) {
    trips.append(trip)
  }
}

struct TripList_Previews: PreviewProvider {
  static var previews: some View {
    TripList()
  }
}
