//
//  AddNewOfflineTask.swift
//  tasked
//
//  Created by Darko Skerlevski on 11.1.23.
//

import SwiftUI
import AlertToast

struct AddNewOfflineTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var taskName: String
    @State var taskCompletion: Bool
    @State var createNewTask: Bool
    @State private var showingAlert = false
    @State var task: CustomTask
    @AppStorage("offlineTasks") var offlineTasks: [CustomTask] = [CustomTask]()
    @AppStorage("offlineDeletedTasks") var offlineDeletedTasks: [CustomTask] = [CustomTask]()
    
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
                    .padding(.bottom, 20)
            }
            else {
                Text("Edit task")
                    .padding(.bottom, 20)
            }
            TextField("Task name", text: $taskName)
            Text("description")
                .font(.title3.smallCaps())
            TextEditor(text: $task.description)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .frame(height: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.gray, lineWidth: 4)
                )
            Toggle(isOn: $taskCompletion) {
                Text("Completed?")
            }
            if !createNewTask {
                HStack {
                    Text("Creation date: ")
                    Spacer()
                    Text(task.creationDate)
                }
            }
            HStack {
                Text("Due date: ")
                Spacer()
                DatePicker("Select a date", selection: $task.dueDate, displayedComponents: .date)
                    .labelsHidden()
            }
        }
        .padding(.all, 30)
        .toast(isPresenting: $showingAlert) {
            AlertToast(displayMode: .banner(.slide), type: .error(.red), title: "Failure", subTitle: "Task name cannot be empty!")
        }
        .toolbar {
            ToolbarItem {
                Button(action: {
                    if !taskName.isEmpty {
                        if createNewTask {
                            offlineTasks.append(CustomTask  (title: taskName, description: task.description, dueDate: task.dueDate, completed: taskCompletion, deleted: false, owner: "", taskMembers: [""]))
                        }
                        else {
                            task.title = taskName
                            task.completed = taskCompletion
                            if !task.deleted {
                                if let i = offlineTasks.firstIndex(where: { $0.id == task.id }) {
                                    offlineTasks[i] = CustomTask(id: task.id, title: taskName, description: task.description, creationDate: task.creationDate, dueDate: task.dueDate, completed: taskCompletion, deleted: task.deleted, owner: task.owner, taskMembers: task.taskMembers)
                                }
                            } else {
                                if let i = offlineDeletedTasks.firstIndex(where: { $0.id == task.id }) {
                                    offlineDeletedTasks[i] = CustomTask(id: task.id, title: taskName, description: task.description, creationDate: task.creationDate, dueDate: task.dueDate, completed: taskCompletion, deleted: task.deleted, owner: task.owner, taskMembers: task.taskMembers)
                                }
                            }
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    else {
                        showingAlert = true
                    }
                }) {
                    if createNewTask {
                        Text("Add")
                    }
                    else {
                        Text("Save")
                    }
                }
            }
        }
        
    }
}

//struct AddNewOfflineTask_Previews: PreviewProvider {
//    static var previews: some View {
//        AddNewOfflineTask()
//    }
//}
