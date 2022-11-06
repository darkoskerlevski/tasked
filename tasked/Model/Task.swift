//
//  Task.swift
//  tasked
//
//  Created by Darko Skerlevski on 31.10.22.
//

import Foundation

struct Task: Codable, Identifiable{
    var id: String = UUID().uuidString
    var title: String
    var completed: Bool
}

#if DEBUG
let testDataTasks = [
    Task(title: "Implement the UI", completed: true),
    Task(title: "Connect to firebase", completed: false),
    Task(title: "????", completed: false),
    Task(title: "Profit!!!", completed: false)
]
#endif
