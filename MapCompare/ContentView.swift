//
//  ContentView.swift
//  MapCompare
//
//  Created by Ryan Jones on 7/26/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  @Environment(\.presentationMode) var presentationMode

  @ObservedObject var viewModel = MapCompareViewModel()
  
  @Binding var isAddTripPresented: Bool
  
  let onComplete : (TripModel) -> Void
  
  var body: some View {
    NavigationView {
      ZStack() {
        VStack(spacing: 25) {
          Group() {
            TextField("Origin", text: $viewModel.originDisplay)
            TextField("Destination", text: $viewModel.destinationDisplay)
            
            Button(action: {
              self.viewModel.calculateEstimates()
            }) {
              Text("Calculate")
            }
          }
          
          Divider()
          
          Group() {
            HStack {
              Text(viewModel.appleEstimatedTimeDisplay)
              Spacer()
              ActivityIndicator(shouldAnimate: $viewModel.appleLoading)
            }
            HStack {
              Text(viewModel.googleEstimatedTimeDisplay)
              Spacer()
              ActivityIndicator(shouldAnimate: $viewModel.googleLoading)
            }
            HStack {
              Text(viewModel.hereEstimatedTimeDisplay)
              Spacer()
              ActivityIndicator(shouldAnimate: $viewModel.hereLoading)
            }
            HStack {
              Text(viewModel.bingEstimatedTimeDisplay)
              Spacer()
              ActivityIndicator(shouldAnimate: $viewModel.bingLoading)
            }
          }
          
          Divider()
          
          Group() {
            HStack() {
              Button(action: {
                self.viewModel.openDirections()
              }) {
                Text("Start")
              } .padding(.horizontal, 25)
              
              Button(action: {
                self.viewModel.stop()
              }) {
                Text("Stop")
              } .padding(.horizontal, 25)
            }
          }
          
          Divider()
          
          HStack() {
            Text(viewModel.actualTravelTimeDisplay)
            Spacer()
          }
          
          Divider()
          
          Button(action: {
            self.addTripAction()
          }) {
            Text("Save")
          }
          
          Spacer()
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
              //Spacer()
            }
            .background(Color.white)
            .cornerRadius(5)
            .offset(y: 100)
            .padding(.horizontal, 15)
            .shadow(radius: 5)

            Spacer()
          }
        }
      }
      .navigationBarTitle(Text("Add Trip"), displayMode: .inline)
      .navigationBarItems(leading: HStack {
        Button(action: {
          self.isAddTripPresented.toggle()
        }) {
          Text("Cancel")
        }
      })
    }
  }
  
  private func addTripAction() {
    onComplete(
      viewModel.trip
    )
  }
}
