//
//  SharedTaskCellViewModel.swift
//  tasked
//
//  Created by Darko Skerlevski on 6.1.23.
//

import Combine
import Foundation

class SharedTaskCellViewModel: ObservableObject, Identifiable {
    @Published var taskRepository = SharedTaskRepository()
    @Published var task: CustomTask
    
    var id = ""
    @Published var completionStateIconName = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init(task: CustomTask) {
        self.task = task
        
        $task
            .map { task in
                task.completed ? "checkmark.circle.fill" : "circle"
            }
            .assign(to: \.completionStateIconName, on: self)
            .store(in: &cancellables)
        
        $task
            .compactMap { task in
                task.id
            }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
        
        $task
            .dropFirst()
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .sink { task in
                self.taskRepository.updateTask(task)
            }
            .store(in: &cancellables)
    }
}
