//
//  CheckboxRepository.swift
//  Agile Task
//
//  Created by Artur Korol on 27.12.2023.
//

import Foundation

protocol CheckboxRepository {
    func getAll() -> [CheckboxDTO]
    func save(_ data: CheckboxDTO)
    func delete(_ data: CheckboxDTO)
}

final class CheckboxRepositoryImpl: CheckboxRepository {
    private let storage: StorageService
    
    init(storage: StorageService) {
        self.storage = storage
    }
    
    func getAll() -> [CheckboxDTO] {
        let data = storage.fetch(by: CheckboxObject.self).map(CheckboxDTO.init)
        return data
    }
    
    func save(_ dto: CheckboxDTO) {
        try? storage.saveOrUpdateObject(object: CheckboxObject(dto))
    }
    
    func delete(_ data: CheckboxDTO) {
        try? storage.delete(object: CheckboxObject(data))
    }
}
