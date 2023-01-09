//
//  SharedTaskListViewModel.swift
//  tasked
//
//  Created by Darko Skerlevski on 6.1.23.
//

import Foundation
import Combine

class SharedTaskListViewModel: ObservableObject {
    @Published var taskRepository = SharedTaskRepository()
    @Published var taskCellViewModels = [SharedTaskCellViewModel]()
    @Published var deletedTaskCellViewModels = [SharedTaskCellViewModel]()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        taskRepository.$tasks.map { tasks in
            tasks.map { task in
                SharedTaskCellViewModel(task: task)
            }
        }
        .assign(to: \.taskCellViewModels, on: self)
        .store(in: &cancellables)
        
        taskRepository.$deletedTasks.map { tasks in
            tasks.map { task in
                SharedTaskCellViewModel(task: task)
            }
        }
        .assign(to: \.deletedTaskCellViewModels, on: self)
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
    
    func removeTaskMember(task: CustomTask, memberID: String) {
        taskRepository.removeTaskMember(task, memberID: memberID)
    }
    
}
