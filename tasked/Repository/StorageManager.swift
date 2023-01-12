//
//  StorageManager.swift
//  tasked
//
//  Created by Darko Skerlevski on 3.1.23.
//

import SwiftUI
import Firebase
import FirebaseStorage

public class StorageManager: ObservableObject {
    let storage = Storage.storage()
    let auth = Auth.auth()
    @Published var imageReadyAfterUpload = true

    func upload(image: UIImage) {
        let storageRef = storage.reference().child(auth.currentUser!.uid + "/image.jpg")

        let resizedImage = image.scalePreservingAspectRatio(width: 200, height: 200)

        let data = resizedImage.jpegData(compressionQuality: 0.5)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"

        if let data = data {
            storageRef.putData(data, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error while uploading file: ", error)
                }

                if let metadata = metadata {
                    self.imageReadyAfterUpload = true
                }
            }
        }
    }
    
//    func downloadImage() -> Void {
//        let imageRef = storage.reference().child("images/image.jpg")
//        
//        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
//            if let error = error {
//                print(error)
//            } else {
//                self.image = UIImage(data: data!)?.withRenderingMode(.alwaysOriginal)
//            }
//        }
//    }

    func deleteItem(item: StorageReference) {
        item.delete { error in
            if let error = error {
                print("Error deleting item", error)
            }
        }
    }
}
