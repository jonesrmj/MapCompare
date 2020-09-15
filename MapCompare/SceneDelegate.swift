//
//  SceneDelegate.swift
//  MapCompare
//
//  Created by Ryan Jones on 7/26/20.
//  Copyright © 2020 Ryan Jones. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  var appState = AppState()
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    let context = persistentContainer.viewContext
    let contentView = TripListView()
      .environment(\.managedObjectContext, context)
      .environmentObject(appState)
    
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(rootView: contentView)
      self.window = window
      window.makeKeyAndVisible()
    }
    
    if let activity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
      appState.restore(from: activity)
    }
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    saveContext()
  }
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "MapCompare")
    container.loadPersistentStores { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    return container
  }()
  
  func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
    let activity = NSUserActivity(activityType: Bundle.main.activityType)
    appState.store(in: activity)
    return activity
  }
  
  func saveContext() {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
}

extension Bundle {
  var activityType: String {
    return Bundle.main.infoDictionary?["NSUserActivityTypes"].flatMap { ($0 as? [String] )?.first } ?? ""
  }
}
