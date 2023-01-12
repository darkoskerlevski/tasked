//
//  TaskRepository.swift
//  tasked
//
//  Created by Darko Skerlevski on 31.10.22.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


class TaskRepository: ObservableObject {
    
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    @Published var tasks = [CustomTask]()
    @Published var deletedTasks = [CustomTask]()
    
    init(){
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db.settings = settings
        loadData()
    }
    
    func loadData() {
        DispatchQueue.global(qos: .background).async {
            self.db.collection("users").document(self.auth.currentUser?.uid ?? "nil").collection("personalTasks").addSnapshotListener { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    DispatchQueue.main.async {
                        let allTasks = querySnapshot.documents.map { d in
                            return CustomTask(id: d.documentID, title: d["title"] as? String ?? "", description: d["description"] as? String ?? "", creationDate: d["creationDate"] as? String ?? "", dueDate: d["dueDate"] as? Date ?? Date.now, completed: d["completed"] as? Bool ?? false, deleted: d["deleted"] as? Bool ?? false, owner: d["owner"] as? String ?? "", taskMembers: d["taskMembers"] as? [String] ?? [])
                        }
                        self.tasks = allTasks.filter { $0.deleted == false }
                        self.deletedTasks = allTasks.filter { $0.deleted == true }
                    }
                }
            }
        }
    }
    
    func addTask(_ task: CustomTask) {
        do {
            let _ = try db.collection("users").document(self.auth.currentUser!.uid).collection("personalTasks").addDocument(data: ["title" : task.title, "description" : task.description, "creationDate" : task.creationDate, "dueDate" : task.dueDate, "completed" : task.completed, "taskMembers" : task.taskMembers, "deleted" : task.deleted])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
    func updateTask(_ task: CustomTask) {
        do {
            try db.collection("users").document(self.auth.currentUser!.uid).collection("personalTasks").document(task.id).setData(["title" : task.title, "description" : task.description, "creationDate" : task.creationDate, "dueDate" : task.dueDate, "completed" : task.completed, "taskMembers" : task.taskMembers, "deleted" : task.deleted])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
    func removeTask(_ task: CustomTask) {
        if task.deleted {
            do {
                try db.collection("users").document(self.auth.currentUser!.uid).collection("personalTasks").document(task.id).delete()
            }
            catch {
                fatalError("Unable to encode task: \(error.localizedDescription)")
            }
        } else {
            do {
                try db.collection("users").document(self.auth.currentUser!.uid).collection("personalTasks").document(task.id).setData(["title" : task.title, "description" : task.description, "creationDate" : task.creationDate, "dueDate" : task.dueDate, "completed" : task.completed, "taskMembers" : task.taskMembers, "deleted" : true])
            }
            catch {
                fatalError("Unable to encode task: \(error.localizedDescription)")
            }
        }
    }
    
    func restoreTask(_ task: CustomTask) {
        do {
            try db.collection("users").document(self.auth.currentUser!.uid).collection("personalTasks").document(task.id).setData(["title" : task.title, "description" : task.description, "creationDate" : task.creationDate, "dueDate" : task.dueDate, "completed" : task.completed, "taskMembers" : task.taskMembers, "deleted" : false])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
    func moveTask(_ task: CustomTask) {
        do {
            let _ = try db.collection("sharedTasks").document(task.id).setData(["title" : task.title, "description" : task.description, "creationDate" : task.creationDate, "dueDate" : task.dueDate, "completed" : task.completed, "owner" : auth.currentUser!.uid, "taskMembers" : [auth.currentUser!.uid], "deleted" : task.deleted])
            try db.collection("users").document(self.auth.currentUser!.uid).collection("personalTasks").document(task.id).delete()
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
}
