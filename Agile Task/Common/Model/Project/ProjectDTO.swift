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
    var tasks: [TaskDTO] = []
}

extension ProjectDTO {
    init(_ object: ProjectObject) {
        self.id = object.id
        self.name = object.name
        self.isSelected = object.isSelected
        self.tasks = object.tasks.map(TaskDTO.init)
    }
}

extension ProjectDTO {
    static func mockProject() -> ProjectDTO {
        ProjectDTO(
            id: ObjectId.generate(),
            name: "Default project",
            isSelected: true,
            tasks: TaskDTO.mockArray()
        )
    }
}

extension ProjectDTO: Equatable, Hashable {
    static func == (lhs: ProjectDTO, rhs: ProjectDTO) -> Bool {
        if lhs.id == rhs.id {
           return true
       } else {
           return false
       }
    }
}
