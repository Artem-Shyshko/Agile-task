//
//  CompletedTaskViewModel.swift
//  Master Task
//
//  Created by Artur Korol on 18.10.2023.
//

import SwiftUI
import RealmSwift

final class CompletedTaskViewModel: ObservableObject {
    @Published var completedTasks = [TaskDTO]()
    @Published var isSearchBarHidden: Bool = true
    @Published var searchText: String = ""
    @Published var showDeleteAlert: Bool = false
    @Published var showRestoreAlert: Bool = false
    
    let taskRepository: TaskRepository = TaskRepositoryImpl()
    let projectRepository: ProjectRepository = ProjectRepositoryImpl()
    
    init() {
        let selectedProject = projectRepository.getSelectedProject()
        completedTasks = selectedProject.tasks.filter { $0.isCompleted }
    }
    
    func updateTask(_ task: TaskDTO) {
        if let taskIndex = completedTasks.firstIndex(where: { $0.id == task.id}) {
            completedTasks[taskIndex].isCompleted.toggle()
            completedTasks[taskIndex].completedDate = task.isCompleted ? Date() : nil
            taskRepository.saveTask(completedTasks[taskIndex])
            completedTasks.remove(at: taskIndex)
        }
    }
    
}
