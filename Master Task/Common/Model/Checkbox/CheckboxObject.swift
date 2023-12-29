//
//  CheckBoxObject.swift
//  Master Task
//
//  Created by Artur Korol on 30.10.2023.
//

import RealmSwift

class CheckboxObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var isCompleted: Bool = false
    @Persisted var sortingOrder: Int = 0
    
    @Persisted(originProperty: "checkBoxList") var assignee: LinkingObjects<TaskObject>
    
    convenience init(
        title: String
    ) {
        self.init()
        self.title = title
    }
}

extension CheckboxObject {
    convenience init(_ dto: CheckboxDTO) {
        self.init()
        
        id = dto.id
        title = dto.title
        isCompleted = dto.isCompleted
        sortingOrder = dto.sortingOrder
    }
}
