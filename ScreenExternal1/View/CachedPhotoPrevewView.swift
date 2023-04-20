//
//  AsyncPhoto.swift
//  ScreenExternal1
//
//  Created by Admin on 10/03/2023.
//

import SwiftUI

struct CachedPhotoView<Content: View>: View {
    @StateObject private var manager = CachedImageManager()
    var urlString: String
    @ViewBuilder let content: (AsyncImagePhase) -> Content
    
    var body: some View {
        ZStack {
            switch manager.currentState {
            case .loading:
                content(.empty)
            case .success(let data):
                if let image = UIImage(data: data) {
                    content(.success(Image(uiImage: image)))
                } else {
                    content(.failure(CachedImageError.invalidData))
                }
            case .failed(let error):
                content(.failure(error))
            default:
                content(.empty)
            }
        }.task {
            await manager.load(urlString)
        }
    }
}

extension CachedPhotoView {
    enum CachedImageError: Error {
         case invalidData
    }
}

enum Media {
    case photo
    case video
    case favorites
    case externalScreen
}
