//
//  AddNewTaskView.swift
//  tasked
//
//  Created by Darko Skerlevski on 7.12.22.
//

import SwiftUI
import AlertToast

struct AddNewTaskView: View {
    @State var taskName: String
    @State var taskCompletion: Bool
    @State var createNewTask: Bool
    @State var showMoveTaskAlert = false
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var taskListVM = TaskListViewModel()
    @ObservedObject var userManager: UserManager
    @State private var showingAlert = false
    @State var task: CustomTask
    
    init(task: CustomTask, createNewTask: Bool, userManager: UserManager) {
        _taskName = State(initialValue: task.title)
        _taskCompletion = State(initialValue: task.completed)
        _createNewTask = State(initialValue: createNewTask)
        _task = State(initialValue: task)
        _userManager = ObservedObject(initialValue: userManager)
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
            .padding(.bottom, 32)
            if !createNewTask && !task.deleted {
                HStack{
                    Spacer()
                    Button {
                        showMoveTaskAlert = true
                    } label: {
                        Text("move to shared tasks")
                            .font(.title3.smallCaps())
                    }
                    .alert(isPresented: $showMoveTaskAlert) {
                        Alert(
                            title: Text("Move task?"),
                            message: Text("Are you sure want to move this task to shared tasks?"),
                            primaryButton: .default(Text("Move"), action: {
                                taskListVM.moveTask(task: task)
                                userManager.userInfo!.sharedTasks.append(task.id)
                                userManager.updateUserData(userInfo: userManager.userInfo!)
                            }),
                            secondaryButton: .destructive(Text("Cancel"), action: { showMoveTaskAlert = false })
                        )
                    }
                    Spacer()
                }
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
                            taskListVM.addTask(task: CustomTask(title: taskName, description: task.description, dueDate: task.dueDate, completed: taskCompletion, deleted: false, owner: userManager.getUserID(), taskMembers: [userManager.getUserID()]))
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

//struct AddNewTaskView_Previews: PreviewProvider {
//    @State private var task = Task(title: "Temp", completed: false)
//    static var previews: some View {
//        AddNewTaskView(task: $task)
//    }
//}
