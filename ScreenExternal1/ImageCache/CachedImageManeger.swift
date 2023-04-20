//
//  CachedImageManeger.swift
//  ScreenExternal1
//
//  Created by Admin on 28/03/2023.

import Foundation

final class CachedImageManager: ObservableObject {
    @Published private(set) var currentState: CurrentState?
    
    private let imageRetriver = ImageRetriver()
    
    @MainActor func load(_ imgUrl: String, cache: Imagecache = .share) async {
        
        self.currentState = .loading
        
        if let imageData = cache.object(forKey: imgUrl as NSString) {
            self.currentState = .success(data: imageData)
            return
        }
        do {
            let data = try await imageRetriver.fetch(imgUrl)
            self.currentState = .success(data: data)
            cache.set(object: data as NSData, forKey: imgUrl as NSString)
        } catch {
            self.currentState = .failed(error: error)
        }
    }
}

extension CachedImageManager {
    enum CurrentState {
        case loading
        case failed(error: Error)
        case success(data: Data)
    }
}
