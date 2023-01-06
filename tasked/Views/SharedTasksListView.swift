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
    @State var showSettings: Bool = false
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
                                        sharedTaskCellView(taskCellVM: taskCellVM, taskListVM: taskListVM)
                                    }
                                }
                                else
                                {
                                    sharedTaskCellView(taskCellVM: taskCellVM, taskListVM: taskListVM)
                                }
                            }
                        }
                    }
                    HStack {
                        Toggle("", isOn: $showCompleted)
                            .labelsHidden()
                        Text("incomplete?")
                        Spacer()
                        NavigationLink(destination: AddNewTaskView(task: CustomTask(title: "", completed: false), createNewTask: true)) {
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
                .onLoad {
                    self.taskListVM.taskRepository.loadDataShared(taskList: userManager.userInfo!.sharedTasks)
                    print(userManager.userInfo!)
                }
                .navigationTitle("Shared tasks")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    VStack {
                        HStack {
                            Toggle("", isOn: $showCompleted)
                                .labelsHidden()
                            Text("show incomplete only?")
                        }
                        Button("Done") {
                            showSettings = false
                        }
                    }
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
    var body: some View {
        SharedTaskCell(taskCellVM: taskCellVM)
            .swipeActions(allowsFullSwipe: false) {
                Button(role: .destructive) {
                    taskListVM.removeTask(task: taskCellVM.task)
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                    self.taskCellVM.task.completed.toggle()
                } label: {
                    Label("Complete task", systemImage: "checkmark")
                }
                .tint(.blue)
            }
    }
}

struct SharedTaskCell: View {
    @ObservedObject var taskCellVM: SharedTaskCellViewModel
    
    var onCommit: (CustomTask) -> (Void) = {_ in }
    
    var body: some View {
        HStack {
            Image(systemName: taskCellVM.task.completed ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 20, height: 20)
                .onTapGesture {
                    self.taskCellVM.task.completed.toggle()
                }
            NavigationLink(destination: AddNewTaskView(task: taskCellVM.task, createNewTask: false)) {
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
