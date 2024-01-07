//
//  Account.swift
//  Master Task
//
//  Created by Artur Korol on 07.09.2023.
//

import Foundation
import RealmSwift

final class ProjectObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String
    @Persisted var isSelected: Bool = false
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

extension ProjectObject {
    convenience init(_ dto: ProjectDTO) {
        self.init()
        
        self.id = dto.id
        self.name = dto.name
        self.isSelected = dto.isSelected
    }
}
