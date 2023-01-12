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
    @Published var deletedTasks = [CustomTask]()
    
    
    init(){
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db.settings = settings
        loadDataShared()
    }
    
    func addUserToTask(taskID: String, userID: String) {
        self.db.collection("sharedTasks").document(taskID).getDocument { querySnapshot, error in
            if let querySnapshot = querySnapshot, querySnapshot.exists {
                let data = querySnapshot.data()
                let id = querySnapshot.documentID
                let title = data?["title"] as? String ?? ""
                let description = data?["description"] as? String ?? ""
                let creationDate = data?["creationDate"] as? String ?? ""
                let dueDate = data?["dueDate"] as? Date ?? Date.now
                let completed = data?["completed"] as? Bool ?? false
                let deleted = data?["deleted"] as? Bool ?? false
                let owner = data?["owner"] as? String ?? ""
                var taskMembers = data?["taskMembers"] as? [String] ?? []
                taskMembers.append(userID)
                var task = CustomTask(id: id, title: title, description: description, creationDate: creationDate, dueDate: dueDate, completed: completed, deleted: deleted, owner: owner, taskMembers: taskMembers)
                self.updateTask(task)
            }
        }
    }
    
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
                            let allTasks = availableTasks.map { d in
                                return CustomTask(id: d.documentID, title: d["title"] as? String ?? "", description: d["description"] as? String ?? "", creationDate: d["creationDate"] as? String ?? "", dueDate: d["dueDate"] as? Date ?? Date.now, completed: d["completed"] as? Bool ?? false, deleted: d["deleted"] as? Bool ?? false, owner: d["owner"] as? String ?? "", taskMembers: d["taskMembers"] as? [String] ?? [])
                            }
                            self.tasks = allTasks.filter { $0.deleted == false }
                            self.deletedTasks = allTasks.filter { $0.deleted == true }
                        }
                    }
                    
                }
            }
        }
    }
    
    
    
    func addTask(_ task: CustomTask) {
        do {
            let _ = try db.collection("sharedTasks").document(task.id).setData(["title" : task.title, "description" : task.description, "creationDate" : task.creationDate, "dueDate" : task.dueDate, "completed" : task.completed, "owner" : auth.currentUser!.uid, "taskMembers" : task.taskMembers, "deleted" : task.deleted])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
    func updateTask(_ task: CustomTask) {
        do {
            try db.collection("sharedTasks").document(task.id).setData(["title" : task.title, "description" : task.description, "creationDate" : task.creationDate, "dueDate" : task.dueDate, "completed" : task.completed, "owner" : task.owner, "taskMembers" : task.taskMembers, "deleted" : task.deleted])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
    func removeTask(_ task: CustomTask) {
        if task.deleted {
            do {
                try db.collection("sharedTasks").document(task.id).delete()
                for member in task.taskMembers {
                    db.collection("users").document(member).updateData([
                        "sharedTasks" : FieldValue.arrayRemove([task.id])
                    ])
                }
            }
            catch {
                fatalError("Unable to encode task: \(error.localizedDescription)")
            }
        } else {
            do {
                try db.collection("sharedTasks").document(task.id).setData(["title" : task.title, "description" : task.description, "creationDate" : task.creationDate, "dueDate" : task.dueDate, "completed" : task.completed, "owner" : task.owner, "taskMembers" : task.taskMembers, "deleted" : true])
            }
            catch {
                fatalError("Unable to encode task: \(error.localizedDescription)")
            }
        }
    }
    
    func removeTaskMember(_ task: CustomTask, memberID: String) {
        do {
            try db.collection("sharedTasks").document(task.id).updateData([
                "taskMembers" : FieldValue.arrayRemove([memberID])
            ])
            db.collection("users").document(memberID).updateData([
                "sharedTasks" : FieldValue.arrayRemove([task.id])
            ])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
    func restoreTask(_ task: CustomTask) {
        do {
            try db.collection("sharedTasks").document(task.id).setData(["title" : task.title, "description" : task.description, "creationDate" : task.creationDate, "dueDate" : task.dueDate, "completed" : task.completed, "owner": task.owner, "taskMembers" : task.taskMembers, "deleted" : false])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
}
