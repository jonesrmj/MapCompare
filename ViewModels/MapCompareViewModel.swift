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
import CoreData

//Google Maps API Key - AIzaSyDTi_XOeVlQM9sRq8Vntlw-8c8vsbxqrbI
//Here Maps API Key - J9mnOKeM9hvkDM84Z2XDLjXCi3b6SoRMRMtOM9YyWSU
//Bing Maps API Key - AuZh08gukk6RY79-n6QxsPUdifLbkVcjr3W-FIjmdXs5JkscAGiKCF1G5sYc1-Vs

class MapCompareViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
  
  private let locationManager = CLLocationManager()
  private var currentRegion: MKCoordinateRegion?
  private var currentLocation: CLLocationCoordinate2D?
  private var destinationLocation: CLLocationCoordinate2D?
  private var completer: MKLocalSearchCompleter
  private var cancellable: AnyCancellable?
  private var startTime: Date?
  private var endTime: Date?
  
  var trip = TripModel()
  
  @Published var originDisplay: String = ""
  @Published var destinationDisplay: String = ""
  @Published var actualTravelTimeDisplay: String = "Actual Travel Time:"
  @Published var appleEstimatedTimeDisplay: String = "Apple Estimate:"
  @Published var googleEstimatedTimeDisplay: String = "Google Estimate:"
  @Published var hereEstimatedTimeDisplay: String = "Here Estimate:"
  @Published var bingEstimatedTimeDisplay: String = "Bing Estimate:"
  @Published var suggestedAddresses: [MKLocalSearchCompletion] = []
  @Published var appleLoading: Bool = false
  @Published var googleLoading: Bool = false
  @Published var hereLoading: Bool = false
  @Published var bingLoading: Bool = false
  
  override init() {
    completer = MKLocalSearchCompleter()
    
    super.init()

    cancellable = $destinationDisplay.assign(to: \.queryFragment, on: self.completer)
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
    self.destinationDisplay = destination.title
    self.trip.destinationTitle = destination.title
    
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(destination.title + ", " + destination.subtitle) { placemarks, error in
      let d = placemarks!.first
      self.destinationLocation = CLLocationCoordinate2D(latitude: d!.location!.coordinate.latitude, longitude: d!.location!.coordinate.longitude)
      self.trip.destinationLat = self.destinationLocation!.latitude
      self.trip.destinationLong = self.destinationLocation!.longitude
    }
    
    completer.cancel()
    suggestedAddresses.removeAll()
  }
  
  func calculateEstimates() {
    calculateAppleEstimate()
    calculateGoogleEstimate()
    calculateHereEstimate()
    calculateBingEstimate()
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
        self.appleEstimatedTimeDisplay = "Unable to Estimate"
        return
      }
      
      self.trip.appleEstimatedSeconds = mapRoute.expectedTravelTime
      
      DispatchQueue.main.async {
        self.appleLoading = false
        self.appleEstimatedTimeDisplay = TripModel.displayTimeFromSeconds(label: "Apple Estimate" , seconds: self.trip.appleEstimatedSeconds)
      }
    }
  }
  
  func calculateGoogleEstimate() {
    googleLoading = true
    let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(currentLocation!.latitude),\(currentLocation!.longitude)&destination=\(destinationLocation!.latitude),\(destinationLocation!.longitude)&key=AIzaSyDTi_XOeVlQM9sRq8Vntlw-8c8vsbxqrbI"
    if let url = URL(string: urlString) {
      URLSession.shared.dataTask(with: url) { data, res, err in
        if let data = data {
          let decoder = JSONDecoder()
          if let json = try? decoder.decode(GoogleMapsResponse.self, from: data) {
            self.trip.googleEstimatedSeconds = Double(json.getDuration())
            
            DispatchQueue.main.async {
              self.googleLoading = false
              self.googleEstimatedTimeDisplay = TripModel.displayTimeFromSeconds(label: "Google Estimate" , seconds: self.trip.googleEstimatedSeconds)
            }
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
          let decoder = JSONDecoder()
          if let json = try? decoder.decode(HereMapsResponse.self, from: data) {
            self.trip.hereEstimatedSeconds = Double(json.getDuration())
            
            DispatchQueue.main.async {
              self.hereLoading = false
              self.hereEstimatedTimeDisplay = TripModel.displayTimeFromSeconds(label: "Here Estimate" , seconds: self.trip.hereEstimatedSeconds)
            }
          }
        }
      }.resume()
    }
  }
  
  func calculateBingEstimate() {
    bingLoading = true
    let urlString = "https://dev.virtualearth.net/REST/V1/Routes?wp.0=\(currentLocation!.latitude),\(currentLocation!.longitude)&wp.1=\(destinationLocation!.latitude),\(destinationLocation!.longitude)&key=AuZh08gukk6RY79-n6QxsPUdifLbkVcjr3W-FIjmdXs5JkscAGiKCF1G5sYc1-Vs"
    if let url = URL(string: urlString) {
      URLSession.shared.dataTask(with: url) { data, res, err in
        if let data = data {
          let decoder = JSONDecoder()
          if let json = try? decoder.decode(BingMapsResponse.self, from: data) {
            self.trip.bingEstimatedSeconds = Double(json.getDuration())
            
            DispatchQueue.main.async {
              self.bingLoading = false
              self.bingEstimatedTimeDisplay = TripModel.displayTimeFromSeconds(label: "Bing Estimate" , seconds: self.trip.bingEstimatedSeconds)
            }
          }
        }
      }.resume()
    }
  }
  
  func openDirections() {
    startTime = Date()
    trip.tripStart = startTime
    
    let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)))
    source.name = "\(originDisplay)"
    
    let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinationLocation!.latitude, longitude: destinationLocation!.longitude)))
    destination.name = "\(self.destinationDisplay)"
    
    MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
  }
  
  func stop() {
    endTime = Date()
    trip.tripEnd = endTime
    
    self.actualTravelTimeDisplay = TripModel.displayTimeFromSeconds(label: "Actual Travel Time", seconds: self.trip.tripActualSeconds)
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
        self.originDisplay == ""
        else {
          return
      }
      
      // 4 (Store the current location and update the field)
      //self.currentPlace = firstPlace
      self.originDisplay = firstPlace.name ?? "Current Location"
      self.trip.originTitle = self.originDisplay
      self.currentLocation = loc.coordinate
      self.trip.originLat = self.currentLocation!.latitude
      self.trip.originLong = self.currentLocation!.longitude
      self.currentRegion = region
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Error requesting location: \(error.localizedDescription)")
  }
  
}

extension MKLocalSearchCompletion: Identifiable {}
