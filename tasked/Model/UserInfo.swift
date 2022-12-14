//
//  UserInfo.swift
//  tasked
//
//  Created by Darko Skerlevski on 5.1.23.
//

import Foundation

struct UserInfo: Codable, Hashable {
    var name: String
    var title: String
    var email: String
    var r: Double
    var g: Double
    var b: Double
    var sharedTasks: [String]
}
