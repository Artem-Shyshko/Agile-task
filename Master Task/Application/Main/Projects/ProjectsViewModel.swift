//
//  ProjectViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 28.12.2023.
//

import Foundation

final class ProjectsViewModel: ObservableObject {
    @Published var savedProjects: [ProjectDTO]
    @Published var isAlert = false
    @Published var isSearchBarHidden: Bool = true
    @Published var searchText: String = ""
    @Published var showNewProjectView = false
    let projectsRepo: ProjectRepository = ProjectRepositoryImpl()
    
    init() {
        savedProjects = projectsRepo.getProjects()
    }
    
    func selectAnotherProject(_ project: ProjectDTO) {
        guard !project.isSelected else { return }
        
        let selectedProject = projectsRepo.getSelectedProject()
        
        if let index = savedProjects.firstIndex(where: {$0.id == selectedProject.id }) {
            savedProjects[index].isSelected = false
            projectsRepo.saveProject(savedProjects[index])
        }
        
        if let index = savedProjects.firstIndex(where: {$0.id == project.id }) {
            savedProjects[index].isSelected = true
            projectsRepo.saveProject(savedProjects[index])
        }
    }
    
    func deleteProject(_ project: ProjectDTO) {
        projectsRepo.deleteProject(project)
        savedProjects.removeAll(where: {$0.id == project.id} )
    }
}
