//
//  ContentView.swift
//  tasked
//
//  Created by Darko Skerlevski on 27.10.22.
//

import SwiftUI

struct AllTasksListView: View {
    
    @ObservedObject var taskListVM = TaskListViewModel()
    let tasks = testDataTasks
    @State var presentAddNewItem: Bool = false
    @State var showCompleted: Bool = false
    
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(taskListVM.taskCellViewModels) { taskCellVM in
                        Group {
                            if showCompleted {
                                if !taskCellVM.task.completed {
                                    taskCellView(taskCellVM: taskCellVM)
                                }
                            }
                            else
                            {
                                taskCellView(taskCellVM: taskCellVM)
                            }
                        }
                    }
                }
                HStack {
                    Toggle("", isOn: $showCompleted)
                        .labelsHidden()
                    Text("incomplete?")
                    Spacer()
                    NavigationLink(destination: AddNewTaskView(task: Task(title: "", completed: false), createNewTask: true)) {
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
        }
        
    }
    
    fileprivate func taskCellView(taskCellVM: TaskCellViewModel) -> some View {
        return TaskCell(taskCellVM: taskCellVM)
            .swipeActions(allowsFullSwipe: false) {
                Button(role: .destructive) {
                    taskListVM.removeTask(task: taskCellVM.task)
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
            }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            AllTasksListView()
        }
    }
}

struct TaskCell: View {
    @ObservedObject var taskCellVM: TaskCellViewModel
    
    var onCommit: (Task) -> (Void) = {_ in }
    
    var body: some View {
        HStack {
            Image(systemName: taskCellVM.task.completed ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 20, height: 20)
                .onTapGesture {
                    self.taskCellVM.task.completed.toggle()
                }
//            TextField("Enter a new task", text: $taskCellVM.task.title, onCommit: {
//                self.onCommit(self.taskCellVM.task)
//            })
            NavigationLink(destination: AddNewTaskView(task: taskCellVM.task, createNewTask: false)) {
                Text(taskCellVM.task.title)
            }
        }
    }
}
