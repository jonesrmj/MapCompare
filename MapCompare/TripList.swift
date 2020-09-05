//
//  TripList.swift
//  MapCompare
//
//  Created by Ryan Jones on 8/12/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import SwiftUI
import MessageUI

struct TripList: View {
  @Environment(\.managedObjectContext) var managedObjectContext
  
  @FetchRequest(
    entity: Trip.entity(),
    sortDescriptors: [
      NSSortDescriptor(keyPath: \Trip.tripStart, ascending: false)
    ]
  ) var trips: FetchedResults<Trip>
  
  @State var isAddTripPresented = false
  @State var isEmailPresented = false
  @State var isStatsPresented = false
  @State var result: Result<MFMailComposeResult, Error>? = nil
  
  var body: some View {
    NavigationView {
      List {
        ForEach(trips, id:\.tripStart) {
          TripRow(trip: $0)
        }
        .onDelete(perform: deleteTrip)
      }
      .sheet(isPresented: $isAddTripPresented)  {
        ContentView { trip in
          self.addTrip(trip: trip)
          self.isAddTripPresented = false
        }
      }
      .navigationBarTitle(Text("Trips"))
        .navigationBarItems(trailing:
          HStack {
            Button(action: {
              self.generateCSVText(withManagedObjects: self.trips)
              self.isEmailPresented.toggle()
            }) {
              Image(systemName: "envelope")
            }
            .disabled(!MFMailComposeViewController.canSendMail())
            .sheet(isPresented: $isEmailPresented) {
                MailView(result: self.$result)
            }
            
            Button(action: { self.isStatsPresented.toggle() }) {
              Image(systemName: "gauge")
            }
            .padding(.horizontal, 30.0)
            
            Button(action: { self.isAddTripPresented.toggle() }) {
              Image(systemName: "plus")
            }
          }
      )
    }
  }
  
  func deleteTrip(at offsets: IndexSet) {
    offsets.forEach { index in
      let trip = self.trips[index]
      self.managedObjectContext.delete(trip)
    }
    saveContext()
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
  
  func generateCSVText(withManagedObjects arrManagedObject: FetchedResults<Trip>) {
    var CSVString = "title, originTitle, originLat, originLong, destinationTitle, destinationLat, destinationLong, tripStart, tripEnd, appleEstimatedSeconds, googleEstimatedSeconds, hereEstimatedSeconds, bingEstimatedSeconds, tripActualSeconds, tripActualTime, appleDeltaSeconds, googleDeltaSeconds, hereDeltaSeconds, bingDeltaSeconds\n"
    arrManagedObject.forEach { (trip) in
      let entityContent = "\(String(describing: trip.title)), \(String(describing: trip.originTitle!)), \(String(describing: trip.originLat)), \(String(describing: trip.originLong)), \(String(describing: trip.destinationTitle!)), \(String(describing: trip.destinationLat)), \(String(describing: trip.destinationLong)), \(String(describing: trip.tripStart!)), \(String(describing: trip.tripEnd!)), \(String(describing: trip.appleEstimatedSeconds)), \(String(describing: trip.googleEstimatedSeconds)), \(String(describing: trip.hereEstimatedSeconds)), \(String(describing: trip.bingEstimatedSeconds)), \(String(describing: trip.tripActualSeconds)), \(String(describing: trip.tripActualTime)), \(String(describing: trip.appleDeltaSeconds)), \(String(describing: trip.googleDeltaSeconds)), \(String(describing: trip.hereDeltaSeconds)), \(String(describing: trip.bingDeltaSeconds))\n"
      CSVString.append(entityContent)
    }
    let fileManager = FileManager.default
    let directory = fileManager.urls( for: .documentDirectory, in: .userDomainMask)[0]
    let path = directory.appendingPathComponent("trip").appendingPathExtension("csv")
    if (!fileManager.fileExists(atPath:path.path)) {
      fileManager.createFile(atPath: path.path, contents: nil, attributes: nil)
    }
    do {
      try CSVString.write(to: path, atomically: true, encoding: .utf8)
    } catch let error {
      print("Error creating CSV: \(error.localizedDescription)")
    }
  }
}

struct TripList_Previews: PreviewProvider {
  static var previews: some View {
    TripList()
  }
}
