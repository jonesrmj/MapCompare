//
//  TripListView.swift
//  MapCompare
//
//  Created by Ryan Jones on 8/12/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import SwiftUI
import MessageUI

struct TripListView: View {
  @Environment(\.managedObjectContext) var managedObjectContext
  @EnvironmentObject var appState: AppState
  
  @FetchRequest(
    entity: Trip.entity(),
    sortDescriptors: [
      NSSortDescriptor(keyPath: \Trip.tripStart, ascending: false)
    ]
  ) var trips: FetchedResults<Trip>
  
  @State var result: Result<MFMailComposeResult, Error>? = nil
  
  var body: some View {
    NavigationView {
      VStack {
        if #available(iOS 14.0, *) {
          List {
            ForEach(trips, id:\.tripStart) {
              TripRowView(trip: $0)
            }
            .onDelete(perform: deleteTrip)
          }
          .listStyle(InsetGroupedListStyle())
        } else {
          List {
            ForEach(trips, id:\.tripStart) {
              TripRowView(trip: $0)
            }
            .onDelete(perform: deleteTrip)
          }
          .listStyle(GroupedListStyle())
        }
      }
      .navigationBarTitle(Text("Trips"))
      .navigationBarItems(trailing:
        HStack {
          VStack {
            Button(action: {
              self.generateCSVText(withManagedObjects: self.trips)
              self.appState.isEmailPresented.toggle()
            }) {
              Image(systemName: "envelope")
            }
            .disabled(!MFMailComposeViewController.canSendMail())
          }
          
          VStack {
            Button(action: { self.appState.isStatsPresented.toggle() }) {
              Image(systemName: "gauge")
            }
            .padding(.horizontal, 30.0)
          }
          
          Button(action: { self.appState.isAddTripPresented = true }) {
            Image(systemName: "plus")
          }
        }
      )
    }
    .sheet(isPresented: $appState.isAddTripPresented, onDismiss: {
      self.appState.tripModel = TripModel()
    }) {
      AddTripView(viewModel: AddTripViewModel(tripModel: self.appState.tripModel)) {
        self.addTrip()
        self.appState.isAddTripPresented = false
      }
      .environmentObject(self.appState)
    }
    .background(
      EmptyView()
      .sheet(isPresented: $appState.isStatsPresented) {
        StatView(isStatsPresented: self.$appState.isStatsPresented)
        .environment(\.managedObjectContext, self.managedObjectContext)
      }
    )
    .background(
      EmptyView()
      .sheet(isPresented: $appState.isEmailPresented) {
        MailView(result: self.$result)
      }
    )
  }
  
  func deleteTrip(at offsets: IndexSet) {
    offsets.forEach { index in
      let trip = self.trips[index]
      self.managedObjectContext.delete(trip)
    }
    saveContext()
  }
  
  func addTrip() {
    let managedTrip = Trip(context: managedObjectContext)
    managedTrip.setPropertiesUsingTripModel(trip: appState.tripModel)
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
    var CSVString = "title, originTitle, originLat, originLong, destinationTitle, destinationLat, destinationLong, tripStart, tripEnd, appleEstimatedSeconds, googleEstimatedSeconds, hereEstimatedSeconds, bingEstimatedSeconds, tripActualSeconds, tripActualTime, appleDeltaSeconds, googleDeltaSeconds, hereDeltaSeconds, bingDeltaSeconds, mostAccurateProvider\n"
    arrManagedObject.forEach { (trip) in
      let entityContent = "\(String(describing: trip.title)), \(String(describing: trip.originTitle!)), \(String(describing: trip.originLat)), \(String(describing: trip.originLong)), \(String(describing: trip.destinationTitle!)), \(String(describing: trip.destinationLat)), \(String(describing: trip.destinationLong)), \(String(describing: trip.tripStart!)), \(String(describing: trip.tripEnd!)), \(String(describing: trip.appleEstimatedSeconds)), \(String(describing: trip.googleEstimatedSeconds)), \(String(describing: trip.hereEstimatedSeconds)), \(String(describing: trip.bingEstimatedSeconds)), \(String(describing: trip.tripActualSeconds)), \(String(describing: trip.tripActualTime)), \(String(describing: trip.appleDeltaSeconds)), \(String(describing: trip.googleDeltaSeconds)), \(String(describing: trip.hereDeltaSeconds)), \(String(describing: trip.bingDeltaSeconds)), \(String(describing: trip.mostAccurateProvider))\n"
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
