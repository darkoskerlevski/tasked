//
//  TaskMembersRepository.swift
//  tasked
//
//  Created by Darko Skerlevski on 8.1.23.
//

import Foundation
import Firebase
import FirebaseFirestore

class TaskMembersRepository: ObservableObject {
    let db = Firestore.firestore()
    
    public var auth = Auth.auth()
    
    public var members = [UserInfo]()
    public var memberIDPairs: [UserInfo:String] = [UserInfo:String]()
    
    init() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db.settings = settings
    }
    
    func loadTaskMembers(task: CustomTask) {
        for member in task.taskMembers {
            self.db.collection("users").document(member).addSnapshotListener { document, error in
                if let document = document, document.exists {
                    let documentData = document.data()
                    let name = documentData!["name"] as? String ?? ""
                    let subtitle = documentData!["title"] as? String ?? ""
                    let r = documentData!["r"] as? Double ?? 0.0
                    let g = documentData!["g"] as? Double ?? 0.0
                    let b = documentData!["b"] as? Double ?? 0.0
                    let email = documentData!["email"] as? String ?? ""
                    let sharedTasks = documentData!["sharedTasks"] as? [String] ?? []
                    let userInfo = UserInfo(name: name, title: subtitle, email: email, r: r, g: g, b: b, sharedTasks: sharedTasks)
                    self.members.append(userInfo)
                    self.memberIDPairs[userInfo] = document.documentID
                }
            }
        }
    }
}
