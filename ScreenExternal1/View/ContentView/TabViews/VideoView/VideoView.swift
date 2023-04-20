//
//  Video.swift
//  ScreenExternal1
//
//  Created by Admin on 17/02/2023.

import UIKit
import SwiftUI
import FirebaseStorage
import CoreData

struct VideoView: View {
      @ObservedObject var viewModel: ViewModel
      let videos: FetchedResults<Video>
      @Environment(\.managedObjectContext) var viewContext
      @Namespace var addView
    
      var body: some View {
          NavigationView() {
              ZStack {
                  LinearGradient(gradient: Gradient(colors: [Color("color4"), Color("color1")]), startPoint: .top, endPoint: .bottom)
                      .ignoresSafeArea(.all, edges: .all)
              
              VStack() {
                  ScrollViewReader { scrollview in
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
                                              viewModel.player.pause()
                                              viewModel.videoUrl = nil
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
                              
                              if viewModel.checkNetwork() {
                                  ForEachVideoView(viewModel: viewModel, videos: videos).onAppear {
                                      scrollview.scrollTo(addView)
                                  }
                              }
                              // add new video
                              ZStack() {
                                 // Image(systemName: "video")
                                  Image("video")
                                      .resizable()
                                      .scaledToFit()
                                      .padding(14)
                                      .frame(width: viewModel.frame().width, height: viewModel.frame().height)
                                      .background(Color("color1").opacity(0.3))
                                      .opacity(0.5)
                                      .foregroundColor(Color.white)
                                      .cornerRadius(10)
                                      .onTapGesture {
                                          viewModel.sheetAddNewItemVD = true
                                      }
                              }.id(addView)
                                  .sheet(isPresented: $viewModel.showVideoLibraryPicker, content: {
                                      ImagePicker(isPresented: $viewModel.showVideoLibraryPicker, sourceType: .photoLibrary, viewContext: viewContext, isVideo: true, viewModel: viewModel)
                                  })
                                  .sheet(isPresented: $viewModel.showVideoCameraPicker, content: {
                                      ImagePicker(isPresented: $viewModel.showVideoCameraPicker, sourceType: .camera, viewContext: viewContext, isVideo: true, viewModel: viewModel)
                                  })
                                  .alert("Rename the video and add text if necessary", isPresented: $viewModel.alertWithTextVideo) {
                                      TextField((videos.last?.name ?? ""), text: $viewModel.nameForItem).foregroundColor(.black)
                                      TextField("Write a text for the video", text: $viewModel.textForItem).foregroundColor(.black)
                                      Button("Cancel", role: .cancel) {
                                          scrollview.scrollTo(addView)
                                      }
                                      Button("Update") {
                                          viewModel.updateItemNameText(photos: nil, videos: videos, viewContext: viewContext)
                                          scrollview.scrollTo(addView)
                                      }
                                  }
                          }
                          .padding(.leading, 10)
                          .padding(.trailing, 10)
                          .padding(.top, 60)
                          .padding(.bottom, 10)
                          .shadow(color: .gray, radius: 8, x: 0, y: 0)
                          
                      }.actionSheet(isPresented: $viewModel.sheetPlayItem) {
                          ActionSheet(title: Text("Choose how to present the video"), message: nil, buttons: [.default(Text("Show one selected video"), action: {
                              viewModel.showOneSelectedItem = true
                              viewModel.loopAllVideos = false
                              viewModel.color = Color("color2")
                          }), .default(Text("Loop all videos"), action: {
                              viewModel.showOneSelectedItem = false
                              viewModel.showPrevewVideo = false
                              viewModel.color = Color("color1")
                              if videos.isEmpty == false {
                                  viewModel.resetItems(media: .video, photos: nil, videos: videos)
                                  viewModel.countOfLoopingItem = 0
                                  viewModel.loopAllVideos = true
                                  viewModel.loopAllVideos(videos: videos)
                                  viewModel.color = Color("color4").opacity(0.3)
                              }
                          }), .destructive(Text("Stop"), action: {
                              viewModel.cancelAllPlaying(photos: nil, videos: videos)
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
          .actionSheet(isPresented: $viewModel.sheetAddNewItemVD) {
              ActionSheet(title: Text("How do you want to add an video?"), buttons: [.cancel(), .default(Text("Add from the library"), action: {
                  viewModel.showVideoLibraryPicker = true
              }), .default(Text("Take a new video"), action: {
                  viewModel.showVideoCameraPicker = true
              })])
          }
          .onDisappear {
              viewModel.cancelAllPlaying(photos: nil, videos: videos)
          }
      }
   }


