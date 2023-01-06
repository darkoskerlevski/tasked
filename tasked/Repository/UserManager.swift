//
//  UserManager.swift
//  tasked
//
//  Created by Darko Skerlevski on 4.1.23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

public class UserManager: ObservableObject {
    
    @Published var isLoggedIn: Bool = false
    @Published var showToast: Bool = false
    @Published var errorCreatingUser: Bool = false
    @Published var userInfo: UserInfo? = nil
    @Published var name: String = ""
    @Published var title: String = ""
    @Published var r = 0.0
    @Published var g = 0.0
    @Published var b = 0.0
    let db = Firestore.firestore()
    
    public var auth = Auth.auth()
    
    func loadUserData() {
        db.collection("users").document(auth.currentUser!.uid).addSnapshotListener { documentSnapshot, error in
            if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                let documentData = documentSnapshot.data()
                let name = documentData!["name"] as? String ?? ""
                let subtitle = documentData!["title"] as? String ?? ""
                let r = documentData!["r"] as? Double ?? 0.0
                let g = documentData!["g"] as? Double ?? 0.0
                let b = documentData!["b"] as? Double ?? 0.0
                let sharedTasks = documentData!["sharedTasks"] as? [String] ?? []
                self.userInfo = UserInfo(name: name, title: subtitle, r: r, g: g, b: b, sharedTasks: sharedTasks)
                self.name = name
                self.title = subtitle
                self.r = r
                self.g = g
                self.b = b
            }
        }
    }
    
    func updateUserData(userInfo: UserInfo) {
        self.db.collection("users").document(auth.currentUser!.uid).setData([
            "name" : userInfo.name,
            "title" : userInfo.title,
            "r" : userInfo.r,
            "g" : userInfo.g,
            "b" : userInfo.b,
            "sharedTasks" : userInfo.sharedTasks
        ])
    }
    
    func getUserID() -> String {
        if self.isLoggedIn {
            return self.auth.currentUser!.uid
        } else {
            return ""
        }
    }
    
    func register(email: String, pass: String, name: String, title: String) {
        self.auth.createUser(withEmail: email, password: pass) { (user, error) in
            if error != nil {
                print("error creating user")
                self.errorCreatingUser = true
            } else {
                // SUCCESS
                self.userInfo = UserInfo(name: name, title: title, r: 0, g: 0, b: 0, sharedTasks: [])
                self.db.collection("users").document(user!.user.uid).setData([
                    "name" : self.userInfo?.name ?? "",
                    "title" : self.userInfo?.title ?? "",
                    "r" : self.userInfo?.r ?? 0.0,
                    "g" : self.userInfo?.g ?? 0.0,
                    "b" : self.userInfo?.b ?? 0.0,
                    "sharedTasks" : self.userInfo?.sharedTasks ?? []
                ])
            }
        }
    }
    
    func login(email: String, pass: String) {
        self.auth.signIn(withEmail: email, password: pass) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                self.showToast = true
            } else {
                self.isLoggedIn = true
                self.loadUserData()
            }
            
        }
    }
    
    func logout() {
        do {
            try self.auth.signOut()
            self.isLoggedIn = false
            self.userInfo = nil
        } catch {
            print("error signing out")
        }
    }
    
}
