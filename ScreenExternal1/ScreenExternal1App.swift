//  ScreenExternal1App.swift
//  ScreenExternal1
//  Created by Admin on 17/02/2023.

import SwiftUI
import FirebaseAuth

@main
 struct ScreenExternal1App: App {
   @UIApplicationDelegateAdaptor var delegate: FSAppDelegate
   @StateObject var dataController = DataController()
   @State var isActive = false
   @State var intro = UserDefaults.standard.bool(forKey: "intro")
     
    var body: some Scene {
        WindowGroup {
            if isActive {
                if intro == false {
                    IntroPageView(intro: $intro)
                } else if intro == true {
                    ContentView()
                        .environment(\.managedObjectContext, dataController.conteiner.viewContext)
                        .onAppear {
                            login()
                        }
                }
            } else {
                SplashScreenView().onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                        self.isActive = true
                    }
                }
            }
          
        }
    }
     
     func login() {
         Auth.auth().signInAnonymously { result, error in
             if error != nil {
                 print(error!.localizedDescription)
                 return
             }
             print("Success = \(result!.user.uid)")
         }
     }
}

