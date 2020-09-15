//
//  AddTripViewModel.swift
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

class AddTripViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
  private let locationManager = CLLocationManager()
  private var currentRegion: MKCoordinateRegion?
  private var currentLocation: CLLocationCoordinate2D?
  private var destinationLocation: CLLocationCoordinate2D?
  private var completer: MKLocalSearchCompleter
  private var cancellable: AnyCancellable?
  
  // TripModel Properties
  @Published var originTitle: String = ""
  @Published var originLat: Double = 0
  @Published var originLong: Double = 0
  @Published var destinationTitle: String = ""
  @Published var destinationLat: Double = 0
  @Published var destinationLong: Double = 0
  @Published var appleEstimatedSeconds: Double = 0
  @Published var googleEstimatedSeconds: Double = 0
  @Published var hereEstimatedSeconds: Double = 0
  @Published var bingEstimatedSeconds: Double = 0
  @Published var tripStart: Date?
  @Published var tripEnd: Date?
  
  @Published var actualTravelSeconds: Double = 0
  
  //  @Published var appleEstimatedTimeDisplay: String = "Apple Estimate:"
  //  @Published var googleEstimatedTimeDisplay: String = "Google Estimate:"
  //  @Published var hereEstimatedTimeDisplay: String = "Here Estimate:"
  //  @Published var bingEstimatedTimeDisplay: String = "Bing Estimate:"
  
  @Published var suggestedAddresses: [MKLocalSearchCompletion] = []
  @Published var appleLoading: Bool = false
  @Published var googleLoading: Bool = false
  @Published var hereLoading: Bool = false
  @Published var bingLoading: Bool = false
  
  init(tripModel: TripModel) {
    completer = MKLocalSearchCompleter()
    
    super.init()
    
    cancellable = $destinationTitle.assign(to: \.queryFragment, on: self.completer)
    
    locationManager.delegate = self
    completer.delegate = self

    setTripDetails(from: tripModel)
  }
  
  private func setTripDetails(from tripModel: TripModel)  {
    if (tripModel.originLat == 0 && tripModel.originLong ==  0) {
      attemptLocationAccess()
    }  else {
      originTitle = tripModel.originTitle
      originLat = tripModel.originLat
      originLong = tripModel.originLong
      currentLocation = CLLocationCoordinate2D(latitude: originLat, longitude: originLong)
    }
    
    if (tripModel.destinationTitle != "") {
      destinationTitle = tripModel.destinationTitle
      destinationLat = tripModel.destinationLat
      destinationLong = tripModel.destinationLong
      destinationLocation = CLLocationCoordinate2D(latitude: destinationLat, longitude: destinationLong)
      completer.cancel()
      suggestedAddresses.removeAll()
    }
    
    appleEstimatedSeconds = tripModel.appleEstimatedSeconds
    googleEstimatedSeconds = tripModel.googleEstimatedSeconds
    hereEstimatedSeconds = tripModel.hereEstimatedSeconds
    bingEstimatedSeconds = tripModel.bingEstimatedSeconds
    tripStart = tripModel.tripStart
    tripEnd  = tripModel.tripEnd
    actualTravelSeconds = tripModel.tripActualSeconds
  }
  
  private func attemptLocationAccess() {
    // 1 (Check to see if user enabled location services)
    guard CLLocationManager.locationServicesEnabled() else {
      return
    }
    // 2 (When finding the location’s coordinates, it’s not the most precise, so an accuracy of 100 meters is more than adequate)
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
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
    self.destinationTitle = destination.title
    
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(destination.title + ", " + destination.subtitle) { placemarks, error in
      let d = placemarks!.first
      self.destinationLocation = CLLocationCoordinate2D(latitude: d!.location!.coordinate.latitude, longitude: d!.location!.coordinate.longitude)
      self.destinationLat = self.destinationLocation!.latitude
      self.destinationLong = self.destinationLocation!.longitude
      
      self.appleEstimatedSeconds = 0
      self.googleEstimatedSeconds = 0
      self.hereEstimatedSeconds = 0
      self.bingEstimatedSeconds = 0
    }
    
    completer.cancel()
    suggestedAddresses.removeAll()
  }
  
  func calculateEstimates() {
    calculateAppleEstimate()
    calculateGoogleEstimate()
    calculateHereEstimate()
    calculateBingEstimate()
    
    tripStart = nil
    tripEnd = nil
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
        //        self.appleEstimatedTimeDisplay = "Unable to Estimate"
        return
      }
      
      DispatchQueue.main.async {
        self.appleEstimatedSeconds = mapRoute.expectedTravelTime
        self.appleLoading = false
        //        self.appleEstimatedTimeDisplay = TripModel.displayTimeFromSeconds(label: "Apple Estimate" , seconds: self.appleEstimatedSeconds)
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
            
            DispatchQueue.main.async {
              self.googleEstimatedSeconds = Double(json.getDuration())
              self.googleLoading = false
              //              self.googleEstimatedTimeDisplay = TripModel.displayTimeFromSeconds(label: "Google Estimate" , seconds: self.googleEstimatedSeconds)
            }
          }
        }
      }.resume()
    }
  }
  
  func calculateHereEstimate() {
    hereLoading = true
    let urlString = "https://router.hereapi.com/v8/routes?transportMode=car&origin=\(currentLocation!.latitude),\(currentLocation!.longitude)&destination=\(destinationLocation!.latitude),\(destinationLocation!.longitude)&mode=fastest;car;traffic:enabled&apiKey=J9mnOKeM9hvkDM84Z2XDLjXCi3b6SoRMRMtOM9YyWSU&return=summary"
    if let url = URL(string: urlString) {
      URLSession.shared.dataTask(with: url) { data, res, err in
        if let data = data {
          let decoder = JSONDecoder()
          if let json = try? decoder.decode(HereMapsResponse.self, from: data) {
            
            DispatchQueue.main.async {
              self.hereEstimatedSeconds = Double(json.getDuration())
              self.hereLoading = false
              //              self.hereEstimatedTimeDisplay = TripModel.displayTimeFromSeconds(label: "Here Estimate" , seconds: self.hereEstimatedSeconds)
            }
          }
        }
      }.resume()
    }
  }
  
  func calculateBingEstimate() {
    bingLoading = true
    let urlString = "https://dev.virtualearth.net/REST/V1/Routes?wp.0=\(currentLocation!.latitude),\(currentLocation!.longitude)&wp.1=\(destinationLocation!.latitude),\(destinationLocation!.longitude)&optimize=timeWithTraffic&key=AuZh08gukk6RY79-n6QxsPUdifLbkVcjr3W-FIjmdXs5JkscAGiKCF1G5sYc1-Vs"
    if let url = URL(string: urlString) {
      URLSession.shared.dataTask(with: url) { data, res, err in
        if let data = data {
          let decoder = JSONDecoder()
          if let json = try? decoder.decode(BingMapsResponse.self, from: data) {
            
            DispatchQueue.main.async {
              self.bingEstimatedSeconds = Double(json.getDuration())
              self.bingLoading = false
              //              self.bingEstimatedTimeDisplay = TripModel.displayTimeFromSeconds(label: "Bing Estimate" , seconds: self.bingEstimatedSeconds)
            }
          }
        }
      }.resume()
    }
  }
  
  func openDirections() {
    tripStart = Date()
    
    let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)))
    source.name = "\(originTitle)"
    
    let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinationLocation!.latitude, longitude: destinationLocation!.longitude)))
    destination.name = "\(self.destinationTitle)"
    
    MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
  }
  
  func stop() {
    tripEnd = Date()
    actualTravelSeconds = tripEnd != nil && tripStart != nil ? tripEnd!.timeIntervalSince(tripStart!) : 0
  }
}

extension AddTripViewModel: CLLocationManagerDelegate {
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
        self.originTitle == ""
        else {
          return
      }
      
      // 4 (Store the current location and update the field)
      self.originTitle = firstPlace.name ?? "Current Location"
      self.currentLocation = loc.coordinate
      self.originLat = self.currentLocation!.latitude
      self.originLong = self.currentLocation!.longitude
      self.currentRegion = region
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Error requesting location: \(error.localizedDescription)")
  }
}

extension MKLocalSearchCompletion: Identifiable {}
