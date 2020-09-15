//
//  ContentView.swift
//  MapCompare
//
//  Created by Ryan Jones on 7/26/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import SwiftUI
import Combine

struct AddTripView: View {
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  @EnvironmentObject var appState: AppState
  
  @ObservedObject var viewModel: AddTripViewModel
  
  @State var originTitleInfo: AnyCancellable?
  @State var originLatInfo: AnyCancellable?
  @State var originLongInfo: AnyCancellable?
  @State var destinationTitleInfo: AnyCancellable?
  @State var destinationLatInfo: AnyCancellable?
  @State var destinationLongInfo: AnyCancellable?
  @State var tripStartInfo: AnyCancellable?
  @State var tripEndInfo: AnyCancellable?
  @State var appleEstimatedSecondsInfo: AnyCancellable?
  @State var googleEstimatedSecondsInfo: AnyCancellable?
  @State var hereEstimatedSecondsInfo: AnyCancellable?
  @State var bingEstimatedSecondsInfo: AnyCancellable?
  
  let onComplete : () -> Void
  
  var body: some View {
    NavigationView() {
      ZStack() {
        VStack(spacing: 25) {
          Group() {
            TextField("Origin", text: $viewModel.originTitle)
            TextField("Destination", text: $viewModel.destinationTitle)
            
            Button(action: {
              self.viewModel.calculateEstimates()
            }) {
              Text("Calculate")
            }
          }
          
          Divider()
          
          Group() {
            HStack {
              Text(TripModel.displayTimeFromSeconds(label: "Apple Estimate", seconds: viewModel.appleEstimatedSeconds))
              Spacer()
              ActivityIndicator(shouldAnimate: $viewModel.appleLoading)
            }
            HStack {
              Text(TripModel.displayTimeFromSeconds(label: "Google Estimate", seconds: viewModel.googleEstimatedSeconds))
              Spacer()
              ActivityIndicator(shouldAnimate: $viewModel.googleLoading)
            }
            HStack {
              Text(TripModel.displayTimeFromSeconds(label: "Here Estimate", seconds: viewModel.hereEstimatedSeconds))
              Spacer()
              ActivityIndicator(shouldAnimate: $viewModel.hereLoading)
            }
            HStack {
              Text(TripModel.displayTimeFromSeconds(label: "Bing Estimate", seconds: viewModel.bingEstimatedSeconds))
              Spacer()
              ActivityIndicator(shouldAnimate: $viewModel.bingLoading)
            }
          }
          
          Divider()
          
          Group() {
            VStack() {
              Button(action: {
                self.viewModel.openDirections()
              }) {
                Text("Start")
              } .padding(.horizontal, 25)
              
              Text(self.viewModel.tripStart != nil ? TripModel.dateFormatter.string(from: self.viewModel.tripStart!) : "N/A")
            }
            
            VStack() {
              Button(action: {
                self.viewModel.stop()
              }) {
                Text("Stop")
              } .padding(.horizontal, 25)
              
              Text(self.viewModel.tripEnd != nil ? TripModel.dateFormatter.string(from: self.viewModel.tripEnd!) : "N/A")
            }
          }
          
          Divider()
          
          HStack() {
            Text(TripModel.displayTimeFromSeconds(label: "Actual Travel Time", seconds: viewModel.actualTravelSeconds))
            Spacer()
          }
          
          Divider()
          
          Button(action: {
            self.addTripAction()
          }) {
            Text("Save")
          }
        }
        .padding(.horizontal, 25)
        .padding(.top, 25)
        
        // Popup
        if !viewModel.suggestedAddresses.isEmpty {
          VStack() {
            VStack(alignment: .leading) {
              ForEach(viewModel.suggestedAddresses.prefix(5)) { address in
                VStack(alignment: .leading) {
                  Text(address.title)
                  Text(address.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                  Divider()
                }
                .padding(5)
                .contentShape(Rectangle())
                .onTapGesture {
                  self.viewModel.setDestination(destination: address)
                }
              }
            }
            .background(Color.white)
            .cornerRadius(5)
            .offset(y: 110)
            .padding(.horizontal, 15)
            .shadow(radius: 5)
            
            Spacer()
          }
        }
      }
      .navigationBarTitle("Add Trip", displayMode: .inline)
      .navigationBarItems(leading: HStack {
        Button(action: {
          self.appState.isAddTripPresented.toggle()
        }) {
          Text("Cancel")
        }
      })
      .padding(.vertical, 20.0)
      .onAppear {
        if self.destinationTitleInfo == nil {
          self.destinationTitleInfo = self.viewModel.$destinationTitle
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .sink { value in
              self.appState.tripModel.destinationTitle = value
          }
        }
        if self.destinationLatInfo == nil {
          self.destinationLatInfo = self.viewModel.$destinationLat
            .receive(on: RunLoop.main)
            .sink { value in
              self.appState.tripModel.destinationLat = value
          }
        }
        if self.destinationLongInfo == nil {
          self.destinationLongInfo = self.viewModel.$destinationLong
            .receive(on: RunLoop.main)
            .sink { value in
              self.appState.tripModel.destinationLong = value
          }
        }
        if self.originTitleInfo == nil {
          self.originTitleInfo = self.viewModel.$originTitle
            .receive(on: RunLoop.main)
            .sink { value in
              self.appState.tripModel.originTitle = value
          }
        }
        if self.originLatInfo == nil {
          self.originLatInfo = self.viewModel.$originLat
            .receive(on: RunLoop.main)
            .sink { value in
              self.appState.tripModel.originLat = value
          }
        }
        if self.originLongInfo == nil {
          self.originLongInfo = self.viewModel.$originLong
            .receive(on: RunLoop.main)
            .sink { value in
              self.appState.tripModel.originLong = value
          }
        }
        if self.tripStartInfo == nil {
          self.tripStartInfo = self.viewModel.$tripStart
            .receive(on: RunLoop.main)
            .sink { value in
              self.appState.tripModel.tripStart = value
          }
        }
        if self.tripEndInfo == nil {
          self.tripEndInfo = self.viewModel.$tripEnd
            .receive(on: RunLoop.main)
            .sink { value in
              self.appState.tripModel.tripEnd = value
          }
        }
        if self.appleEstimatedSecondsInfo == nil {
          self.appleEstimatedSecondsInfo = self.viewModel.$appleEstimatedSeconds
            .receive(on: RunLoop.main)
            .sink { value in
              self.appState.tripModel.appleEstimatedSeconds = value
          }
        }
        if self.googleEstimatedSecondsInfo == nil {
          self.googleEstimatedSecondsInfo = self.viewModel.$googleEstimatedSeconds
            .receive(on: RunLoop.main)
            .sink { value in
              self.appState.tripModel.googleEstimatedSeconds = value
          }
        }
        if self.hereEstimatedSecondsInfo == nil {
          self.hereEstimatedSecondsInfo = self.viewModel.$hereEstimatedSeconds
            .receive(on: RunLoop.main)
            .sink { value in
              self.appState.tripModel.hereEstimatedSeconds = value
          }
        }
        if self.bingEstimatedSecondsInfo == nil {
          self.bingEstimatedSecondsInfo = self.viewModel.$bingEstimatedSeconds
            .receive(on: RunLoop.main)
            .sink { value in
              self.appState.tripModel.bingEstimatedSeconds = value
          }
        }
      }
      .onDisappear {
        self.destinationTitleInfo?.cancel()
        self.destinationTitleInfo = nil
        self.destinationLatInfo?.cancel()
        self.destinationLatInfo = nil
        self.destinationLongInfo?.cancel()
        self.destinationLongInfo = nil
        self.originTitleInfo?.cancel()
        self.originTitleInfo = nil
        self.originLatInfo?.cancel()
        self.originLatInfo = nil
        self.originLongInfo?.cancel()
        self.originLongInfo = nil
        self.tripStartInfo?.cancel()
        self.tripStartInfo = nil
        self.tripEndInfo?.cancel()
        self.tripEndInfo = nil
        self.appleEstimatedSecondsInfo?.cancel()
        self.appleEstimatedSecondsInfo = nil
        self.googleEstimatedSecondsInfo?.cancel()
        self.googleEstimatedSecondsInfo = nil
        self.hereEstimatedSecondsInfo?.cancel()
        self.hereEstimatedSecondsInfo = nil
        self.bingEstimatedSecondsInfo?.cancel()
        self.bingEstimatedSecondsInfo = nil
      }
    }
  }
  
  private func addTripAction() {
    onComplete()
  }
}
