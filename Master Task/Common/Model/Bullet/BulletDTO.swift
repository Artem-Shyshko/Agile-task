//
//  BulletDTO.swift
//  Agile Task
//
//  Created by Artur Korol on 08.01.2024.
//

import RealmSwift

struct BulletDTO {
    var id: ObjectId
    var title: String
    var isCompleted: Bool = false
    var sortingOrder: Int = 0
}

extension BulletDTO {
    init(object: BulletObject) {
        id = object.id
        title = object.title
        isCompleted = object.isCompleted
        sortingOrder = object.sortingOrder
    }
}
