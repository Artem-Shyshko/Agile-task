//
//  RecordDTO.swift
//  Agile Password
//
//  Created by USER on 03.04.2024.
//

import Foundation
import RealmSwift

// MARK: - RecordDTO
struct RecordDTO {
    var id: ObjectId
    var openRecordInfo: OpenRecordInfo
    var protectedRecordInfo: ProtectedRecordInfo
    var settingsRecordInfo: SettingsRecordInfo
    var sortingOrder: Int = 0
}

// MARK: - RecordDTO Init
extension RecordDTO {
    init(object: RecordObject) {
        id = object.id
        openRecordInfo = OpenRecordInfo(title: object.title, 
                                        recordDescription: object.recordDescription ?? "",
                                        bulletInfo: object.bulletList.map { BulletDTO(object: $0) })
        protectedRecordInfo = ProtectedRecordInfo(userName: object.userName,
                                                  password: object.password,
                                                  fields: [])
        settingsRecordInfo = SettingsRecordInfo(protectWith: object.protection,
                                                autoClose: object.autoClose)
        sortingOrder = object.sortingOrder
        
        var fields = [FieldsInfo]()
        fields += returnFieldsInfoFrom(object)
        protectedRecordInfo.fields = fields
    }
    
    func returnFieldsInfoFrom(_ object: RecordObject) -> [FieldsInfo] {
        var fields = [FieldsInfo]()
        
        let objectList = object.fieldsList.sorted { $0.sortingOrder < $1.sortingOrder }
        
        objectList.forEach { fieldInfo in
            switch fieldInfo.type {
            case .title:
                fields.append(FieldsInfo.title(fieldInfo.title))
            case .password:
                fields.append(FieldsInfo.password(fieldInfo.title))
            case .email:
                fields.append(FieldsInfo.email(fieldInfo.title))
            case .url:
                fields.append(FieldsInfo.url(fieldInfo.title))
            case .number:
                fields.append(FieldsInfo.number(fieldInfo.title))
            case .date:
                fields.append(FieldsInfo.date(fieldInfo.title))
            case .bulletList:
                let bulletList = Array(fieldInfo.listObBullet.map { BulletDTO(object: $0) })
                fields.append(FieldsInfo.bulletList(bulletList))
            case .address:
                fields.append(FieldsInfo.address(fieldInfo.title))
            case .phone:
                fields.append(FieldsInfo.phone(fieldInfo.title))
            }
        }
        
        return fields
    }
}


// MARK: - Equatable
extension RecordDTO: Equatable {
    static func == (lhs: RecordDTO, rhs: RecordDTO) -> Bool {
        if lhs.openRecordInfo.title == rhs.openRecordInfo.title,
           lhs.protectedRecordInfo.password == rhs.protectedRecordInfo.password {
            return true
        } else {
            return false
        }
    }
}

// MARK: - Hashable
extension RecordDTO: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.stringValue)
    }
}
