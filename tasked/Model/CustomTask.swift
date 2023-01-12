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
    var description: String
    var creationDate: String = Date.now.formatted(date: .long, time: .omitted)
    var dueDate: Date
    var completed: Bool
    var deleted: Bool
    var owner: String
    var taskMembers: [String]
}
