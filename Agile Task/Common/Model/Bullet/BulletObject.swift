//
//  BulletObject.swift
//  Agile Task
//
//  Created by Artur Korol on 08.01.2024.
//

import RealmSwift

class BulletObject: Object, ObjectKeyIdentifiable, TaskItem {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var sortingOrder: Int = 0
    
    @Persisted(originProperty: "bulletList") var assignee: LinkingObjects<TaskObject>
    
    convenience init(
        title: String,
        sortingOrder: Int = 0
    ) {
        self.init()
        self.title = title
        self.sortingOrder = sortingOrder
    }
}

extension BulletObject {
    convenience init(_ dto: BulletDTO) {
        self.init()
        
        id = dto.id
        title = dto.title
        sortingOrder = dto.sortingOrder
    }
}
