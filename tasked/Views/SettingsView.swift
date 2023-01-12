//
//  SettingsView.swift
//  tasked
//
//  Created by Darko Skerlevski on 3.1.23.
//

import SwiftUI
import PhotosUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            Form {
                HeaderBackgroundSliders(userManager: userManager)
                ProfileSettings(storageManager: storageManager, userManager: userManager)
            }
            .navigationBarTitle(Text("Settings"))
            .navigationBarItems(
                trailing:
                    Button (
                        action: {
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        label: {
                            Text("Done")
                        }
                    )
            )
        }
    }
}
struct ProfileSettings: View {
    @AppStorage("name") var name = DefaultSettings.name
    @AppStorage("subtitle") var subtitle = DefaultSettings.subtitle
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var userManager: UserManager
    @State var didSomethingChange: Bool = false
    
    var body: some View {
        Section(header: Text("Profile")) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Pick Profile Image", systemImage: "photo")
            }
            .onChange(of: selectedItem) { newItem in
                storageManager.imageReadyAfterUpload = false
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            storageManager.upload(image: uiImage)
                            ProfileURLImage().imageLoader.loadImage()
                        }
                    }
                }
            }
            TextField("Name", text: $name)
            TextField("Subtitle", text: $subtitle)
        }
        .onDisappear {
            if userManager.userInfo!.name != name {
                userManager.userInfo!.name = name
                didSomethingChange = true
            }
            if userManager.userInfo!.title != subtitle {
                userManager.userInfo!.title = subtitle
                didSomethingChange = true
            }
            if didSomethingChange {
                userManager.updateUserData(userInfo: userManager.userInfo!)
                didSomethingChange = false
            }
        }
        .onLoad {
            name = userManager.name
            subtitle = userManager.title
        }
    }
}

struct HeaderBackgroundSliders: View {
    @AppStorage("rValue") var rValue = DefaultSettings.rValue
    @AppStorage("gValue") var gValue = DefaultSettings.gValue
    @AppStorage("bValue") var bValue = DefaultSettings.bValue
    @ObservedObject var userManager: UserManager
    @State var didSomethingChange: Bool = false
    
    var body: some View {
        Section(header: Text("Header Background Color")) {
            HStack {
                VStack {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 100)
                        .foregroundColor(Color(red: rValue, green: gValue, blue: bValue, opacity: 1.0))
                }
                VStack {
                    colorSlider(value: $rValue, textColor: .red)
                    colorSlider(value: $gValue, textColor: .green)
                    colorSlider(value: $bValue, textColor: .blue)
                }
            }
        }
        .onDisappear {
            if userManager.userInfo!.r != rValue {
                userManager.userInfo!.r = rValue
                didSomethingChange = true
            }
            if userManager.userInfo!.g != gValue {
                userManager.userInfo!.g = gValue
                didSomethingChange = true
            }
            if userManager.userInfo!.b != bValue {
                userManager.userInfo!.b = bValue
                didSomethingChange = true
            }
            if didSomethingChange {
                userManager.updateUserData(userInfo: userManager.userInfo!)
                didSomethingChange = false
            }
        }
        .onLoad {
            rValue = userManager.r
            gValue = userManager.g
            bValue = userManager.b
        }
    }
}

struct colorSlider: View {
    @Binding var value: Double
    var textColor: Color
    
    var body: some View {
        HStack {
            Text(verbatim: "0")
                .foregroundColor(textColor)
            Slider(value: $value, in: 0.0...1.0)
            Text(verbatim: "255")
                .foregroundColor(textColor)
            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(storageManager: StorageManager(), userManager: UserManager())
    }
}
