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

//Google Maps API Key - AIzaSyDTi_XOeVlQM9sRq8Vntlw-8c8vsbxqrbI
//Here Maps API Key - J9mnOKeM9hvkDM84Z2XDLjXCi3b6SoRMRMtOM9YyWSU

class MapCompareViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
  private let locationManager = CLLocationManager()
  private var currentRegion: MKCoordinateRegion?
  private var currentLocation: CLLocationCoordinate2D?
  private var destinationLocation: CLLocationCoordinate2D?
  private var completer: MKLocalSearchCompleter
  private var cancellable: AnyCancellable?
  private var startTime: Date?
  private var endTime: Date?
  
  @Published var origin: String = ""
  @Published var destination: String = ""
  @Published var appleEstimatedTime: String = "Apple Estimate:"
  @Published var googleEstimatedTime: String = "Google Estimate:"
  @Published var hereEstimatedTime: String = "Here Estimate:"
  @Published var suggestedAddresses: [MKLocalSearchCompletion] = []
  @Published var appleLoading: Bool = false
  @Published var googleLoading: Bool = false
  @Published var hereLoading: Bool = false
  @Published var actualTravelTime: String = "Actual Travel Time:"
  
  override init() {
    completer = MKLocalSearchCompleter()
    
    super.init()
    
    cancellable = $destination.assign(to: \.queryFragment, on: self.completer)
    locationManager.delegate = self
    completer.delegate = self
    
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
  
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    self.suggestedAddresses = completer.results
  }
  
  func setDestination(destination: MKLocalSearchCompletion) {
    self.destination = destination.title
    
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(destination.title + ", " + destination.subtitle) { placemarks, error in
      let d = placemarks!.first
      self.destinationLocation = CLLocationCoordinate2D(latitude: d!.location!.coordinate.latitude, longitude: d!.location!.coordinate.longitude)
    }
    
    completer.cancel()
    suggestedAddresses.removeAll()
  }
  
  func calculateEstimates() {
    calculateAppleEstimate()
    calculateGoogleEstimate()
    calculateHereEstimate()
  }
  
  func calculateAppleEstimate() {
    appleLoading = true
    guard currentLocation != nil else { return }
    let request = MKDirections.Request()
    
    request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation!))
    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationLocation!))
    
    let directions = MKDirections(request: request)
    
    directions.calculate { response, error in
      guard let mapRoute = response?.routes.first else {
        self.appleEstimatedTime = "Unable to Estimate"
        return
      }
      
      let (h,m,s) = self.secondsToHoursMinutesSeconds(seconds: mapRoute.expectedTravelTime)
      self.appleLoading = false
      self.appleEstimatedTime = "Apple Estimate: \(h) hrs \(m) min \(s) sec"
    }
  }
  
  func calculateGoogleEstimate() {
    googleLoading = true
    let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(currentLocation!.latitude),\(currentLocation!.longitude)&destination=\(destinationLocation!.latitude),\(destinationLocation!.longitude)&key=AIzaSyDTi_XOeVlQM9sRq8Vntlw-8c8vsbxqrbI"
    if let url = URL(string: urlString) {
      URLSession.shared.dataTask(with: url) { data, res, err in
        if let data = data {
          print("google initalize")
          
          let decoder = JSONDecoder()
          if let json = try? decoder.decode(GoogleMapsResponse.self, from: data) {
            print("processes json (google)")
            
            let (h,m,s) = self.secondsToHoursMinutesSeconds(seconds: Double(json.getDuration()))
            self.googleLoading = false
            self.googleEstimatedTime = "Google Estimate: \(h) hrs \(m) min \(s) sec"
          }
        }
      }.resume()
    }
  }
  
  func calculateHereEstimate() {
    hereLoading = true
    let urlString = "https://router.hereapi.com/v8/routes?transportMode=car&origin=\(currentLocation!.latitude),\(currentLocation!.longitude)&destination=\(destinationLocation!.latitude),\(destinationLocation!.longitude)&apiKey=J9mnOKeM9hvkDM84Z2XDLjXCi3b6SoRMRMtOM9YyWSU&return=summary"
    if let url = URL(string: urlString) {
      URLSession.shared.dataTask(with: url) { data, res, err in
        if let data = data {
          print("here initalize")
          
          let decoder = JSONDecoder()
          if let json = try? decoder.decode(HereMapsResponse.self, from: data) {
            print("processed json (here)")
            
            let (h,m,s) = self.secondsToHoursMinutesSeconds(seconds: Double(json.getDuration()))
            self.hereLoading = false
            self.hereEstimatedTime = "Here Estimate: \(h) hrs \(m) min \(s) sec"
          }
        }
      }.resume()
    }
  }
  
  func secondsToHoursMinutesSeconds(seconds: Double) -> (Int, Int, Int) {
    return (Int(seconds) / 3600, (Int(seconds) % 3600) / 60, (Int(seconds) % 3600) % 60)
  }
  
  func openDirections() {
    startTime = Date()
    
    let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)))
    source.name = "\(origin)"
    
    let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinationLocation!.latitude, longitude: destinationLocation!.longitude)))
    destination.name = "\(self.destination)"
    
    MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
  }
  
  func stop() {
    endTime = Date()
    
    let difference = endTime?.timeIntervalSince(startTime!)
    let interval = Int(difference!)
    let (h,m,s) = self.secondsToHoursMinutesSeconds(seconds: Double(interval))
    self.actualTravelTime = "Actual Travel Time: \(h) hrs \(m) min \(s) sec"
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

extension MKLocalSearchCompletion: Identifiable {}
