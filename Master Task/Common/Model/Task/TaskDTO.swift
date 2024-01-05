//
//  TaskDTO.swift
//  Agile Task
//
//  Created by Artur Korol on 27.12.2023.
//

import Foundation
import MasterAppsUI
import RealmSwift

struct TaskDTO: CalendarItem {
    var id: ObjectId
    var parentId: ObjectId
    var status: TaskStatus
    var title: String
    var description: String?
    var date: Date?
    var dateOption: DateType = .none
    var time: Date?
    var timeOption: TimeOption
    var timePeriod: TimePeriod
    var recurring: RecurringOptions
    var reminder: Reminder
    var reminderDate: Date?
    var createdDate: Date = Date()
    var modificationDate: Date?
    var completedDate: Date?
    var colorName: String
    var isCompleted: Bool = false
    var sortingOrder: Int = 0
    var showCheckboxes = true
    var checkBoxArray: [CheckboxDTO]
    
    var isReminder: Bool {
        switch reminder {
        case .custom, .inOneHour, .tomorrow, .nextWeek, .withRecurring:
            return true
        case .none:
            return false
        }
    }
    
    var isRecurring: Bool {
        switch recurring {
        case .none:
            return false
        case .daily, .weekly, .monthly, .yearly, .custom, .weekdays:
            return true
        }
    }
}

extension TaskDTO {
    init(object: TaskObject) {
        id = object.id
        parentId = object.parentId
        status = object.status
        title = object.title
        description = object.taskDescription
        date = object.date
        dateOption = object.dateOption
        time = object.time
        timeOption = object.timeOption
        timePeriod = object.timePeriod
        recurring = object.recurring
        reminder = object.reminder
        reminderDate = object.reminderDate
        createdDate = object.createdDate
        modificationDate = object.modificationDate
        completedDate = object.completedDate
        colorName = object.colorName
        isCompleted = object.isCompleted
        sortingOrder = object.sortingOrder
        showCheckboxes = object.showCheckboxes
        checkBoxArray = object.checkBoxList.map { CheckboxDTO(object: $0) }
    }
}

extension TaskDTO: Equatable {
    static func == (lhs: TaskDTO, rhs: TaskDTO) -> Bool {
       if lhs.title == rhs.title,
          lhs.isCompleted == rhs.isCompleted {
           return true
       } else {
           return false
       }
    }
}

extension TaskDTO: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.stringValue)
    }
}
