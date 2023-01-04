//
//  ProfileView.swift
//  tasked
//
//  Created by Darko Skerlevski on 3.1.23.
//

import SwiftUI
import FirebaseStorage

struct ProfileView: View {
    @State var isPresented: Bool = false
    @ObservedObject var storageManager: StorageManager = StorageManager()
    
    var body: some View {
        VStack {
            VStack {
                Header(storageManager: storageManager)
                ProfileText()
            }
            Spacer()
            Button (
                action: { self.isPresented = true },
                label: {
                    Label("Edit", systemImage: "pencil")
                })
            .sheet(isPresented: $isPresented, content: {
                SettingsView(storageManager: storageManager)
            })
        }
    }
}

struct Header: View {
    @AppStorage("rValue") var rValue = DefaultSettings.rValue
    @AppStorage("gValue") var gValue = DefaultSettings.gValue
    @AppStorage("bValue") var bValue = DefaultSettings.bValue
    @State var profileImage: UIImage?
    @ObservedObject var storageManager: StorageManager
    
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundColor(Color(red: rValue, green: gValue, blue: bValue, opacity: 1.0))
                .edgesIgnoringSafeArea(.top)
                .frame(height: 100)
            if storageManager.image != nil {
                Image(uiImage: storageManager.image!)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
            }
        }
        .onLoad {
            storageManager.downloadImage()
        }
    }
}

struct ProfileText: View {
    @AppStorage("name") var name = DefaultSettings.name
    @AppStorage("subtitle") var subtitle = DefaultSettings.subtitle
    
    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: 5) {
                Text(name)
                    .bold()
                    .font(.title)
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
            }.padding()
            Spacer()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
