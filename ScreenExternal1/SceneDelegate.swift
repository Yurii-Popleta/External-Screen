//
//  SceneDelegate.swift
//  ScreenExternal1
//
//  Created by Admin on 28/02/2023.
//

import SwiftUI

 class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  var imagesStore = ViewModel.shared
     
  func scene(_ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions) {
    print("second screen conected")
    guard let scene = scene as? UIWindowScene else {
       return
    }
      print("size of screen is \(scene.screen.nativeBounds)")
      imagesStore.screen = scene.screen.nativeBounds
    let content = ExternalView()
          .environmentObject(ViewModel.shared)
      
    window = UIWindow(windowScene: scene)
    window?.rootViewController = UIHostingController(rootView: content)
    window?.isHidden = false
  }
     
     func sceneDidDisconnect(_ scene: UIScene) {
         imagesStore.screen = nil
     }
}

