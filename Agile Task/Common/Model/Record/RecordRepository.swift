//
//  RecordRepository.swift
//  Agile Password
//
//  Created by USER on 03.04.2024.
//

import Foundation
import RealmSwift

protocol RecordRepository {
    func getRecordList() -> [RecordDTO]
    func saveRecord(_ data: RecordDTO)
    func saveRecords(_ data: [RecordDTO])
    func deleteRecord(_ id: ObjectId)
    func deleteAll()
    func deleteAll(where id: ObjectId)
    func getRecord(with id: ObjectId) -> RecordDTO?
    func deleteBullet(_ taskId: ObjectId, bulletId: ObjectId)
}

final class RecordRepositoryImpl: RecordRepository {
    private let storage: StorageService
    
    init(storage: StorageService) {
        self.storage = storage
    }
    
    func getRecordList() -> [RecordDTO] {
        let data = storage.fetch(by: RecordObject.self)
        return data.map(RecordDTO.init)
    }
    
    func getRecord(with id: ObjectId) -> RecordDTO? {
        let data = storage.fetch(by: RecordObject.self).first(where: { $0.id == id })
        return data.map(RecordDTO.init)
    }
    
    func saveRecords(_ data: [RecordDTO]) {
        let objects = data.map(RecordObject.init)
        try? storage.saveAll(objects: objects)
    }
    
    func saveRecord(_ data: RecordDTO) {
        try? storage.saveOrUpdateObject(object: RecordObject(data))
    }
    
    func deleteRecord(_ id: ObjectId) {
        if let task = storage.fetch(by: RecordObject.self).first(where: { $0.id == id }) {
            try? storage.delete(object: task)
        }
    }
    
    func deleteAll(where id: ObjectId) {
        let objects = storage.fetch(by: RecordObject.self).filter { $0.id == id }
        try? storage.deleteAll(object: objects)
    }
    
    func deleteAll() {
        let objects = storage.fetch(by: RecordObject.self)
        try? storage.deleteAll(object: objects)
    }
    
    func deleteBullet(_ taskId: ObjectId, bulletId: ObjectId) {
        guard let record = storage.fetch(by: RecordObject.self).first(where: { $0.id == taskId }) else { return }
        guard let bullet = record.bulletList.first(where: { $0.id == bulletId }) else { return }
        
        try? storage.delete(object: bullet)
    }
}
