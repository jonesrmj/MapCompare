//
//  AppState.swift
//  MapCompare
//
//  Created by Ryan Jones on 9/9/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import Foundation

class AppState: ObservableObject {
  @Published var tripModel = TripModel()
  @Published var isAddTripPresented = false
  @Published var isEmailPresented = false
  @Published var isStatsPresented = false
}

extension AppState {
  func restore(from activity: NSUserActivity) {
    guard activity.activityType == Bundle.main.activityType,
      let encodedTripModel = activity.userInfo?[Key.tripModel] as? Data,
      let isAddTripPresented = activity.userInfo?[Key.isAddTripPresented] as? Bool,
      let isEmailPresented = activity.userInfo?[Key.isEmailPresented] as? Bool,
      let isStatspPresented = activity.userInfo?[Key.isStatsPresented] as? Bool
      else {
        return
    }
    
    let decoder = JSONDecoder()
    
    if let decodedTripModel = try? decoder.decode(TripModel.self, from: encodedTripModel) {
      self.tripModel = decodedTripModel
      self.isAddTripPresented = isAddTripPresented
      self.isEmailPresented = isEmailPresented
      self.isStatsPresented = isStatspPresented
    }
  }
  
  func store(in activity: NSUserActivity) {
    let encoder = JSONEncoder()
    
    if let encodedTripModel = try? encoder.encode(tripModel) {
      activity.addUserInfoEntries(from: [Key.tripModel: encodedTripModel,
                                         Key.isAddTripPresented: isAddTripPresented,
                                         Key.isEmailPresented: isEmailPresented,
                                         Key.isStatsPresented: isStatsPresented])
    }
  }
  
  private enum Key {
    static let tripModel = "tripModel"
    static let isAddTripPresented = "isAddTripPresented"
    static let isEmailPresented = "isAddEmailPresented"
    static let isStatsPresented = "isStatsPresented"
  }
}
