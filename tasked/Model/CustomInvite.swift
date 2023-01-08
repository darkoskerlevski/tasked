//
//  CustomInvite.swift
//  tasked
//
//  Created by Darko Skerlevski on 7.1.23.
//

import Foundation

struct CustomInvite: Codable, Identifiable{
    var id: String = UUID().uuidString
    var forTaskID: String
    var forTaskTitle: String
    var forUserEmail: String
    var fromEmail: String
    var fromName: String
}
