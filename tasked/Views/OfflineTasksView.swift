//
//  OfflineTasksView.swift
//  tasked
//
//  Created by Darko Skerlevski on 11.1.23.
//

import SwiftUI

struct OfflineTasksView: View {
    
    @AppStorage("offlineTasks") var offlineTasks: [CustomTask] = [CustomTask]()
    @AppStorage("offlineDeletedTasks") var offlineDeletedTasks: [CustomTask] = [CustomTask]()
    @State var showDeleted: Bool = false
    @State var showCompleted: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(offlineTasks) { task in
                        Group {
                            if showCompleted {
                                if !task.completed {
                                    OfflineTaskCell(task: task)
                                }
                            }
                            else
                            {
                                OfflineTaskCell(task: task)
                            }
                        }
                    }
                }
                .id(UUID())
                HStack {
                    Toggle("", isOn: $showCompleted)
                        .labelsHidden()
                    Text("incomplete?")
                    Spacer()
                    NavigationLink(destination: AddNewOfflineTaskView(task: CustomTask(title: "", description: "", dueDate: Date.now, completed: false, deleted: false, owner: "", taskMembers: [String]()), createNewTask: true)) {
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
            .navigationTitle("All tasks")
            .toolbar {
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
                            ForEach(offlineDeletedTasks) { task in
                                Group {
                                    OfflineTaskCell(task: task)
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
        }
    }
}

struct OfflineTaskCell: View {
    @AppStorage("offlineTasks") var offlineTasks: [CustomTask] = [CustomTask]()
    @AppStorage("offlineDeletedTasks") var offlineDeletedTasks: [CustomTask] = [CustomTask]()
    @State var task: CustomTask
    
    var onCommit: (CustomTask) -> (Void) = {_ in }
    
    var body: some View {
        HStack {
            Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 20, height: 20)
                .onTapGesture {
                    if let i = offlineTasks.firstIndex(where: { $0.id == task.id }) {
                        let changeBool = !task.completed
                        offlineTasks[i] = CustomTask(id: task.id, title: task.title, description: task.description, creationDate: task.creationDate, dueDate: task.dueDate, completed: changeBool, deleted: task.deleted, owner: task.owner, taskMembers: task.taskMembers)
                    }
                }
            NavigationLink(destination: AddNewOfflineTaskView(task: task, createNewTask: false)) {
                Text(task.title)
            }
        }
        .swipeActions(allowsFullSwipe: false) {
            Button(role: .destructive) {
                if task.deleted {
                    offlineDeletedTasks.removeAll(where: { $0.id == task.id })
                } else {
                    if let i = offlineTasks.firstIndex(where: { $0.id == task.id }) {
                        offlineTasks.remove(at: i)
                        offlineDeletedTasks.append(CustomTask(id: task.id, title: task.title, description: task.description, creationDate: task.creationDate, dueDate: task.dueDate, completed: task.completed, deleted: true, owner: task.owner, taskMembers: task.taskMembers))
                    }
                }
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                if task.deleted {
                    offlineTasks.append(CustomTask(id: task.id, title: task.title, description: task.description, creationDate: task.creationDate, dueDate: task.dueDate, completed: task.completed, deleted: false, owner: task.owner, taskMembers: task.taskMembers))
                    offlineDeletedTasks.removeAll(where: { $0.id == task.id})
                } else {
                    if let i = offlineTasks.firstIndex(where: { $0.id == task.id }) {
                        let changeBool = !task.completed
                        offlineTasks[i] = CustomTask(id: task.id, title: task.title, description: task.description, creationDate: task.creationDate, dueDate: task.dueDate, completed: changeBool, deleted: task.deleted, owner: task.owner, taskMembers: task.taskMembers)
                    }
                }
            } label: {
                Label("Complete task", systemImage: "checkmark")
            }
            .tint(.blue)
        }
    }
}

struct OfflineTasksView_Previews: PreviewProvider {
    static var previews: some View {
        OfflineTasksView()
    }
}
