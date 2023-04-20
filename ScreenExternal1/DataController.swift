//
//  DataController.swift
//  ScreenExternal1
//
//  Created by Admin on 23/02/2023.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let conteiner = NSPersistentContainer(name: "CoreData")
    
    init() {
        conteiner.loadPersistentStores { description, error in
            if let error = error {
                print("Core data failed to load: \(error.localizedDescription)")
            } else {
                print("success load core data ")
            }
        }
    }
}
