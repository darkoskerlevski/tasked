//
//  SharedTaskRepository.swift
//  tasked
//
//  Created by Darko Skerlevski on 6.1.23.
//

import Foundation
import Firebase
import FirebaseFirestore


class SharedTaskRepository: ObservableObject {
    
    
    let db = Firestore.firestore()
    
    let auth = Auth.auth()
    
    
    @Published var tasks = [CustomTask]()
    
    
    init(){
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db.settings = settings
        loadDataShared()
    }
//
//    func loadData() {
//        db.collection("sharedTasks").addSnapshotListener { (querySnapshot, error) in
//            if let querySnapshot = querySnapshot {
//                DispatchQueue.main.async {
//                    self.tasks = querySnapshot.documents.map { d in
//                        return CustomTask(id: d.documentID, title: d["title"] as? String ?? "", completed: d["completed"] as? Bool ?? false)
//                    }
//                }
//            }
//        }
//    }
    
    func loadDataShared() {
        db.collection("users").document(auth.currentUser?.uid ?? "nil").addSnapshotListener { documentSnapshot, error in
            if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                let documentData = documentSnapshot.data()
                let sharedTasks = documentData!["sharedTasks"] as? [String] ?? []
                self.db.collection("sharedTasks").addSnapshotListener { (querySnapshot, error) in
                    if let querySnapshot = querySnapshot {
                        DispatchQueue.main.async {
                            let availableTasks = querySnapshot.documents.filter { d in
                                sharedTasks.contains(d.documentID)
                            }
                            self.tasks = availableTasks.map { d in
                                return CustomTask(id: d.documentID, title: d["title"] as? String ?? "", completed: d["completed"] as? Bool ?? false, owner: d["owner"] as? String ?? "", taskMembers: d["taskMembers"] as? [String] ?? [])
                            }
                            print("sharedTasks = ", sharedTasks)
                            print("retreived tasks = ", self.tasks)
                        }
                    }
                    
            }
        }
        
//            print(self.tasks)
//            print(taskList)
        }
    }
    

    
    func addTask(_ task: CustomTask) {
        do {
            let _ = try db.collection("sharedTasks").addDocument(data: ["title" : task.title, "completed" : task.completed, "owner" : auth.currentUser!.uid, "taskMembers" : task.taskMembers])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
    func updateTask(_ task: CustomTask) {
        do {
            try db.collection("sharedTasks").document(task.id).setData(["title" : task.title, "completed" : task.completed, "taskMembers" : task.taskMembers])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
    func removeTask(_ task: CustomTask) {
        do {
            try db.collection("sharedTasks").document(task.id).delete()
            db.collection("users").document(auth.currentUser!.uid).updateData([
                "sharedTasks" : FieldValue.arrayRemove([task.id])
            ])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
}
