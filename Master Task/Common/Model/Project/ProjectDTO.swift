//
//  AccountDTO.swift
//  Agile Task
//
//  Created by Artur Korol on 28.12.2023.
//

import Foundation
import RealmSwift

struct ProjectDTO {
    var id: ObjectId
    var name: String
    var isSelected: Bool = false
    var tasksArray: [TaskDTO]
}

extension ProjectDTO {
    init(_ object: ProjectObject) {
        self.id = object.id
        self.name = object.name
        self.tasksArray = object.tasksList.map { TaskDTO(object: $0) }
        self.isSelected = object.isSelected
    }
}
