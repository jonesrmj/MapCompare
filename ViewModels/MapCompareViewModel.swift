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
    private var currentLocation: MKCoordinateRegion?
    private var destinationLocation = CLLocation(latitude: 39.755965, longitude: -75.697045)
    
    @Published var origin: String = ""
    @Published var destination: String = "229 Charleston Drive"
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        
        attemptLocationAccess()
    }
    
    private func attemptLocationAccess() {
        // 1 (Check to see if user enabled location services)
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        // 2 (When finding the location’s coordinates, it’s not the most precise, so an accuracy of 100 meters is more than adequate)
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // 3 (This informs the app when the privacy setting is changed and your location is updated)
        locationManager.delegate = self
        // 4 (If the user enabled location services, then get current location)
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.denied) {
            // The user denied authorization
        } else if (status == CLAuthorizationStatus.authorizedAlways
            || status == CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestLocation()
            // The user accepted authorization
        }
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
        guard let currentLocation = locations.first else {
            return
        }
        
        //1 (commonDelta refers to zoom level you want. Increase the value for more coverage)
        let commonDelta: CLLocationDegrees = 25 / 111
        let span = MKCoordinateSpan(
            latitudeDelta: commonDelta,
            longitudeDelta: commonDelta)
        //2 (The  region you created using the coordinates obtained via CoreLocation's delegate)
        let region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        currentRegion = region
        
        
        // 2 (Returns an array of placemarks in its completion handler)
        CLGeocoder().reverseGeocodeLocation(currentLocation) { places, _ in
            // 3 (Make sure text field is empty).
            guard
                let firstPlace = places?.first,
                self.origin == ""
                else {
                    return
            }
            
            // 4 (Store the current location and update the field)
            //self.currentPlace = firstPlace
            self.origin = firstPlace.name ?? "Current Location"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
    
}
