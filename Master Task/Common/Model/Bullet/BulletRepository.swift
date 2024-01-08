//
//  BulletRepository.swift
//  Agile Task
//
//  Created by Artur Korol on 08.01.2024.
//

import Foundation

protocol BulletRepository {
    func save(_ data: BulletDTO)
}

final class BulletRepositoryImpl: BulletRepository {
    private let storage: StorageService
    
    init(storage: StorageService = StorageService()) {
        self.storage = storage
    }
    
    func save(_ dto: BulletDTO) {
        try? storage.saveOrUpdateObject(object: BulletObject(dto))
    }
}
