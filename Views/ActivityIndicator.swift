//
//  ActivityIndicator.swift
//  MapCompare
//
//  Created by Ryan Jones on 8/8/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import Foundation
import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
  @Binding var shouldAnimate: Bool
  
  func makeUIView(context: Context) -> UIActivityIndicatorView {
    return UIActivityIndicatorView()
  }
  
  func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
    if self.shouldAnimate {
      uiView.startAnimating()
    } else {
      uiView.stopAnimating()
    }
  }
}
