//
//  File.swift
//  Agile Task
//
//  Created by Artur Korol on 28.12.2023.
//

import Foundation
import RealmSwift

protocol ProjectRepository {
    func getSelectedProject() -> ProjectDTO
    func getProjects() -> [ProjectDTO]
    func saveProject(_ dto: ProjectDTO)
    func saveAll(_ data: [ProjectDTO])
    func deleteProject(_ project: ProjectDTO)
    func saveTask(_ task: TaskDTO)
}

final class ProjectRepositoryImpl: ProjectRepository {
    
    private let storage: StorageService
    
    init(storage: StorageService = StorageService()) {
        self.storage = storage
    }
    
    func getSelectedProject() -> ProjectDTO {
        let data = storage.fetch(by: ProjectObject.self)
        if let project = data.map(ProjectDTO.init).first(where: { $0.isSelected }) {
            return project
        } else {
            var project = ProjectDTO(ProjectObject(name: "General"))
            project.isSelected = true
            saveProject(project)
            return project
        }
    }
    
    func getProjects() -> [ProjectDTO] {
        let data = storage.fetch(by: ProjectObject.self)
        return data.map(ProjectDTO.init)
    }
    
    func saveProject(_ dto: ProjectDTO) {
        try? storage.saveOrUpdateObject(object: ProjectObject(dto))
    }
    
    func saveAll(_ data: [ProjectDTO]) {
        let objects = data.map(ProjectObject.init)
        try? storage.saveAll(objects: objects)
    }
    
    func deleteProject(_ project: ProjectDTO) {
        let objects = storage.fetch(by: ProjectObject.self).filter { $0.id == project.id }
        try? storage.deleteAll(object: objects)
    }
    
    func saveTask(_ data: TaskDTO) {
        if let object = storage.fetch(by: TaskObject.self).first(where: { $0.id == data.id}) {
            try? storage.saveOrUpdateObject(object: object)
        }
    }
}
