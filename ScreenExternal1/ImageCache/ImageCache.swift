//
//  ImageCache.swift
//  ScreenExternal1
//
//  Created by Admin on 28/03/2023.
//

import Foundation

class Imagecache {
    
    typealias CacheType = NSCache<NSString, NSData>
    
    static let share = Imagecache()
    
    private init() {}
    
    private lazy var cache: CacheType = {
        let cache = CacheType()
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
        return cache
    }()
    
    func object(forKey key: NSString) -> Data? {
        cache.object(forKey: key) as? Data
    }
    
    func set(object: NSData, forKey key: NSString) {
        cache.setObject(object, forKey: key)
    }
}
