//
//  ContentView.swift
//  ScreenExternal1
//
//  Created by Admin on 17/02/2023.

import SwiftUI
import AVKit
import MediaPlayer

struct ContentView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date)]) var photos: FetchedResults<Photo>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date)]) var videos: FetchedResults<Video>
    @StateObject var viewModel = ViewModel.shared

    var body: some View {
        VStack {
            TabView() {
                PictureView(viewModel: viewModel, photos: photos)
                    .tabItem {
                        Label("Pictures", systemImage: "photo")
                    }.tag(0)
                    .onAppear {
                        viewModel.tabSelected = 0
                    }
                VideoView(viewModel: viewModel, videos: videos)
                    .tabItem {
                        Label("Videos", systemImage: "video")
                    }.tag(1)
                    .onAppear {
                        viewModel.tabSelected = 1
                    }
                FavoritesView(viewModel: viewModel, photos: photos, videos: videos)
                    .tabItem {
                        Label("Favorites", systemImage: "star.fill")
                    }.tag(2)
                    .onAppear {
                        viewModel.tabSelected = 2
                    }
            }.onAppear {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.backgroundColor = UIColor(named: "color1")
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                UITabBar.appearance().standardAppearance = tabBarAppearance
                UITabBar.appearance().barTintColor = .white
            }
            .accentColor(Color("color4"))
        }.onAppear {
            viewModel.setFavElements(photos: photos, videos: videos)
        }
        .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
