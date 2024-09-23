//
//  BulletDTO.swift
//  Agile Task
//
//  Created by Artur Korol on 08.01.2024.
//

import RealmSwift

struct BulletDTO: Hashable, Identifiable, TaskItem {
    var id: ObjectId
    var title: String
    var sortingOrder: Int = 0
}

extension BulletDTO {
    init(object: BulletObject) {
        id = object.id
        title = object.title
        sortingOrder = object.sortingOrder
    }
}
