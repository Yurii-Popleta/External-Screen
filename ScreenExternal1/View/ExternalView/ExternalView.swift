//
//  ExternalView.swift
//  ScreenExternal1
//
//  Created by Admin on 28/02/2023.
//

import AVKit
import SwiftUI

struct ExternalView: View {
  @EnvironmentObject var viewModel: ViewModel
  
  var body: some View {
      ZStack {
          Color.white
          if viewModel.showOneSelectedItem == true && viewModel.imageUrl != nil || viewModel.loopAllPhotos == true && viewModel.imageUrl != nil {
              if let imageUrl = viewModel.imageUrl {
                  AsyncImage(url: URL(string: imageUrl)) { phase in
                      switch phase {
                      case .empty:
                          Image(systemName: "photo")
                              .systemImage(viewModel: viewModel)
                      case .success(let image):
                          image.externalImage()
                      case .failure( _):
                          Image(systemName: "photo")
                              .systemImage(viewModel: viewModel)
                      @unknown default:
                          EmptyView()
                      }
                  }
              }
          } else if viewModel.showOneSelectedItem == true && viewModel.videoUrl != nil || viewModel.loopAllVideos == true && viewModel.videoUrl != nil {
              VideoPlayer(player: viewModel.player)
                         .edgesIgnoringSafeArea(.all)
          } else if viewModel.loopAllFavorites == true {
              if let imageUrl = viewModel.imageUrl {
                  AsyncImage(url: URL(string: imageUrl)) { phase in
                      switch phase {
                      case .empty:
                          Image(systemName: "photo")
                              .systemImage(viewModel: viewModel)
                      case .success(let image):
                          image.externalImage()
                      case .failure( _):
                          Image(systemName: "photo")
                              .systemImage(viewModel: viewModel)
                      @unknown default:
                          EmptyView()
                      }
                  }
              } else if viewModel.videoUrl != nil {
                  VideoPlayer(player: viewModel.player)
                       .edgesIgnoringSafeArea(.all)
              }
          } else if viewModel.showPrevewImage == true && viewModel.showOneSelectedItem == true {
              Image("sanfrans")
                  .externalImage()
          } else if viewModel.showPrevewVideo == true && viewModel.showOneSelectedItem == true {
              let player = AVPlayer(url: Bundle.main.url(forResource: "Bridge", withExtension: "mp4")!)
              VideoPlayer(player: player).onAppear(perform: {
                  player.play()
              })
              .edgesIgnoringSafeArea(.all)
          }
      }.onAppear {
          viewModel.player.volume = 0.5
      }
   }
}
