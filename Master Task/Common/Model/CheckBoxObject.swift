//
//  CheckBoxObject.swift
//  Master Task
//
//  Created by Artur Korol on 30.10.2023.
//

import RealmSwift

class CheckBoxObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var isCompleted: Bool = false
    
    convenience init(
        title: String
    ) {
        self.init()
        self.title = title
    }
}
