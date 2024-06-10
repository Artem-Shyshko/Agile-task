//
//  TaskRepository.swift
//  Agile Task
//
//  Created by Artur Korol on 27.12.2023.
//

import Foundation
import RealmSwift

protocol TaskRepository {
    func getTaskList() -> [TaskDTO]
    func saveTask(_ data: TaskDTO)
    func saveTasks(_ data: [TaskDTO])
    func deleteTask(_ task: TaskObject)
    func deleteAll()
    func deleteAll(where id: ObjectId)
    func saveCheckbox(_ checkbox: CheckboxDTO)
    func deleteCheckbox(_ taskId: ObjectId, checkboxId: ObjectId)
    func saveBullet(_ bullet: BulletDTO)
    func deleteBullet(_ taskId: ObjectId, bulletId: ObjectId)
    func getAll(where id: ObjectId) -> [TaskDTO]
}

final class TaskRepositoryImpl: TaskRepository {
    private let storage: StorageService
    
    init(storage: StorageService) {
        self.storage = storage
    }
    
    func getTaskList() -> [TaskDTO] {
        let data = storage.fetch(by: TaskObject.self)
        return data.map(TaskDTO.init)
    }
    
    func getAll(where id: ObjectId) -> [TaskDTO] {
        let data = storage.fetch(by: TaskObject.self).filter { $0.parentId == id }
        return data.map(TaskDTO.init)
    }
    
    func saveTasks(_ data: [TaskDTO]) {
        let objects = data.map(TaskObject.init)
        try? storage.saveAll(objects: objects)
    }
    
    func saveCheckbox(_ checkbox: CheckboxDTO) {
        try? storage.saveOrUpdateObject(object: CheckboxObject(checkbox))
    }
    
    func saveBullet(_ bullet: BulletDTO) {
        try? storage.saveOrUpdateObject(object: BulletObject(bullet))
    }
    
    func saveTask(_ data: TaskDTO) {
        try? storage.saveOrUpdateObject(object: TaskObject(data))
    }
    
    func deleteTask(_ task: TaskObject) {
        if let task = storage.fetch(by: TaskObject.self).first(where: { $0.id == task.id}) {
            try? storage.delete(object: task)
        }
    }
    
    func deleteAll(where id: ObjectId) {
        let objects = storage.fetch(by: TaskObject.self).filter { $0.parentId == id }
        try? storage.deleteAll(object: objects)
    }
    
    func deleteAll() {
        let objects = storage.fetch(by: TaskObject.self)
        try? storage.deleteAll(object: objects)
    }
    
    func deleteCheckbox(_ taskId: ObjectId, checkboxId: ObjectId) {
        guard let task = storage.fetch(by: TaskObject.self).first(where: { $0.id == taskId }) else { return }
        guard let checkbox = task.checkBoxList.first(where: { $0.id == checkboxId }) else { return }
        
        try? storage.delete(object: checkbox)
    }
    
    func deleteBullet(_ taskId: ObjectId, bulletId: ObjectId) {
        guard let task = storage.fetch(by: TaskObject.self).first(where: { $0.id == taskId }) else { return }
        guard let checkbox = task.bulletList.first(where: { $0.id == bulletId }) else { return }
        
        try? storage.delete(object: checkbox)
    }
}
