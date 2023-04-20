//
//  FavoritesView.swift
//  ScreenExternal1
//
//  Created by Admin on 28/02/2023.

import SwiftUI
import UIKit
import CoreData
import FirebaseStorage
import AVFoundation

struct ForEachFavoritesIView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var viewModel: ViewModel
    let photos: FetchedResults<Photo>
    let videos: FetchedResults<Video>
    
    var body: some View {
        let elements = viewModel.elements()
        ForEach(0..<elements.count, id: \.self) { index in
            ZStack {
                if elements[index].data is Photo, let photo = elements[index].data as? Photo {
                    if let urlString = photo.imageUrl {
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
                                    Text(" "+photo.name!+" ")
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
                                            viewModel.isfavorite(photo: photo, video: nil, viewContext: viewContext)
                                        } label: {
                                            Image(systemName: photo.isFavorite ? "star.fill" : "star")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(Color("color1"))
                                                .padding(4)
                                                
                                        }
                            }.frame(height: (viewModel.frame().height-10)/3)

                            HStack() {
                                Button {
                                    viewModel.playAction(photos: photos, photo: photo, video: nil, videos: nil, isFavorites: true)
                                } label: {
                                    Image(systemName: photo.play ? "pause.circle" : "play.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Color("color1"))
                                        .bold()
                                }
                            }.frame(height: (viewModel.frame().height-10)/3)
                            
                            HStack()  {
                                Spacer()
                                    Button {
                                        viewModel.photo = photo
                                        viewModel.deleteAlertFavotitePH = true
                                    } label: {
                                        Image(systemName: "trash.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color("color1").opacity(0.8))
                                            .padding(6)
                                    }
                            }.frame(width: viewModel.frame().width-10, height: (viewModel.frame().height-10)/3)
                             .alert("Delete this item?", isPresented: $viewModel.deleteAlertFavotitePH) {
                                    Button("Delete", role: .destructive) {
                                        viewModel.deleteItemFirebase(photo: viewModel.photo, video: nil, viewContext: viewContext)
                                    }
                                }

                        }.frame(width: viewModel.frame().width-10, height:  viewModel.frame().height-10, alignment: .center)
                            .clipped()
                            .contentShape(Rectangle())
                        
                    }
                } else if elements[index].data is Video, let video = elements[index].data as? Video {
                    if let thumbUrlString = video.thumbImage {
                        CachedPhotoView(urlString: thumbUrlString) { phase in
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
                                    viewModel.playAction(photos: nil, photo: nil, video: video, videos: videos, isFavorites: true)
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
                                        viewModel.deleteAlertFavotiteVD = true
                                    } label: {
                                        Image(systemName: "trash.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color("color1").opacity(0.8))
                                            .padding(6)
                                    }
                            }.frame(width: viewModel.frame().width-10, height: (viewModel.frame().height-10)/3)
                             .alert("Delete this item?", isPresented: $viewModel.deleteAlertFavotiteVD) {
                                    Button("Delete", role: .destructive) {
                                        viewModel.deleteItemFirebase(photo: nil, video: viewModel.video, viewContext: viewContext)
                                    }
                                }
                        }.frame(width: viewModel.frame().width-10, height:  viewModel.frame().height-10, alignment: .center)
                            .clipped()
                            .contentShape(Rectangle())
                    }
                }
            }
        }
    }
}
