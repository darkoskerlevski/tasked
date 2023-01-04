//
//  Task.swift
//  tasked
//
//  Created by Darko Skerlevski on 31.10.22.
//

import Foundation

struct CustomTask: Codable, Identifiable{
    var id: String = UUID().uuidString
    var title: String
    var completed: Bool
}

#if DEBUG
let testDataTasks = [
    CustomTask(title: "Implement the UI", completed: true),
    CustomTask(title: "Connect to firebase", completed: false),
    CustomTask(title: "????", completed: false),
    CustomTask(title: "Profit!!!", completed: false)
]
#endif
