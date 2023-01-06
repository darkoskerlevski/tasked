//
//  ContentView.swift
//  tasked
//
//  Created by Darko Skerlevski on 27.10.22.
//

import SwiftUI

struct MyTasksListView: View {
    
    @ObservedObject var userManager: UserManager
    @ObservedObject var taskListVM = TaskListViewModel()
    @State var showSettings: Bool = false
    @State var showCompleted: Bool = false
    
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(taskListVM.taskCellViewModels) { taskCellVM in
                        Group {
                            if showCompleted {
                                if !taskCellVM.task.completed {
                                    taskCellView(taskCellVM: taskCellVM, taskListVM: taskListVM)
                                }
                            }
                            else
                            {
                                taskCellView(taskCellVM: taskCellVM, taskListVM: taskListVM)
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
            .navigationTitle("All tasks")
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
        }
        
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            MyTasksListView(userManager: UserManager())
        }
    }
}

struct taskCellView: View {
    @ObservedObject var taskCellVM: TaskCellViewModel
    @ObservedObject var taskListVM: TaskListViewModel
    var body: some View {
        TaskCell(taskCellVM: taskCellVM)
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

struct TaskCell: View {
    @ObservedObject var taskCellVM: TaskCellViewModel
    
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
