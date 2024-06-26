//
//  NewProjectViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 29.12.2023.
//

import Foundation

final class NewProjectViewModel: ObservableObject {
    @Published var projectName: String = ""
    @Published var searchIsActive: Bool = false
    @Published var editedProject: ProjectDTO?
    var appState: AppState
    
    init(appState: AppState, editedProject: ProjectDTO? = nil) {
        self.appState = appState
        self.editedProject = editedProject
        self.projectName = editedProject?.name ?? ""
    }
    
    func saveButtonAction() -> Bool {
        if var editedProject {
            editedProject.name = projectName
            appState.projectRepository!.saveProject(editedProject)
            
            return true
        } else {
            var newProject = ProjectDTO(ProjectObject())
            newProject.name = projectName
            appState.projectRepository!.saveProject(newProject)
            
            return true
        }
    }
}
