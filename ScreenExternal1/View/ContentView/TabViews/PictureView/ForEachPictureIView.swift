//
//  ImageView.swift
//  ScreenExternal1
//
//  Created by Admin on 25/02/2023.
//

import SwiftUI
import UIKit
import CoreData
import FirebaseStorage
import AVFoundation

 struct ForEachPictureIView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var viewModel: ViewModel
    let photos: FetchedResults<Photo>
     
     @State var can: Bool = false
    
    var body: some View {
            ForEach(photos) { photo in
                    if let urlString = photo.imageUrl {
                       ZStack() {
                           CachedPhotoView(urlString: urlString) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                        image.normalImage(viewModel: viewModel)
                                case .failure( _):
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
                                        viewModel.playAction(photos: photos, photo: photo, video: nil, videos: nil, isFavorites: false)
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
                                            viewModel.deleteAlertPhoto = true
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
                        
                         }.alert("Delete this item?", isPresented: $viewModel.deleteAlertPhoto) {
                           Button("Delete", role: .destructive) {
                               viewModel.deleteItemFirebase(photo: viewModel.photo, video: nil, viewContext: viewContext)
                           }
                       }
                    }
                }
            }
        }
