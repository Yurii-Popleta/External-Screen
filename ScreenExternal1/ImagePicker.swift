

import UIKit
import SwiftUI
import FirebaseStorage
import FirebaseAuth
import CoreData
import AVFoundation
import MobileCoreServices

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var isPresented : Bool
    var sourceType: UIImagePickerController.SourceType
    var viewContext: NSManagedObjectContext
    var isVideo: Bool
    var viewModel: ViewModel
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        if isVideo {
            imagePicker.mediaTypes = ["public.movie"]
            imagePicker.videoQuality = .typeMedium
        }
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        //
    }
    
    typealias UIViewControllerType = UIImagePickerController
  
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
  final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
      
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                if let imageData = image.jpegData(compressionQuality: 0.2) {
                    let fileId = "photo_\(id().replacingOccurrences(of: " ", with: "-")).png"
                    
                    uploadPhoto(with: imageData, filename: fileId) { results in
                     switch results {
                        case .success(let urlString):
                            if self.parent.viewModel.tabSelected == 0 {
                                self.parent.viewModel.alertWithTextPhoto = true
                            }
                            let photo = Photo(context: self.parent.viewContext)
                            photo.id = UUID()
                            photo.date = Date()
                            photo.imageUrl = urlString
                         if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                             photo.name = self.origFileName(media: .photo, url: url)
                         } else {
                             photo.name = "default"
                         }
                            photo.isFavorite = false
                            photo.text = ""
                            photo.play = false
                            self.save(viewContext: self.parent.viewContext)
                        case .failure(let error):
                            print("image upload error \(error)")
                        }
                    }
                }
            } else if let videoUrl = info[.mediaURL] as? URL {
                if let image = generateThumbnailImage(path: videoUrl) {
                    let fileId = "video_\(id().replacingOccurrences(of: " ", with: "-")).mov"
                    
                    uploadVideo(with: videoUrl, filename: fileId) { results in
                        switch results {
                        case .success(let urlString):
                            if let imageData = image.jpegData(compressionQuality: 0.0) {
                                let thumbnailImageId = "thumbnailImage_\(self.id().replacingOccurrences(of: " ", with: "-")).png"
                                
                                self.uploadPhoto(with: imageData, filename: thumbnailImageId) { result in
                                    switch result {
                                    case .success(let photoURLString):
                                        if self.parent.viewModel.tabSelected == 1 {
                                            self.parent.viewModel.alertWithTextVideo = true
                                        }
                                        
                                        let video = Video(context: self.parent.viewContext)
                                        video.id = UUID()
                                        video.date = Date()
                                        video.videoUrl = urlString
                                        video.thumbImage = photoURLString
                                        video.text = ""
                                        video.name = self.origFileName(media: .video, url: videoUrl)
                                        video.isFavorite = false
                                        video.play = false
                                        self.save(viewContext: self.parent.viewContext)
                                    case .failure(let error):
                                        print("thumbnail Image upload error \(error)")
                                    }
                                }
                            }
                        case .failure(let error):
                            print("video upload error \(error)")
                        }
                    }
                }
              }
            parent.isPresented = false
        }
        
      
 //setap of uploading images
        public typealias UploadCompletion = (Result<String, Error>) -> Void
        public enum StorageErrors: Error {
            case failedToUpload
            case failedToGetDownloadUrl }
        let storage = Storage.storage().reference()
        

        public func uploadPhoto(with data: Data, filename: String, completion: @escaping UploadCompletion) {
            var uid = String()
            if Auth.auth().currentUser?.uid != nil {
                uid = Auth.auth().currentUser!.uid
            } else {
                Auth.auth().signInAnonymously { result, error in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    print("Success = \(result!.user.uid)")
                    uid = result!.user.uid
                }
            }
            
            storage.child("\(uid)/\(filename)").putData(data, metadata: nil) { [weak self] metaData, error in
                guard error == nil else {
                    //failed
                    print("failed upload image to firebase")
                    completion(.failure(StorageErrors.failedToUpload))
                    return  }
                
                self?.storage.child("\(uid)/\(filename)").downloadURL { url, error in
                    guard let safeurl = url else {
                        //failed
                        print("failed to get download url")
                        completion(.failure(StorageErrors.failedToGetDownloadUrl))
                        return  }
                    
                    let urlString = safeurl.absoluteString
                    print("download url returned \(urlString)")
                    completion(.success(urlString))
                }
            }
        }
     
    //setap of uploading videos
        public func uploadVideo(with fileUrl: URL, filename: String, completion: @escaping UploadCompletion) {
            var uid = String()
            if Auth.auth().currentUser?.uid != nil {
                uid = Auth.auth().currentUser!.uid
            } else {
                Auth.auth().signInAnonymously { result, error in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    print("Success = \(result!.user.uid)")
                    uid = result!.user.uid
                }
            }
            
            if let videoData = NSData(contentsOf: fileUrl) as Data? {
                storage.child("\(uid)/\(filename)").putData(videoData, metadata: nil) { [weak self] metaData, error in
                    guard error == nil else {
                        //failed
                        print("failed upload video to firebase")
                        completion(.failure(StorageErrors.failedToUpload))
                        return
                 }
                    self?.storage.child("\(uid)/\(filename)").downloadURL { url, error in
                        guard let url = url else {
                            //failed
                            print("failed to get download url")
                            completion(.failure(StorageErrors.failedToGetDownloadUrl))
                            return
                          }
                        let urlString = url.absoluteString
                        print("download url returned \(urlString)")
                        completion(.success(urlString))
                    }
                }
            }
        }
      
      //fileName
      func origFileName(media: Media, url: URL) -> String {
          switch media {
          case .photo:
              let origFileName = url.lastPathComponent
              let index = origFileName.index(origFileName.startIndex, offsetBy: 7)
              let substringFileName = origFileName[..<index]
              return String(substringFileName)
          case .video:
              let origFileName = url.lastPathComponent
              let indexfirst = origFileName.index(origFileName.startIndex, offsetBy: 5)
              let index = origFileName.index(origFileName.startIndex, offsetBy: 13)
              let substringFileName = origFileName[indexfirst..<index]
              return String(substringFileName)
          case .favorites:
              return ""
          case .externalScreen:
              return ""
          }
      }
        
     // set imagePreviewForVideo
        func generateThumbnailImage(path: URL) -> UIImage? {
            do {
                let asset = AVURLAsset(url: path, options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                return thumbnail
            } catch let error {
                print("*** Error generating thumbnail: \(error.localizedDescription)")
                return nil
            }
        }
        
        private func id() -> String {
            let dateString = Date().getFormattedDate(format: "E, d MMM yyyy HH:mm:ss Z")
            let randomNumbers = Int.random(in: 1...10000000)
            let newIdentifier = dateString + String(randomNumbers)
            return newIdentifier
        }
      
      func save(viewContext: NSManagedObjectContext) {
          do {
              try viewContext.save()
              print("success save item")
          } catch {
              print("Error saving item \(error)")
          }
      }
    }
}

extension Date {
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        dateformat.locale = Locale(identifier: "EN")
        return dateformat.string(from: self)
    }
    
}
