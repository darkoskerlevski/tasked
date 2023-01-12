//
//  TaskListViewModel.swift
//  tasked
//
//  Created by Darko Skerlevski on 31.10.22.
//

import Foundation
import Combine

class TaskListViewModel: ObservableObject {
    @Published var taskRepository = TaskRepository()
    @Published var taskCellViewModels = [TaskCellViewModel]()
    @Published var deletedTaskCellViewModels = [TaskCellViewModel]()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        taskRepository.$tasks.map { tasks in
            tasks.map { task in
                TaskCellViewModel(task: task)
            }
        }
        .assign(to: \.taskCellViewModels, on: self)
        .store(in: &cancellables)
        
        taskRepository.$deletedTasks.map { tasks in
            tasks.map { task in
                TaskCellViewModel(task: task)
            }
        }
        .assign(to: \.deletedTaskCellViewModels, on:self)
        .store(in: &cancellables)
    }
    
    func addTask(task: CustomTask) {
        taskRepository.addTask(task)
    }
    
    func updateTask(task: CustomTask) {
        taskRepository.updateTask(task)
    }
    
    func removeTask(task: CustomTask) {
        taskRepository.removeTask(task)
    }
    
    func restoreTask(task: CustomTask) {
        taskRepository.restoreTask(task)
    }
    
    func moveTask(task: CustomTask) {
        taskRepository.moveTask(task)
    }
    
}
