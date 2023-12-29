//
//  ProjectViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 28.12.2023.
//

import Foundation

final class ProjectsViewModel: ObservableObject {
    @Published var savedProjects: [ProjectDTO]
    let projectsRepo: ProjectRepository = ProjectRepositoryImpl()
    
    init() {
        savedProjects = projectsRepo.getProjects()
    }
    
    func selectAnotherProject(_ project: ProjectDTO) {
        guard !project.isSelected else { return }
        
        var selectedProject = projectsRepo.getSelectedProject()
        selectedProject.isSelected = false
        projectsRepo.saveProject(selectedProject)
        
        var projectToEdit = project
        projectToEdit.isSelected = true
        projectsRepo.saveProject(projectToEdit)
    }
    
    func deleteProject(_ project: ProjectDTO) {
        projectsRepo.deleteProject(project)
        savedProjects.removeAll(where: {$0.id == project.id} )
    }
}
