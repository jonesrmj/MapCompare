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
        VStack (spacing: 25) {
            TextField("Origin", text: $viewModel.origin)
            TextField("Destination", text: $viewModel.destination)
            Button(action: {
                self.viewModel.calculateEstimates()
            }) {
                Text("Calculate")
            }
            
            Divider()
            
            Text(viewModel.appleEstimatedTime)
            Text(viewModel.googleEstimatedTime)
            Text(viewModel.hereEstimatedTime)
            
            Divider()
            
            Spacer()
        }
        .padding(.horizontal, 25)
        .padding(.top, 25)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: MapCompareViewModel())
    }
}
