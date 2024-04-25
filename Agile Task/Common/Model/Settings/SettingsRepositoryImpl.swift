//
//  SettingsRepositoryImpl.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 27.12.2023.
//

import Foundation
import RealmSwift

protocol SettingsRepository {
    func get() -> SettingsDTO
    func save(_ data: SettingsDTO)
    func getAsync() async -> SettingsObject?
}

final class SettingsRepositoryImpl: SettingsRepository {
    private let storage: StorageService
    
    init(storage: StorageService = StorageService()) {
        self.storage = storage
    }
    
    func get() -> SettingsDTO {
        let data = storage.fetch(by: SettingsObject.self)
        if let setting = data.map(SettingsDTO.init).first {
            return setting
        } else {
            let settings = SettingsDTO(object: SettingsObject())
            save(settings)
            return settings
        }
    }
    
    func save(_ dto: SettingsDTO) {
        try? storage.saveOrUpdateObject(object: SettingsObject(dto: dto))
    }
    
    func getAsync() async -> SettingsObject? {
        let data = await storage.fetchAsync(by: SettingsObject.self)
        return data.first
    }
}
