//
//  MapCompareViewModel.swift
//  MapCompare
//
//  Created by Ryan Jones on 7/26/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import CoreLocation
import MapKit

class MapCompareViewModel: NSObject, ObservableObject, Identifiable {
    private let locationManager = CLLocationManager()
    private var currentRegion: MKCoordinateRegion?
    
    @Published var origin: String = ""
    @Published var destination: String = ""
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    func setOrigin() {
        self.origin = "Hi Ryan"
    }
}

extension MapCompareViewModel: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    // 1 (Ensure the user has given the app authorization to access location information)
    guard status == .authorizedWhenInUse else {
        return
    }
    manager.requestLocation()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let firstLocation = locations.first else {
        return
    }
    
    //1 (commonDelta refers to zoom level you want. Increase the value for more coverage)
    let commonDelta: CLLocationDegrees = 25 / 111
    let span = MKCoordinateSpan(
        latitudeDelta: commonDelta,
        longitudeDelta: commonDelta)
    //2 (The  region you created using the coordinates obtained via CoreLocation's delegate)
    let region = MKCoordinateRegion(center: firstLocation.coordinate, span: span)
    currentRegion = region
    
    /*
    // 2 (Returns an array of placemarks in its completion handler)
    CLGeocoder().reverseGeocodeLocation(firstLocation) { places, _ in
        // 3 (Make sure text field is empty).
        guard
            let firstPlace = places?.first,
            self.originTextField.contents == nil
            else {
                return
        }
        
        // 4 (Store the current location and update the field)
        self.currentPlace = firstPlace
        self.originTextField.text = firstPlace.abbreviation
     */
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Error requesting location: \(error.localizedDescription)")
  }

