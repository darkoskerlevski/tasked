//
//  MainView.swift
//  tasked
//
//  Created by Darko Skerlevski on 13.12.22.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            AllTasksListView()
                .tabItem {
                    Label("All tasks", systemImage: "list.dash")
                }
            MyTasksListView()
                .tabItem {
                    Label("My tasks", systemImage: "square.and.pencil")
                }
            ProfileView()
                .tabItem {
                    Label("Account", systemImage: "person")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
