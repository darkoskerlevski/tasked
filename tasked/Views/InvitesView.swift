//
//  InvitesView.swift
//  tasked
//
//  Created by Darko Skerlevski on 7.1.23.
//

import SwiftUI

struct InvitesView: View {
    @ObservedObject var userManager: UserManager
    @ObservedObject var taskInviteRepository = TaskInviteRepository()
    @ObservedObject var sharedTaskRepository: SharedTaskRepository
    
    var body: some View {
        NavigationView {
            List {
                ForEach(taskInviteRepository.invites) { invite in
                    HStack {
                        Image("logo")
                            .resizable()
                            .frame(width: 30, height: 30)
                        VStack {
                            HStack {
                                Text("Task name: " + invite.forTaskTitle)
                                Spacer()
                            }
                            HStack {
                                Text("From: " + invite.fromEmail)
                                Spacer()
                            }
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            if !(userManager.userInfo?.sharedTasks.contains(invite.forTaskID))! {
                                userManager.userInfo?.sharedTasks.append(invite.forTaskID)
                                userManager.updateUserData(userInfo: userManager.userInfo!)
                            }
                            taskInviteRepository.removeInvite(invite)
                            sharedTaskRepository.addUserToTask(taskID: invite.forTaskID, userID: userManager.getUserID())
                        } label: {
                            Label("Accept invite", systemImage: "checkmark")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            taskInviteRepository.removeInvite(invite)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                }
            }
            
        }
        .navigationTitle("Invites")
        Spacer()
        Divider()
        Text("tip: swipe from left to accept, from right to decline")
            .font(.footnote.smallCaps())
    }
}

struct InvitesView_Previews: PreviewProvider {
    static var previews: some View {
        InvitesView(userManager: UserManager(), sharedTaskRepository: SharedTaskRepository())
    }
}
