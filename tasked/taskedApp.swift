//
//  taskedApp.swift
//  tasked
//
//  Created by Darko Skerlevski on 27.10.22.
//

import SwiftUI

@main
struct taskedApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: tasksViewModel())
        }
    }
}
