//
//  Task.swift
//  tasked
//
//  Created by Darko Skerlevski on 27.10.22.
//

import Foundation

struct TaskSection: Codable {
    var id: UUID
    var name: String
    var items: [Task]
}

struct Task: Codable, Identifiable, Hashable {
    var id: UUID
    let taskName: String
    let taskDesc: String
    let timeSpent: String
    let status: String
    
    
    
}
