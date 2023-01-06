//
//  MainView.swift
//  tasked
//
//  Created by Darko Skerlevski on 13.12.22.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var userManager: UserManager = UserManager()
    @State private var tabSelection = 1
    
    var body: some View {
        TabView(selection: $tabSelection) {
            MyTasksListView(userManager: userManager)
                .tabItem {
                    Label("My tasks", systemImage: "list.dash")
                }
                .tag(1)
            SharedTasksListView(userManager: userManager, tabSelection: $tabSelection)
                .tabItem {
                    Label("Shared tasks", systemImage: "square.and.pencil")
                }
                .tag(2)
            ProfileView(userManager: userManager)
                .tabItem {
                    Label("Account", systemImage: "person")
                }
                .tag(3)
        }
        .onLoad {
            userManager.auth.addStateDidChangeListener { auth, user in
                if user != nil {
                    userManager.isLoggedIn = true
                    userManager.loadUserData()
                    print(user!)
                }
            }
        }
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
