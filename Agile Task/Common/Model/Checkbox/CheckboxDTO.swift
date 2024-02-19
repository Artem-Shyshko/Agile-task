//
//  CheckboxDTO.swift
//  Agile Task
//
//  Created by Artur Korol on 27.12.2023.
//

import RealmSwift

struct CheckboxDTO {
    var id: ObjectId
    var title: String
    var isCompleted: Bool = false
    var sortingOrder: Int = 0
}

extension CheckboxDTO {
    init(object: CheckboxObject) {
        id = object.id
        title = object.title
        isCompleted = object.isCompleted
        sortingOrder = object.sortingOrder
    }
}
