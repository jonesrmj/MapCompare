//
//  ContentView.swift
//  MapCompare
//
//  Created by Ryan Jones on 7/26/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject var viewModel: MapCompareViewModel
  
  init(viewModel: MapCompareViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    ZStack() {
      VStack(spacing: 25) {
        Group() {
          TextField("Origin", text: $viewModel.origin)
          TextField("Destination", text: $viewModel.destination)
          
          Button(action: {
            self.viewModel.calculateEstimates()
          }) {
            Text("Calculate")
          }
        }
        
        Divider()
        
        Group() {
          HStack {
            Text(viewModel.appleEstimatedTime)
            Spacer()
            ActivityIndicator(shouldAnimate: $viewModel.appleLoading)
          }
          HStack {
            Text(viewModel.googleEstimatedTime)
            Spacer()
            ActivityIndicator(shouldAnimate: $viewModel.googleLoading)
          }
          HStack {
            Text(viewModel.hereEstimatedTime)
            Spacer()
            ActivityIndicator(shouldAnimate: $viewModel.hereLoading)
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
          Text(viewModel.actualTravelTime)
          Spacer()
        }
        
        Spacer()
      }
      .padding(.horizontal, 25)
      .padding(.top, 25)
      
      // Popup
      if !viewModel.suggestedAddresses.isEmpty {
        VStack(alignment: .leading) {
          List(viewModel.suggestedAddresses.prefix(5)) { address in
            VStack(alignment: .leading) {
              Text(address.title)
              Text(address.subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
                .onTapGesture {
                  self.viewModel.setDestination(destination: address)
              }
            }
          }
          .frame(height: CGFloat(viewModel.suggestedAddresses.count > 5 ? 250 : viewModel.suggestedAddresses.count * 50))
          Spacer()
        }
        .padding()
        .offset(y: 90) // 40 for origin
        .shadow(radius: 5)
        .cornerRadius(5)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(viewModel: MapCompareViewModel())
  }
}
