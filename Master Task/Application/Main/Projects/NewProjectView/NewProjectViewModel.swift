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
    let projectRepo: ProjectRepository = ProjectRepositoryImpl()
    
    init(editedProject: ProjectDTO? = nil) {
        self.editedProject = editedProject
    }
    
    @MainActor 
    func saveButtonAction(purchaseManager: PurchaseManager) -> Bool {
        if var editedProject {
            editedProject.name = projectName
            projectRepo.saveProject(editedProject)
            
            return true
        } else {
            guard purchaseManager.hasUnlockedPro else { return false }
            
            var newProject = ProjectDTO(ProjectObject())
            newProject.name = projectName
            projectRepo.saveProject(newProject)
            
            return true
        }
    }
}
