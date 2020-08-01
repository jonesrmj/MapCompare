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

//Google Map API Key - AIzaSyDTi_XOeVlQM9sRq8Vntlw-8c8vsbxqrbI

class MapCompareViewModel: NSObject, ObservableObject, Identifiable {
    private let locationManager = CLLocationManager()
    private var currentRegion: MKCoordinateRegion?
    private var currentLocation: CLLocationCoordinate2D?
    private var destinationLocation = CLLocationCoordinate2D(latitude: 39.755965, longitude: -75.697045)
    
    @Published var origin: String = ""
    @Published var destination: String = "229 Charleston Drive"
    @Published var appleEstimatedTime: String = ""
    
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
    
    func calculateEstimates() {
        calculateAppleEstimate()
        calculateGoogleEstimate()
    }
    
    func calculateAppleEstimate() {
        guard currentLocation != nil else { return }
        let request = MKDirections.Request()
        
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation!))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationLocation))
        
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            guard let mapRoute = response?.routes.first else {
                self.appleEstimatedTime = "Unable to Estimate"
                return
            }
            
            let (h,m,s) = self.secondsToHoursMinutesSeconds(seconds: mapRoute.expectedTravelTime)
            self.appleEstimatedTime = "Apple Estimate: \(h) hrs \(m) min \(s) sec"
        }
    }
    
    func calculateGoogleEstimate() {
        /*
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(currentLocation!.latitude),\(currentLocation!.longitude)&destination=\(destinationLocation.latitude),\(destinationLocation.longitude)&key=AIzaSyDTi_XOeVlQM9sRq8Vntlw-8c8vsbxqrbI"
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, res, err in
                if let data = data {
                    print("hey")
                    
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(response.self, from: data) {
                        print(json)
                    }
                }
            }.resume()
            print("finished")
        }
        */
    }
    
    func secondsToHoursMinutesSeconds(seconds: Double) -> (Int, Int, Int) {
        return (Int(seconds) / 3600, (Int(seconds) % 3600) / 60, (Int(seconds) % 3600) % 60)
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
        guard let loc = locations.first else {
            return
        }
                
        //1 (commonDelta refers to zoom level you want. Increase the value for more coverage)
        let commonDelta: CLLocationDegrees = 25 / 111
        let span = MKCoordinateSpan(
            latitudeDelta: commonDelta,
            longitudeDelta: commonDelta)
        //2 (The  region you created using the coordinates obtained via CoreLocation's delegate)
        let region = MKCoordinateRegion(center: loc.coordinate, span: span)
        
        // 2 (Returns an array of placemarks in its completion handler)
        CLGeocoder().reverseGeocodeLocation(loc) { places, _ in
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
            self.currentLocation = loc.coordinate
            self.currentRegion = region
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
    
}
