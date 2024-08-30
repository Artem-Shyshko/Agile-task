//
//  RecordObject.swift
//  Agile Password
//
//  Created by USER on 03.04.2024.
//

import RealmSwift
import SwiftUI

final class RecordObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var recordDescription: String?
    @Persisted var bulletList: RealmSwift.List<BulletObject>
    @Persisted var userName: String
    @Persisted var password: String
    @Persisted var titleText: RealmSwift.List<String>
    @Persisted var passwordText: RealmSwift.List<String>
    @Persisted var email: RealmSwift.List<String>
    @Persisted var url: RealmSwift.List<String>
    @Persisted var number: RealmSwift.List<String>
    @Persisted var date: RealmSwift.List<String>
    @Persisted var listOfBulletList: RealmSwift.List<ListOfBulletObject>
    @Persisted var address: RealmSwift.List<String>
    @Persisted var phone: RealmSwift.List<String>
    @Persisted var protection: Protection
    @Persisted var autoClose: AutoClose
    @Persisted var sortingOrder: Int = 0
    @Persisted var fieldsList: RealmSwift.List<FieldObject>
}

// MARK: - Convenience init
extension RecordObject {
    convenience init(_ dto: RecordDTO) {
        self.init()
        id = dto.id
        title = dto.openRecordInfo.title
        recordDescription = dto.openRecordInfo.recordDescription
        dto.openRecordInfo.bulletInfo.forEach { bulletList.append(BulletObject($0)) }
        userName = dto.protectedRecordInfo.userName
        password = dto.protectedRecordInfo.password
        dto.protectedRecordInfo.fields.enumerated().forEach { index, fieldInfo in
            switch fieldInfo {
            case .title(let title):
                self.fieldsList.append(FieldObject(type: .title, title: title, sortingOrder: index))
            case .password(let password):
                self.fieldsList.append(FieldObject(type: .password, title: password, sortingOrder: index))
            case .email(let email):
                self.fieldsList.append(FieldObject(type: .email, title: email, sortingOrder: index))
            case .url(let url):
                self.fieldsList.append(FieldObject(type: .url, title: url, sortingOrder: index))
            case .number(let number):
                self.fieldsList.append(FieldObject(type: .number, title: number, sortingOrder: index))
            case .date(let date):
                self.fieldsList.append(FieldObject(type: .date, title: date, sortingOrder: index))
            case .bulletList(let listDTO):
                var list: RealmSwift.List<BulletObject> = List<BulletObject>()
                listDTO.forEach { list.append(BulletObject($0)) }
                self.fieldsList.append(FieldObject(type: .bulletList, listObBullet: list, sortingOrder: index))
            case .address(let address):
                self.fieldsList.append(FieldObject(type: .address, title: address, sortingOrder: index))
            case .phone(let phone):
                self.fieldsList.append(FieldObject(type: .phone, title: phone, sortingOrder: index))
            }
        }
        protection = dto.settingsRecordInfo.protectWith
        autoClose = dto.settingsRecordInfo.autoClose
        sortingOrder = dto.sortingOrder
    }
}

// MARK: - FieldObject
class FieldObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var type: FieldsType
    @Persisted var title: String = ""
    @Persisted var listObBullet: RealmSwift.List<BulletObject>
    @Persisted var sortingOrder: Int = 0
    
    @Persisted(originProperty: "fieldsList") var assignee: LinkingObjects<RecordObject>
    
    convenience init(
        title: String,
        sortingOrder: Int = 0
    ) {
        self.init()
        self.title = title
        self.sortingOrder = sortingOrder
    }
}

extension FieldObject {
    convenience init(type: FieldsType,
                     title: String = "",
                     listObBullet: RealmSwift.List<BulletObject> = List<BulletObject>(),
                     sortingOrder: Int) {
        self.init()
        self.type = type
        self.title = title
        self.listObBullet = listObBullet
        self.sortingOrder = sortingOrder
    }
}

// MARK: - ListOfBulletObject
class ListOfBulletObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var listOfBulletList: RealmSwift.List<BulletObject>
    
    @Persisted(originProperty: "listOfBulletList") var assignee: LinkingObjects<RecordObject>
    
    convenience init(
        lists: [BulletObject]
    ) {
        self.init()
        lists.forEach { listOfBulletList.append(BulletObject(value: $0)) }
    }
}

extension ListOfBulletObject {
    convenience init(dto: [BulletDTO]) {
        self.init()
        id = ObjectId.generate()
        dto.forEach { listOfBulletList.append(BulletObject($0)) }
    }
}

