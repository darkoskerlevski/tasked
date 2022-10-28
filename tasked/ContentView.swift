//
//  ContentView.swift
//  tasked
//
//  Created by Darko Skerlevski on 27.10.22.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: tasksViewModel
    
    var tasks = [Task(id: UUID.init(), taskName: "Test task 1", taskDesc: "Default Task Desc 1", timeSpent: "5min", status: "In Progress"),
                 Task(id: UUID.init(), taskName: "Test task 2", taskDesc: "Default Task Desc 2", timeSpent: "10min", status: "Completed")]
    
    var body: some View {
        ZStack{
            List {
                ForEach(tasks) { section in
                    Text(section.id.uuidString)
                    Text(section.taskName)
                    Text(section.taskDesc)
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                    }, label: {
                        Text("+")
                            .font(.system(.largeTitle))
                            .frame(width: 77, height: 70)
                            .foregroundColor(Color.white)
                            .padding(.bottom, 7)
                    }).background(Color.blue)
                        .cornerRadius(38.5)
                        .padding()
                        .shadow(color: Color.black.opacity(0.3),
                                radius: 3,
                                x: 3,
                                y: 3)
                    //                    if viewModel != array.last {
                    //                        Divider()
                    //                    }
                }
            }
        }
    }
    
    //struct ContentView_Previews: PreviewProvider {
    //    static var previews: some View {
    //        ContentView()
    //    }
    //}
}
