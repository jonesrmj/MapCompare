//
//  TripList.swift
//  MapCompare
//
//  Created by Ryan Jones on 8/12/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import SwiftUI

struct TripList: View {
  @Environment(\.managedObjectContext) var managedObjectContext
  
  @FetchRequest(
    entity: Trip.entity(),
    sortDescriptors: [
      NSSortDescriptor(keyPath: \Trip.tripStart, ascending: false)
    ]
  ) var trips: FetchedResults<Trip>
  
  @State var isPresented = false
  
  var body: some View {
    NavigationView {
      List {
        ForEach(trips, id:\.tripStart) {
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
    //self.trips.remove(atOffsets: offsets)
  }
  
  func addTrip(trip: TripModel) {
    let managedTrip = Trip(context: managedObjectContext)
    managedTrip.setPropertiesUsingTripModel(trip: trip)
    saveContext()
  }
  
  func saveContext() {
    do {
      try managedObjectContext.save()
    } catch {
      print("Error saving managed object context: \(error)")
    }
  }
}

struct TripList_Previews: PreviewProvider {
  static var previews: some View {
    TripList()
  }
}
