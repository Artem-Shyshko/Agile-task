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
    var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
        savedProjects = appState.projectRepository!.getProjects()
    }
    
    func selectProject(_ project: ProjectDTO) {
        if let index = savedProjects.firstIndex(where: { $0.id == project.id}) {
            
            for (index, _) in self.savedProjects.enumerated() {
                savedProjects[index].isSelected = false
            }
            
            savedProjects[index].isSelected = true
            appState.projectRepository!.saveAll(savedProjects)
        }
    }
    
    func deleteProject(_ project: ProjectDTO) {
        guard project.isSelected == false else { return }
        savedProjects.removeAll(where: { $0.id == project.id })
        project.tasks.forEach { task in
            appState.taskRepository!.deleteAll(where: task.id)
        }
        appState.projectRepository!.deleteProject(project)
    }
}
