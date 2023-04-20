//
//  Content-ViewModel.swift
//  ScreenExternal1
//
//  Created by Admin on 02/03/2023.

import UIKit
import SwiftUI
import FirebaseStorage
import CoreData
import AVFoundation

 class ViewModel: ObservableObject {
    static let shared = ViewModel()
    
    var colums = [GridItem(.adaptive(minimum: (UIScreen.screenWidth-30)/2), spacing: 10)]
    var player = AVPlayer()
    @Published var screen: CGRect?
    @Published var tabSelected = 0
    @Published var showAirplay = false
    @Published var color: Color = Color("color1")
    @Published var deleteAlertPhoto = false
    @Published var deleteAlertVideo = false
    @Published var deleteAlertFavotitePH = false
    @Published var deleteAlertFavotiteVD = false
    @Published var showOneSelectedItem: Bool = false
    @Published var loopAllPhotos: Bool = false
    @Published var loopAllFavorites: Bool = false
    @Published var loopAllVideos: Bool = false
    @Published var imageUrl: String?
    @Published var sheetPlayItem = false
    @Published var sheetAddNewItemPH = false
    @Published var sheetAddNewItemVD = false
    @Published var showPhotoLibraryPicker = false
    @Published var showVideoLibraryPicker = false
    @Published var showPhotoCameraPicker = false
    @Published var showVideoCameraPicker = false
    @Published var showPrevewImage = false
    @Published var showPrevewVideo = false
    @Published var alertWithTextPhoto = false
    @Published var alertWithTextVideo = false
    @Published var showFavorites = false
    @Published var nameForItem = ""
    @Published var textForItem = ""
    @Published var textExist = false
    @Published var showingTextNow = ""
    @Published var countOfLoopingItem = 0
    @Published var elementsFav = [(data: Any, date: Date)]()
    @Published var photo: FetchedResults<Photo>.Element?
    @Published var video: FetchedResults<Video>.Element?
    @Published var videoUrl: String? {
        didSet {
            guard let videoUrl = videoUrl, let url = URL(string: videoUrl) else {
                           return
                       }
                       player = AVPlayer(url: url)
                       player.seek(to: .zero)
                       player.play()
            if screen == nil {
                player.volume = 0.0
            }
        }
    }
    
    func setFavElements(photos: FetchedResults<Photo>, videos: FetchedResults<Video>) {
            var new: [(data: Any, date: Date)] = []
            for photo in photos {
                if photo.isFavorite == true, let date = photo.date {
                    new.append((data: photo, date: date))
                }
            }
            for video in videos {
                if video.isFavorite == true, let date = video.date {
                    new.append((data: video, date: date))
                }
            }
            let final = new.sorted { first , second in
                first.date < second.date
            }
            elementsFav = final
    }
    
    func elements() -> [(data: Any, date: Date)] {
        let final = elementsFav.sorted { first , second in
                first.date < second.date
            }
            return final
    }
    
    func sizeExternalScreen() -> String {
        if let screenExist = screen {
            return "Screen is connected \(String(Int(screenExist.width))) x \(String(Int(screenExist.height)))"
        } else {
            return "External screen is not connected"
        }
    }
    
    func checkNetwork() -> Bool {
       return NetworkMenager.shared.isConnected
    }
    
    func frame() -> (width: CGFloat, height: CGFloat) {
        return (width: (UIScreen.screenWidth-30)/2, height: (UIScreen.screenWidth-25)/2/1.778)
    }
    
    func cancelAllPlaying(photos: FetchedResults<Photo>?, videos: FetchedResults<Video>?) {
        if let photos, let videos {
            for image in photos {
                image.play = false
            }
            for video in videos {
                video.play = false
            }
            showOneSelectedItem = false
            showPrevewVideo = false
            loopAllFavorites = false
            imageUrl = nil
            videoUrl = nil
        } else if let photos {
            for image in photos {
                image.play = false
            }
            showOneSelectedItem = false
            showPrevewImage = false
            loopAllPhotos = false
            imageUrl = nil
        } else if let videos {
            for video in videos {
                video.play = false
            }
            player.pause()
            showOneSelectedItem = false
            showPrevewVideo = false
            loopAllVideos = false
            videoUrl = nil
        }
        player.pause()
        textExist = false
        showingTextNow = ""
        color = Color("color1")
    }
    
    func updateItemNameText(photos: FetchedResults<Photo>?, videos: FetchedResults<Video>?, viewContext: NSManagedObjectContext) {
        if let photos {
            if nameForItem != "" {
                photos.last?.name = nameForItem
                nameForItem = ""
            }
            if textForItem != "" {
                photos.last?.text = textForItem
                textForItem = ""
            }
            do {
                try viewContext.save()
            } catch {
                print("\(error): Failure to save data")
            }
        }
        
        if let videos {
            if  nameForItem != "" {
                    videos.last?.name = nameForItem
                    nameForItem = ""
            }
            if textForItem != "" {
                    videos.last?.text = textForItem
                    textForItem = ""
            }
            do {
                try viewContext.save()
            } catch {
                print("\(error): Failure to save data")
            }
        }
    }
    
    func loopThoughAllPhotos(photos: FetchedResults<Photo>) {
        
        if loopAllPhotos == true {
                imageUrl = photos[countOfLoopingItem].imageUrl
                           photos[countOfLoopingItem].play = true
                
                if photos[countOfLoopingItem].text != "", let text = photos[countOfLoopingItem].text {
                    textExist = true
                    showingTextNow = text
                } else if photos[countOfLoopingItem].text == "" {
                    textExist = false
                    showingTextNow = ""
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5) {
                    if self.countOfLoopingItem < photos.count-1 {
                        self.countOfLoopingItem += 1
                        photos[self.countOfLoopingItem-1].play = false
                        self.loopThoughAllPhotos(photos: photos)
                    } else if self.countOfLoopingItem == photos.count-1 {
                        photos.last?.play = false
                        self.color = Color("color1")
                        self.loopAllPhotos = false
                        self.textExist = false
                        self.showingTextNow = ""
                        self.imageUrl = nil
                    }
                }
            }
        }
    
    func loopAllVideos(videos: FetchedResults<Video>) {
        if loopAllVideos == true {
            videoUrl = videos[countOfLoopingItem].videoUrl
            videos[countOfLoopingItem].play = true
            if let currentItem = player.currentItem {
               let time = currentItem.asset.duration
                
            if videos[countOfLoopingItem].text != "", let text = videos[countOfLoopingItem].text {
                textExist = true
                showingTextNow = text
            } else if videos[countOfLoopingItem].text == "" {
                textExist = false
                showingTextNow = ""
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+time.seconds) {
                if self.countOfLoopingItem < videos.count-1 {
                    self.countOfLoopingItem += 1
                    videos[self.countOfLoopingItem-1].play = false
                    self.loopAllVideos(videos: videos)
                } else if self.countOfLoopingItem == videos.count-1 {
                    videos.last?.play = false
                    self.loopAllVideos = false
                    self.color = Color("color1")
                    self.textExist = false
                    self.showingTextNow = ""
                    self.videoUrl = nil
                   }
               }
           }
       }
   }
    

    func loopAllfavorites() {
            if loopAllFavorites == true {
                if let photo = elements()[countOfLoopingItem].data as? Photo {
                    videoUrl = nil
                    imageUrl = photo.imageUrl
                    photo.play = true
                  
                    if photo.text != "", let text = photo.text {
                        textExist = true
                        showingTextNow = text
                    } else if photo.text == "" {
                        textExist = false
                        showingTextNow = ""
                    }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5) {
                        if self.countOfLoopingItem < self.elements().count-1 {
                            self.countOfLoopingItem += 1
                            let previousPhoto = self.elements()[self.countOfLoopingItem-1].data as? Photo
                            previousPhoto?.play = false
                            self.loopAllfavorites()
                        } else if self.countOfLoopingItem == self.elements().count-1 {
                            let lastPhoto = self.elements().last?.data as? Photo
                            lastPhoto?.play = false
                            self.color = Color("color1")
                            self.loopAllFavorites = false
                            self.imageUrl = nil
                        }
                    }
                } else if let video = elements()[countOfLoopingItem].data as? Video {
                    imageUrl = nil
                    videoUrl = video.videoUrl
                    video.play = true
                 if let currentItem = player.currentItem {
                    let time = currentItem.asset.duration
                     if video.text != "", let text = video.text {
                        textExist = true
                        showingTextNow = text
                    } else if video.text == "" {
                        textExist = false
                        showingTextNow = ""
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now()+time.seconds) {
                        if self.countOfLoopingItem < self.elements().count-1 {
                            self.countOfLoopingItem += 1
                            let previousVideo = self.elements()[self.countOfLoopingItem-1].data as? Video
                            previousVideo?.play = false
                            self.loopAllfavorites()
                        } else if self.countOfLoopingItem == self.elements().count-1 {
                            let lastPhoto = self.elements().last?.data as? Video
                            lastPhoto?.play = false
                            self.loopAllFavorites = false
                            self.color = Color("color1")
                            self.videoUrl = nil
                        }
                     }
                  }
               }
            }
         }
     
     func resetItems(media: Media, photos: FetchedResults<Photo>?, videos: FetchedResults<Video>?) {
         switch media {
         case .photo:
             if let photos {
                 for photo in photos {
                     photo.play = false
                 }
             }
         case .video:
             if let videos {
                 for video in videos {
                     video.play = false
                 }
             }
         case .favorites:
             for item in elements() {
                 if let photo = item.data as? Photo {
                     photo.play = false
                 } else if let video = item.data as? Video {
                     video.play = false
                 }
                 imageUrl = nil
                 videoUrl = nil
             }
         case .externalScreen:
             break
         }
         
     }
    
    func isfavorite(photo: FetchedResults<Photo>.Element?, video: FetchedResults<Video>.Element?, viewContext: NSManagedObjectContext) {
        showFavorites = false
        if let photo {
            if photo.isFavorite == false, let date = photo.date {
                elementsFav.append((data: photo, date: date))
            } else if photo.isFavorite == true, let date = photo.date {
                elementsFav.removeAll { result in
                    result.date == date
                }
            }
            photo.isFavorite = !photo.isFavorite
            do {
                try viewContext.save()
            } catch {
                print("\(error): Failure to save data")
            }
        }
       
        if let video {
            if video.isFavorite == false, let date = video.date {
                elementsFav.append((data: video, date: date))
            } else if video.isFavorite == true, let date = video.date {
                elementsFav.removeAll { result in
                    result.date == date
                }
            }
            video.isFavorite = !video.isFavorite
            do {
                try viewContext.save()
            } catch {
                print("\(error): Failure to save data")
            }
        }
        showFavorites = true
    }
    
     func playAction(photos: FetchedResults<Photo>?, photo: FetchedResults<Photo>.Element?, video: FetchedResults<Video>.Element?, videos: FetchedResults<Video>?, isFavorites: Bool) {
        // play photo
        if let photo, let photos {
            if photo.play == true {
                for isplay in photos {
                    isplay.play = false
                }
                if loopAllFavorites == true || loopAllPhotos {
                    color = Color("color1")
                }
                textExist = false
                imageUrl = nil
            } else if photo.play == false {
                if isFavorites {
                    for element in elements() {
                        if let video = element.data as? Video {
                              video.play = false
                              videoUrl = nil
                              player.pause()
                        }
                    }
                }
                
                for isplay in photos {
                    isplay.play = false
                }
                if let videos {
                    for isplay in videos {
                        isplay.play = false
                    }
                }
                if photo.text != "", let text = photo.text {
                    textExist = true
                    showingTextNow = text
                } else if photo.text == "" {
                    textExist = false
                    showingTextNow = ""
                }
                photo.play = true
                imageUrl = photo.imageUrl
                videoUrl = nil
            }
        }
        // play video
        if let video, let videos {
            if video.play == true {
                for isplay in videos {
                    isplay.play = false
                }
                if loopAllFavorites == true || loopAllVideos {
                    color = Color("color1")
                }
                player.pause()
                textExist = false
                videoUrl = nil
            } else if video.play == false {
                if isFavorites {
                    for element in elements() {
                        if let photo = element.data as? Photo {
                            photo.play = false
                            imageUrl = nil
                        }
                    }
                }
                player.pause()
                for isplay in videos {
                    isplay.play = false
                }
                if let photos {
                    for isplay in photos {
                        isplay.play = false
                    }
                }
                if video.text != "", let text = video.text {
                    textExist = true
                    showingTextNow = text
                } else if video.text == "" {
                    textExist = false
                    showingTextNow = ""
                }
                video.play = true
                videoUrl = video.videoUrl
                imageUrl = nil
            }
        }
        loopAllFavorites = false
        loopAllPhotos = false
        loopAllVideos = false
        showPrevewImage = false
        showPrevewVideo = false
    }
    
    func deleteItemFirebase(photo: FetchedResults<Photo>.Element?, video: FetchedResults<Video>.Element?, viewContext: NSManagedObjectContext) {
        showFavorites = false
        if let photo, let imageUrl = photo.imageUrl, let date = photo.date {
            let storage = Storage.storage()
            let storageRef = storage.reference(forURL: imageUrl)
           
             elementsFav.removeAll { result in
                result.date == date
            }
             //Remove image from Firebase
            storageRef.delete { error in
                if let error = error {
                    print(error)
                } else {
                    self.imageUrl = nil
                    print("File deleted successfully")
                }
            }
            //Remove from Coredata
            viewContext.delete(photo)
            do {
                try viewContext.save()
            } catch {
                print("\(error): Failure to save data")
            }
        }
        if let video, let videoUrl = video.videoUrl, let date = video.date, let thumbImage = video.thumbImage {
            let storage = Storage.storage()
            let storageRef = storage.reference(forURL: videoUrl)
            let thumbImageRef = storage.reference(forURL: thumbImage)
            //Remove image from Firebase
            elementsFav.removeAll { result in
                result.date == date
            }
            
            storageRef.delete { error in
                if let error = error {
                    print(error)
                } else {
                    self.imageUrl = nil
                    print("File deleted successfully")
                }
            }
            
            thumbImageRef.delete { error in
                if let error = error {
                    print(error)
                } else {
                    self.imageUrl = nil
                    print("File deleted successfully")
                }
            }
            
            //Remove from Coredata
            viewContext.delete(video)
            do {
                try viewContext.save()
            } catch {
                print("\(error): Failure to save data")
            }
        }
        showFavorites = true
    }
}


extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
