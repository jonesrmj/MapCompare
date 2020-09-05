//
//  MailCompose.swift
//  MapCompare
//
//  Created by Ryan Jones on 9/5/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import SwiftUI
import UIKit
import MessageUI

struct MailView: UIViewControllerRepresentable {
  
  @Environment(\.presentationMode) var presentation
  @Binding var result: Result<MFMailComposeResult, Error>?
  
  class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    
    @Binding var presentation: PresentationMode
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    init(presentation: Binding<PresentationMode>,
         result: Binding<Result<MFMailComposeResult, Error>?>) {
      _presentation = presentation
      _result = result
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
      defer {
        $presentation.wrappedValue.dismiss()
      }
      guard error == nil else {
        self.result = .failure(error!)
        return
      }
      self.result = .success(result)
    }
  }
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(presentation: presentation,
                       result: $result)
  }
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
    let vc = MFMailComposeViewController()
    vc.mailComposeDelegate = context.coordinator
    vc.setSubject("MapCompare Trip Data")
    let fileManager = FileManager.default
    let directory = fileManager.urls( for: .documentDirectory, in: .userDomainMask)[0]
    let path = directory.appendingPathComponent("trip").appendingPathExtension("csv")
    if let data = NSData(contentsOf: path) {
      vc.addAttachmentData(data as Data, mimeType: "application/csv", fileName: "trip.csv")
    }
    return vc
  }
  
  func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                              context: UIViewControllerRepresentableContext<MailView>) {
    
  }
}
