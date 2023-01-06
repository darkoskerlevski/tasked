//
//  ImageLoader.swift
//  tasked
//
//  Created by Darko Skerlevski on 6.1.23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

class ImageLoader: ObservableObject {
    @Published var data: Data?

    func loadImage() {
        let imageRef = Storage.storage().reference().child("images/image.jpg")
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("\(error)")
            }
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
    }
}
