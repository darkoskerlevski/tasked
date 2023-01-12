//
//  MyTasksListView.swift
//  tasked
//
//  Created by Darko Skerlevski on 13.12.22.
//

import SwiftUI

struct SharedTasksListView: View {
    @ObservedObject var userManager: UserManager
    @ObservedObject var taskListVM = SharedTaskListViewModel()
    @Binding var tabSelection: Int
    @State var showDeleted: Bool = false
    @State var showCompleted: Bool = false
    
    var body: some View {
        NavigationView {
            if userManager.isLoggedIn {
                VStack {
                    List {
                        ForEach(taskListVM.taskCellViewModels) { taskCellVM in
                            Group {
                                if showCompleted {
                                    if !taskCellVM.task.completed {
                                        sharedTaskCellView(taskCellVM: taskCellVM, taskListVM: taskListVM, userManager: userManager)
                                    }
                                }
                                else
                                {
                                    sharedTaskCellView(taskCellVM: taskCellVM, taskListVM: taskListVM, userManager: userManager)
                                }
                            }
                        }
                    }
                    HStack {
                        Toggle("", isOn: $showCompleted)
                            .labelsHidden()
                        Text("incomplete?")
                        Spacer()
                        NavigationLink(destination: AddNewSharedTaskView(task: CustomTask(title: "", description: "", dueDate: Date.now, completed: false, deleted: false, owner: userManager.getUserID(), taskMembers: [String]()), createNewTask: true, userManager: userManager)) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Add New Task")
                            }
                        }
                        .buttonStyle(DefaultButtonStyle())
                    }
                    .padding([.leading, .trailing])
                    Divider()
                }
                .navigationTitle("Shared tasks")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: InvitesView(userManager: userManager, sharedTaskRepository: taskListVM.taskRepository)) {
                            Image(systemName: "envelope.fill")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showDeleted = true
                        } label: {
                            Image(systemName: "trash.fill")
                        }
                    }
                }
                .sheet(isPresented: $showDeleted) {
                    NavigationView {
                        VStack {
                            List {
                                ForEach(taskListVM.deletedTaskCellViewModels) { taskCellVM in
                                    Group {
                                        sharedTaskCellView(taskCellVM: taskCellVM, taskListVM: taskListVM, userManager: userManager)
                                    }
                                }
                            }
                            Spacer()
                            Divider()
                            Text("tip: swipe from left to restore, from right to permanently delete")
                                .font(.footnote.smallCaps())
                                .padding()
                        }
                        .navigationTitle("Deleted tasks")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showDeleted = false
                                }
                            }
                        }
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                }
            } else {
                VStack {
                    Text("You are not signed in!")
                        .font(.title)
                    HStack {
                        Text("please")
                            .font(.title3)
                        Text("sign in")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .onTapGesture {
                                self.tabSelection = 3
                            }
                        Text("to use this feature")
                            .font(.title3)
                    }
                }
            }
        }
    }
}

struct sharedTaskCellView: View {
    @ObservedObject var taskCellVM: SharedTaskCellViewModel
    @ObservedObject var taskListVM: SharedTaskListViewModel
    @ObservedObject var userManager: UserManager
    var body: some View {
        SharedTaskCell(taskCellVM: taskCellVM, userManager: userManager)
            .swipeActions(allowsFullSwipe: false) {
                Button(role: .destructive) {
                    if taskCellVM.task.owner == userManager.getUserID() {
                        taskListVM.removeTask(task: taskCellVM.task)
                    } else {
                        taskListVM.removeTaskMember(task: taskCellVM.task, memberID: userManager.getUserID())
                    }
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                    if self.taskCellVM.task.deleted {
                        taskListVM.restoreTask(task: taskCellVM.task)
                    } else {
                        self.taskCellVM.task.completed.toggle()
                    }
                } label: {
                    Label("Complete task", systemImage: "checkmark")
                }
                .tint(.blue)
            }
    }
}

struct SharedTaskCell: View {
    @ObservedObject var taskCellVM: SharedTaskCellViewModel
    @ObservedObject var userManager: UserManager
    
    var onCommit: (CustomTask) -> (Void) = {_ in }
    
    var body: some View {
        HStack {
            Image(systemName: taskCellVM.task.completed ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 20, height: 20)
                .onTapGesture {
                    self.taskCellVM.task.completed.toggle()
                }
            NavigationLink(destination: AddNewSharedTaskView(task: taskCellVM.task, createNewTask: false, userManager: userManager)) {
                Text(taskCellVM.task.title)
            }
        }
    }
}

struct MyTasksListView_Previews: PreviewProvider {
    static var previews: some View {
        SharedTasksListView(userManager: UserManager(), tabSelection: .constant(2))
    }
}
