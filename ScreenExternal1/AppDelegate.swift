//
//  AppDelegate.swift
//  ScreenExternal1
//
//  Created by Admin on 23/02/2023.
//

import Foundation
import UIKit
import FirebaseCore

class FSAppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    // ...
      FirebaseApp.configure()
    return true
  }

}
