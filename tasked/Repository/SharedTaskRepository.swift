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
    
    @Published var tasks = [CustomTask]()
    
    
//    init(){
//        loadData()
//    }
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
    
    func loadDataShared(taskList: [String]) {
        db.collection("sharedTasks").addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                DispatchQueue.main.async {
                    let availableTasks = querySnapshot.documents.filter { d in
                        taskList.contains(d.documentID)
                    }
                    self.tasks = availableTasks.map { d in
                            return CustomTask(id: d.documentID, title: d["title"] as? String ?? "", completed: d["completed"] as? Bool ?? false)
                    }
                }
            }
            print(self.tasks)
            print(taskList)
        }
    }
    

    
    func addTask(_ task: CustomTask) {
        do {
            let _ = try db.collection("tasks").addDocument(data: ["title" : task.title, "completed" : task.completed])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
    func updateTask(_ task: CustomTask) {
        do {
            try db.collection("tasks").document(task.id).setData(["title" : task.title, "completed" : task.completed])
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
    func removeTask(_ task: CustomTask) {
        do {
            try db.collection("tasks").document(task.id).delete()
        }
        catch {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
}
