//
//  AddNewTaskView.swift
//  tasked
//
//  Created by Darko Skerlevski on 7.12.22.
//

import SwiftUI

struct AddNewTaskView: View {
    @State var taskName: String = ""
    @State var taskCompletion: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var taskListVM = TaskListViewModel()
    @State private var showingAlert = false
    @State var task: Task?
    
    init(task: Task?) {
        if task != nil {
            taskName = task!.title
            taskCompletion = task!.completed
        }
    }
    
    var body: some View {
        VStack {
            Text("Add a new task")
            TextField("Task name", text: $taskName)
                .foregroundColor(.purple)
            Toggle(isOn: $taskCompletion) {
                Text("Completed?")
            }
            HStack {
                Button(action: {
                    if !taskName.isEmpty {
                        taskListVM.addTask(task: Task(title: taskName, completed: taskCompletion))
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
