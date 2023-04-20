//
//  ImageVideos.swift
//  ScreenExternal1
//
//  Created by Admin on 27/02/2023.
//

import SwiftUI
import UIKit
import CoreData
import FirebaseStorage
import AVFoundation

struct ForEachVideoView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var viewModel: ViewModel
    let videos: FetchedResults<Video>
    
    var body: some View {
            ForEach(videos) { video in
                if let urlString = video.thumbImage {
                    ZStack {
                        CachedPhotoView(urlString: urlString) { phase in
                            switch phase {
                            case .empty:
                                 ProgressView()
                            case .success(let image):
                                    image.normalImage(viewModel: viewModel)
                            case .failure(_):
                                 ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        
                        VStack(spacing: 0) {
                            HStack() {
                                VStack {
                                    Text(" "+video.name!+" ")
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
                                        Button {
                                            viewModel.isfavorite(photo: nil, video: video, viewContext: viewContext)
                                        } label: {
                                            Image(systemName: video.isFavorite ? "star.fill" : "star")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(Color("color1"))
                                                .padding(4)
                                                
                                        }
                            }.frame(height: (viewModel.frame().height-10)/3)

                            HStack() {
                                Button {
                                    viewModel.playAction(photos: nil, photo: nil, video: video, videos: videos, isFavorites: false)
                                } label: {
                                    Image(systemName: video.play ? "pause.circle" : "play.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Color("color1"))
                                        .bold()
                                }
                            }.frame(height: (viewModel.frame().height-10)/3)
                            
                            HStack()  {
                                Spacer()
                                    Button {
                                        viewModel.video = video
                                        viewModel.deleteAlertVideo = true
                                    } label: {
                                        Image(systemName: "trash.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color("color1").opacity(0.8))
                                            .padding(6)
                                    }
                            }.frame(width: viewModel.frame().width-10, height: (viewModel.frame().height-10)/3)

                        }.frame(width: viewModel.frame().width-10, height:  viewModel.frame().height-10, alignment: .center)
                            .clipped()
                            .contentShape(Rectangle())
                    
                     }.alert("Delete this item?", isPresented: $viewModel.deleteAlertVideo) {
                       Button("Delete", role: .destructive) {
                           viewModel.deleteItemFirebase(photo: nil, video: viewModel.video, viewContext: viewContext)
                       }
                    }
                }
            }
        }
    }
