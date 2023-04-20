//
//  Picture.swift
//  ScreenExternal1
//
//  Created by Admin on 17/02/2023.

import UIKit
import SwiftUI
import FirebaseStorage
import CoreData

struct PictureView: View {
    @ObservedObject var viewModel: ViewModel
    let photos: FetchedResults<Photo>
    @Environment(\.managedObjectContext) var viewContext
    @Namespace var addView
  //  @State private var airPlayView = AirPlayView()
    
    var body: some View {
        NavigationView() {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color("color4"), Color("color1")]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea(.all, edges: .all)
                  
                VStack() {
                    ScrollViewReader { scrollView in
                        ScrollView() {
                            LazyVGrid(columns: viewModel.colums, spacing: 10) {
                                ZStack {
                                    //Default image
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
                                                        Image(systemName: "star")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .foregroundColor(Color("color1"))
                                                            .padding(4)
                                        }.frame(height: (viewModel.frame().height-10)/3)

                                        HStack() {
                                            Button {
                                                for photo in photos {
                                                    photo.play = false
                                                }
                                                viewModel.imageUrl = nil
                                                viewModel.loopAllPhotos = false
                                                viewModel.textExist = false
                                                viewModel.showPrevewImage = !viewModel.showPrevewImage
                                            } label: {
                                                Image(systemName: viewModel.showPrevewImage ? "pause.circle" : "play.circle")
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
                                //
                                if viewModel.checkNetwork() {
                                    ForEachPictureIView(viewModel: viewModel, photos: photos).onAppear {
                                        scrollView.scrollTo(addView)
                                    }
                                }
                                ZStack() {
                                    // add new photo
                                 //   Image(systemName: "photo")
                                    Image("camera")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(15)
                                        .frame(width: viewModel.frame().width, height: viewModel.frame().height)
                                        .background(Color("color1").opacity(0.3))
                                        .opacity(0.5)
                                        .foregroundColor(Color.white)
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            viewModel.sheetAddNewItemPH = true
                                        }
                                }.id(addView)
                                    .sheet(isPresented: $viewModel.showPhotoLibraryPicker, content: {
                                        ImagePicker(isPresented: $viewModel.showPhotoLibraryPicker, sourceType: .photoLibrary, viewContext: viewContext, isVideo: false, viewModel: viewModel)
                                    })
                                    .sheet(isPresented: $viewModel.showPhotoCameraPicker, content: {
                                        ImagePicker(isPresented: $viewModel.showPhotoCameraPicker, sourceType: .camera, viewContext: viewContext, isVideo: false, viewModel: viewModel)
                                    })
                                    .alert("Rename the photo and add text if necessary", isPresented: $viewModel.alertWithTextPhoto) {
                                        TextField((photos.last?.name ?? ""), text: $viewModel.nameForItem).foregroundColor(.black)
                                        TextField("Write a text for the photo", text: $viewModel.textForItem).foregroundColor(.black)
                                        Button("Cancel") {
                                            scrollView.scrollTo(addView)
                                        }
                                        Button("Update") {
                                            viewModel.updateItemNameText(photos: photos, videos: nil, viewContext: viewContext)
                                            scrollView.scrollTo(addView)
                                        }
                                    }
                            }
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .padding(.top, 60)
                            .padding(.bottom, 10)
                            .shadow(color: .gray, radius: 8, x: 0, y: 0)
                            
                        }
                        .actionSheet(isPresented: $viewModel.sheetPlayItem) {
                            ActionSheet(title: Text("Choose how to present the photo"), message: nil, buttons: [
                                        .default(Text("Show one selected photo"), action: {
                                        viewModel.showOneSelectedItem = true
                                        viewModel.loopAllPhotos = false
                                        viewModel.color = Color("color2")
                                    }), .default(Text("Loop all photos"), action: {
                                        viewModel.showOneSelectedItem = false
                                        viewModel.showPrevewImage = false
                                        viewModel.color = Color("color1")
                                        if photos.isEmpty == false {
                                            viewModel.resetItems(media: .photo, photos: photos, videos: nil)
                                            viewModel.countOfLoopingItem = 0
                                            viewModel.loopAllPhotos = true
                                            viewModel.color = Color("color4").opacity(0.3)
                                            viewModel.loopThoughAllPhotos(photos: photos)
                                        }
                                    }), .destructive(Text("Stop"), action: {
                                        viewModel.cancelAllPlaying(photos: photos, videos: nil)
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
        .onDisappear {
            viewModel.cancelAllPlaying(photos: photos, videos: nil)
        }
        .actionSheet(isPresented: $viewModel.sheetAddNewItemPH) {
            ActionSheet(title: Text("How do you want to add an image?"), buttons: [.cancel(), .default(Text("Add from the library"), action: {
                viewModel.showPhotoLibraryPicker = true
            }), .default(Text("Take a new photo"), action: {
                viewModel.showPhotoCameraPicker = true
            })])
        }

    }
}
