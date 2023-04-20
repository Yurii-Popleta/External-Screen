//
//  Favorite.swift
//  ScreenExternal1
//
//  Created by Admin on 17/02/2023.

import SwiftUI
import SwiftUI
import FirebaseStorage
import CoreData

struct FavoritesView: View {
    @ObservedObject var viewModel: ViewModel
    let photos: FetchedResults<Photo>
    let videos: FetchedResults<Video>
    @Environment(\.managedObjectContext) var viewContext
    
    var body: some View {
        NavigationView() {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color("color4"), Color("color1")]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea(.all, edges: .all)
            
            VStack() {
                ScrollViewReader { scrollView in
                    ScrollView() {
                        LazyVGrid(columns: viewModel.colums, spacing: 10) {
                            //Default image
                            ZStack {
                                Image("sanfrans")
                                    .resizable()
                                    .frame(width: viewModel.frame().width, height: viewModel.frame().height)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(10)
                              
                                VStack(spacing: 0) {
                                    HStack() {
                                        VStack {
                                            Text(" San Francisco  ")
                                                .font(.system(size: ((viewModel.frame().height-10)/7), weight: .semibold, design:    .default))
                                                .foregroundColor(Color.white)
                                                .clipped()
                                                .lineLimit(1)
                                                .opacity(0.8)
                                                .padding(3)
                                                .background {
                                                    Color.gray
                                                         .opacity(0.3)
                                                }.cornerRadius(7)
                                            Spacer()
                                        }.frame(height: (viewModel.frame().height-10)/3)
                                            Spacer()
                                                    Image(systemName: "star.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundColor(Color("color1"))
                                                        .padding(4)
                                    }.frame(height: (viewModel.frame().height-10)/3)

                                    HStack() {
                                        Button {
                                            for video in videos {
                                                video.play = false
                                            }
                                            for photo in photos {
                                                photo.play = false
                                            }
                                            viewModel.player.pause()
                                            viewModel.videoUrl = nil
                                            viewModel.imageUrl = nil
                                            viewModel.loopAllVideos = false
                                            viewModel.textExist = false
                                            viewModel.showPrevewVideo = !viewModel.showPrevewVideo
                                        } label: {
                                            Image(systemName: viewModel.showPrevewVideo ? "pause.circle" : "play.circle")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(Color("color1"))
                                                .bold()
                                        }
                                    }.frame(height: (viewModel.frame().height-10)/3)
                                      Spacer()
                                    
                                }.frame(width: viewModel.frame().width-10, height:  viewModel.frame().height-10, alignment: .center)
                                    .clipped()
                                    .contentShape(Rectangle())
                            }
                            if viewModel.checkNetwork() && viewModel.showFavorites == true {
                                ForEachFavoritesIView(viewModel: viewModel, photos: photos, videos: videos)

                            }
                        }.padding(.leading, 10)
                            .padding(.trailing, 10)
                            .padding(.top, 60)
                            .padding(.bottom, 10)
                            .shadow(color: .gray, radius: 8, x: 0, y: 0)
                    }
                    .actionSheet(isPresented: $viewModel.sheetPlayItem) {
                            ActionSheet(title: Text("Choose how to present the item"), message: nil, buttons: [.default(Text("Show one selected item"), action: {
                                viewModel.showOneSelectedItem = true
                                viewModel.loopAllFavorites = false
                                viewModel.color = Color("color2")
                            }), .default(Text("Loop all items"), action: {
                                viewModel.showPrevewVideo = false
                                viewModel.showOneSelectedItem = false
                                viewModel.color = Color("color1")
                                if viewModel.elements().isEmpty == false {
                                    viewModel.countOfLoopingItem = 0
                                    viewModel.resetItems(media: .favorites, photos: nil, videos: nil)
                                    viewModel.loopAllFavorites = true
                                    viewModel.loopAllfavorites()
                                    viewModel.color = Color("color4").opacity(0.3)
                                }
                            }), .destructive(Text("Stop"), action: {
                                viewModel.cancelAllPlaying(photos: photos, videos: videos)
                            })])
                        }
                    
                    if viewModel.textExist {
                        VStack {
                            ZStack {
                                Color.gray
                                    .opacity(0.2)
                                ScrollView {
                                    Text(viewModel.showingTextNow)
                                        .font(.system(.body, design: .default, weight: .medium))
                                        .foregroundColor(Color("color1"))
                                        .padding(.top, 10)
                                        .padding(.leading, 15)
                                        .padding(.trailing, 15)
                                        .padding(.bottom, 10)
                                }
                            }
                            .frame(width: UIScreen.screenWidth - 20, height: 100, alignment: .bottom)
                            .cornerRadius(10)
                            .padding(.bottom, 10)
                        }
                    }
                }.frame(maxWidth: .infinity)
                
                if viewModel.checkNetwork() == false {
                    Image(systemName: "wifi.slash")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.gray)
                        .opacity(0.7)
                        .frame(width: 200, height: 200, alignment: .center)
                    Text("Update your internet connection")
                        .foregroundColor(Color.black)
                        .opacity(0.7)
                        .font(.system(size: 18, weight: .medium, design: .default))
                    Spacer().frame(height: 200)
                }
                
            }
                VStack {
                    CastomtoolbarView(viewModel: viewModel)
                    Spacer()
                }
                
               }
        }
        .onAppear(perform: {
            viewModel.showFavorites = true
        })
        .onDisappear {
            viewModel.cancelAllPlaying(photos: photos, videos: videos)
            viewModel.showFavorites = false
        }
    }
}
