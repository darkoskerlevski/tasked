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
    @Published var image: UIImage? = nil

    func upload(image: UIImage) {
        // Create a storage reference
        let storageRef = storage.reference().child("images/image.jpg")

        // Resize the image to 200px with a custom extension
        let resizedImage = image.scalePreservingAspectRatio(width: 200, height: 200)

        // Convert the image into JPEG and compress the quality to reduce its size
        let data = resizedImage.jpegData(compressionQuality: 0.5)

        // Change the content type to jpg. If you don't, it'll be saved as application/octet-stream type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"

        // Upload the image
        if let data = data {
            storageRef.putData(data, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error while uploading file: ", error)
                }

                if let metadata = metadata {
                    // SUCCESS
                }
            }
        }
    }
    
    func downloadImage() -> Void {
        let imageRef = storage.reference().child("images/image.jpg")
        
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                self.image = UIImage(data: data!)
            }
        }
    }

        // You can use the listItem() function above to get the StorageReference of the item you want to delete
    func deleteItem(item: StorageReference) {
        item.delete { error in
            if let error = error {
                print("Error deleting item", error)
            }
        }
    }
}
