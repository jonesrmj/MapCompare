//
//  StatView.swift
//  MapCompare
//
//  Created by Ryan Jones on 9/6/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import Foundation
import SwiftUI

struct StatView: View {
  @Environment(\.presentationMode) var presentation
  
  @ObservedObject var viewModel = StatViewModel()
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack() {
        Text("Apple Average:")
        Spacer()
        Text(viewModel.appleDeltaDisplay)
      }
      HStack() {
        Text("Google Average:")
        Spacer()
        Text(viewModel.googleDeltaDisplay)
      }
      HStack() {
        Text("Here Average:")
        Spacer()
        Text(viewModel.hereDeltaDisplay)
      }
      HStack() {
        Text("Bing Average:")
        Spacer()
        Text(viewModel.bingDeltaDisplay)
      }
    }
  }
}
