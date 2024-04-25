//
//  ProjectViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 28.12.2023.
//

import Foundation

final class ProjectsViewModel: ObservableObject {
    @Published var savedProjects: [ProjectDTO] = []
    @Published var isSearchBarHidden: Bool = true
    @Published var searchText: String = ""
    let projectsRepo: ProjectRepository = ProjectRepositoryImpl()
    let taskRepo: TaskRepository = TaskRepositoryImpl()
    
    init() {
        savedProjects = projectsRepo.getProjects()
    }
    
    func selectProject(_ project: ProjectDTO) {
        if let index = savedProjects.firstIndex(where: { $0.id == project.id}) {
            
            for (index, _) in self.savedProjects.enumerated() {
                savedProjects[index].isSelected = false
            }
            
            savedProjects[index].isSelected = true
            projectsRepo.saveAll(savedProjects)
        }
    }
    
    func deleteProject(_ project: ProjectDTO) {
        guard project.isSelected == false else { return }
        savedProjects.removeAll(where: { $0.id == project.id })
        project.tasks.forEach { task in
            taskRepo.deleteAll(where: task.id)
        }
        projectsRepo.deleteProject(project)
    }
}
