//
//  AddNewTaskView.swift
//  tasked
//
//  Created by Darko Skerlevski on 7.12.22.
//

import SwiftUI

struct AddNewTaskView: View {
    @State var taskName: String
    @State var taskCompletion: Bool
    @State var createNewTask: Bool
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var taskListVM = TaskListViewModel()
    @State private var showingAlert = false
    @State var task: CustomTask
    
    init(task: CustomTask, createNewTask: Bool) {
        _taskName = State(initialValue: task.title)
        _taskCompletion = State(initialValue: task.completed)
        _createNewTask = State(initialValue: createNewTask)
        _task = State(initialValue: task)
    }
    
    var body: some View {
        VStack {
            if createNewTask {
                Text("Add a new task")
            }
            else {
                Text("Edit task")
            }
            TextField("Task name", text: $taskName)
                .foregroundColor(.purple)
            Toggle(isOn: $taskCompletion) {
                Text("Completed?")
            }
            HStack {
                Button(action: {
                    if !taskName.isEmpty {
                        if createNewTask {
                            taskListVM.addTask(task: CustomTask(title: taskName, completed: taskCompletion))
                        }
                        else {
                            task.title = taskName
                            task.completed = taskCompletion
                            taskListVM.updateTask(task: task)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    else {
                        showingAlert = true
                    }
                }) {
                    Text("Add")
                }
                .alert("Task name cannot be empty!", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                }
                .padding(.trailing, 40)
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                }
            }
            .padding(.top, 20)
        }
        .padding(.all, 30)
        
    }
}

//struct AddNewTaskView_Previews: PreviewProvider {
//    @State private var task = Task(title: "Temp", completed: false)
//    static var previews: some View {
//        AddNewTaskView(task: $task)
//    }
//}
