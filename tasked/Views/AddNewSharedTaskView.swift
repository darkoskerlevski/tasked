//
//  EditSharedTaskView.swift
//  tasked
//
//  Created by Darko Skerlevski on 6.1.23.
//

import SwiftUI
import AlertToast

struct AddNewSharedTaskView: View {
    @State var taskName: String
    @State var taskCompletion: Bool
    @State var createNewTask: Bool
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var taskListVM = SharedTaskListViewModel()
    @ObservedObject var userManager: UserManager
    @ObservedObject var taskInviteRepository = TaskInviteRepository()
    @ObservedObject var taskMembersRepository = TaskMembersRepository()
    @State private var showingAlert = false
    @State private var inviteMember = ""
    @State var task: CustomTask
    
    init(task: CustomTask, createNewTask: Bool, userManager: UserManager) {
        _taskName = State(initialValue: task.title)
        _taskCompletion = State(initialValue: task.completed)
        _createNewTask = State(initialValue: createNewTask)
        _task = State(initialValue: task)
        _userManager = ObservedObject(initialValue: userManager)
        taskMembersRepository.loadTaskMembers(task: task)
    }
    
    var isSendInviteButtonDisabled: Bool {
        inviteMember.contains("@") && inviteMember.contains(".")
    }
    
    var body: some View {
        VStack {
            Group {
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
                if !createNewTask {
                    HStack {
                        TextField("Add members to task by email", text: $inviteMember)
                            .keyboardType(.emailAddress)
                        Button {
                            taskInviteRepository.addInvite(CustomInvite(forTaskID: task.id, forTaskTitle: task.title, forUserEmail: inviteMember, fromEmail: userManager.auth.currentUser!.email!, fromName: userManager.userInfo!.name))
                            inviteMember = ""
                        } label: {
                            Text("Send invite")
                        }
                        .disabled(!isSendInviteButtonDisabled)
                    }
                }
            }
            if !createNewTask {
                Text("Members of this task:")
                    .font(.title3.smallCaps())
                    .padding(.top, 16)
            }
            List {
                ForEach(taskMembersRepository.members, id: \.self) { member in
                    VStack {
                        Text("Email: " + member.email)
                    }
                    .swipeActions(edge: .trailing) {
                        if task.owner == userManager.getUserID() && taskMembersRepository.memberIDPairs[member] != task.owner{
                            Button(role: .destructive) {
                                taskListVM.taskRepository.removeTaskMember(task, memberID: taskMembersRepository.memberIDPairs[member]!)
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .padding([.leading, .trailing], 30)
        .toast(isPresenting: $showingAlert) {
            AlertToast(displayMode: .banner(.slide), type: .error(.red), title: "Failure", subTitle: "Task name cannot be empty!")
        }
        .toolbar {
            ToolbarItem {
                Button(action: {
                    if !taskName.isEmpty {
                        if createNewTask {
                            task.title = taskName
                            task.completed = taskCompletion
                            task.owner = userManager.getUserID()
                            task.taskMembers = [userManager.getUserID()]
                            taskListVM.addTask(task: task)
                        }
                        else {
                            task.title = taskName
                            task.completed = taskCompletion
                            taskListVM.updateTask(task: task)
                        }
                        userManager.userInfo!.sharedTasks.append(task.id)
                        userManager.updateUserData(userInfo: userManager.userInfo!)
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
