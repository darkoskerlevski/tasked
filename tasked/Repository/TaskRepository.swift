//
//  TaskRepository.swift
//  tasked
//
//  Created by Darko Skerlevski on 31.10.22.
//

import Foundation
import FirebaseFirestore
import simd

class TaskRepository: ObservableObject {
    
    let db = Firestore.firestore()
    
    @Published var tasks = [Task]()
    
    init(){
        loadData()
    }
    
    func loadData() {
        db.collection("tasks").addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                DispatchQueue.main.async {
                    self.tasks = querySnapshot.documents.map { d in
                        return Task(id: d.documentID, title: d["title"] as? String ?? "", completed: d["completed"] as? Bool ?? false)
                    }
                }
            }
        }
    }
    
    func addTask(_ task: Task) {
        do {
            let _ = try db.collection("tasks").addDocument(data: ["title" : task.title, "completed" : task.completed])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
    func updateTask(_ task: Task) {
        do {
            try db.collection("tasks").document(task.id).setData(["title" : task.title, "completed" : task.completed])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
}