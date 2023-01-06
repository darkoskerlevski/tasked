//
//  ProfileURLImage.swift
//  tasked
//
//  Created by Darko Skerlevski on 6.1.23.
//

import SwiftUI

struct ProfileURLImage: View {
    @ObservedObject var imageLoader: ImageLoader

    init() {
        imageLoader = ImageLoader()
        imageLoader.loadImage()
    }

    var body: some View {
        Image(uiImage:
                (imageLoader.data != nil ? UIImage(data: imageLoader.data!)! : UIImage(systemName: "person.crop.circle.fill")?.scalePreservingAspectRatio(width: 200, height: 150))!)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 4))
        .shadow(radius: 10)
    }
}
