//
//  TaskRepository.swift
//  tasked
//
//  Created by Darko Skerlevski on 31.10.22.
//

import Foundation
import FirebaseFirestore


class TaskRepository: ObservableObject {
    
    let db = Firestore.firestore()
    
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
            self.db.collection("tasks").addSnapshotListener { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    DispatchQueue.main.async {
                        let allTasks = querySnapshot.documents.map { d in
                            return CustomTask(id: d.documentID, title: d["title"] as? String ?? "", completed: d["completed"] as? Bool ?? false, deleted: d["deleted"] as? Bool ?? false, owner: d["owner"] as? String ?? "", taskMembers: d["taskMembers"] as? [String] ?? [])
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
            let _ = try db.collection("tasks").addDocument(data: ["title" : task.title, "completed" : task.completed, "taskMembers" : task.taskMembers, "deleted" : task.deleted])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
    func updateTask(_ task: CustomTask) {
        do {
            try db.collection("tasks").document(task.id).setData(["title" : task.title, "completed" : task.completed, "taskMembers" : task.taskMembers, "deleted" : task.deleted])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
    func removeTask(_ task: CustomTask) {
        if task.deleted {
            do {
                try db.collection("tasks").document(task.id).delete()
            }
            catch {
                fatalError("Unable to encode task: \(error.localizedDescription)")
            }
        } else {
            do {
                try db.collection("tasks").document(task.id).setData(["title" : task.title, "completed" : task.completed, "taskMembers" : task.taskMembers, "deleted" : true])
            }
            catch {
                fatalError("Unable to encode task: \(error.localizedDescription)")
            }
        }
    }
    
    func restoreTask(_ task: CustomTask) {
        do {
            try db.collection("tasks").document(task.id).setData(["title" : task.title, "completed" : task.completed, "taskMembers" : task.taskMembers, "deleted" : false])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
}
