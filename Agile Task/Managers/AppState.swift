//
//  AppState.swift
//  Agile Task
//
//  Created by Artur Korol on 14.03.2024.
//

import Foundation

final class AppState: ObservableObject {
    @Published var settings: SettingsDTO = SettingsDTO(object: SettingsObject())
    @Published var selectedTab: Tab = .taskList
    
    var storage: StorageService?
    var settingsRepository: SettingsRepository?
    var projectRepository: ProjectRepository?
    var taskRepository: TaskRepository?
    var checkboxRepository: CheckboxRepository?
    var bulletRepository: BulletRepository?
    
    init() {
        let storage = StorageService()
        self.storage = storage
        self.projectRepository = ProjectRepositoryImpl(storage: storage)
        self.settingsRepository = SettingsRepositoryImpl(storage: storage)
        self.taskRepository = TaskRepositoryImpl(storage: storage)
        self.checkboxRepository = CheckboxRepositoryImpl(storage: storage)
        self.bulletRepository = BulletRepositoryImpl(storage: storage)
    }
    
    func restore() {
        storage = nil
        self.projectRepository = nil
        self.settingsRepository = nil
        self.taskRepository = nil
        self.checkboxRepository = nil
        self.bulletRepository = nil
        
        let storage = StorageService()
        self.storage = storage
        self.projectRepository = ProjectRepositoryImpl(storage: storage)
        self.settingsRepository = SettingsRepositoryImpl(storage: storage)
        self.taskRepository = TaskRepositoryImpl(storage: storage)
        self.checkboxRepository = CheckboxRepositoryImpl(storage: storage)
        self.bulletRepository = BulletRepositoryImpl(storage: storage)
    }
}
