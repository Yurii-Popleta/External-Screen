//
//  NetworkConnection.swift
//  ScreenExternal1
//
//  Created by Admin on 02/03/2023.
//

import Foundation
import Network

class NetworkMenager: ObservableObject {
    static let shared = NetworkMenager()
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkMenager")
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied ? true : false
            }
        }
        monitor.start(queue: queue)
    }
}
