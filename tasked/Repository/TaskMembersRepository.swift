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
    
    public var members = [String]()
    
    init() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db.settings = settings
    }
    
    func loadTaskMembers(task: CustomTask) {
        self.db.collection("users").whereField("sharedTasks", arrayContains: task.id).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.members = documents.map { $0["email"]! as! String }
        }
    }
}
