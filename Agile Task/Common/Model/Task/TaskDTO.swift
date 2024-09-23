//
//  TaskDTO.swift
//  Agile Task
//
//  Created by Artur Korol on 27.12.2023.
//

import Foundation
import RealmSwift
import SwiftUI

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
    var recurring: RecurringConfigurationDTO?
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
    var bulletArray: [BulletDTO]
    var taskType: TaskType
    
    init(id: ObjectId = ObjectId(), status: TaskStatus = .none, title: String, description: String? = nil, date: Date? = nil, dateOption: DateType = .none, time: Date? = nil, timeOption: TimeOption = .none, timePeriod: TimePeriod, recurring: RecurringConfigurationDTO? = nil, reminder: Reminder = .none, reminderDate: Date? = nil, createdDate: Date = Date(), modificationDate: Date? = nil, completedDate: Date? = nil, colorName: String, isCompleted: Bool, sortingOrder: Int, showCheckboxes: Bool = true, checkBoxArray: [CheckboxDTO], bulletArray: [BulletDTO], taskType: TaskType) {
        self.id = id
        self.parentId = id
        self.status = status
        self.title = title
        self.description = description
        self.date = date
        self.dateOption = dateOption
        self.time = time
        self.timeOption = timeOption
        self.timePeriod = timePeriod
        self.recurring = recurring
        self.reminder = reminder
        self.reminderDate = reminderDate
        self.createdDate = createdDate
        self.modificationDate = modificationDate
        self.completedDate = completedDate
        self.colorName = colorName
        self.isCompleted = isCompleted
        self.sortingOrder = sortingOrder
        self.showCheckboxes = showCheckboxes
        self.checkBoxArray = checkBoxArray
        self.bulletArray = bulletArray
        self.taskType = taskType
    }
    
    var isReminder: Bool {
        switch reminder {
        case .custom, .inOneHour, .tomorrow, .nextWeek, .withRecurring:
            return true
        case .none:
            return false
        }
    }
    
    var isRecurring: Bool {
        guard let recurring else { return false }
        switch recurring.option {
        case .none:
            return false
        case .daily, .weekly, .monthly, .yearly, .custom, .weekdays, .inADay:
            return true
        }
    }
}

extension TaskDTO {
    init(object: TaskObject) {
        id = object.id
        parentId = object.parentId
        status = object.status ?? .none
        title = object.title
        description = object.taskDescription
        date = object.date
        dateOption = object.dateOption
        time = object.time
        timeOption = object.timeOption
        timePeriod = object.timePeriod
        reminder = object.reminder ?? .none
        reminderDate = object.reminderDate
        createdDate = object.createdDate
        modificationDate = object.modificationDate
        completedDate = object.completedDate
        colorName = object.colorName
        isCompleted = object.isCompleted
        sortingOrder = object.sortingOrder
        showCheckboxes = object.showCheckboxes
        checkBoxArray = object.checkBoxList.map { CheckboxDTO(object: $0) }.defaultSorting()
        bulletArray = object.bulletList.map { BulletDTO(object: $0) }.defaultSorting()
        taskType = object.taskType ?? .light
        
        if let recurringConfig = object.recurring {
            self.recurring = RecurringConfigurationDTO(recurringConfig)
        }
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

extension TaskDTO {
    static func mockArray() -> [TaskDTO] {
        [
            TaskDTO(
                id: ObjectId.generate(),
                status: .love,
                title: "welcome_task_mock",
                date: Date(),
                dateOption: .today,
                time: Date(),
                timeOption: .custom,
                timePeriod: .am,
                recurring: RecurringConfigurationDTO.mock,
                reminder: .inOneHour,
                reminderDate: Date(),
                colorName: Color.nyanza.name,
                isCompleted: false,
                sortingOrder: 0,
                showCheckboxes: false,
                checkBoxArray: [],
                bulletArray: [], 
                taskType: .advanced
            ),
            TaskDTO(
                id: ObjectId.generate(),
                status: .high,
                title: "todo_task_mock",
                dateOption: .today,
                timeOption: .none,
                timePeriod: .am,
                reminder: .none,
                colorName: Color.sectionColor.name,
                isCompleted: false,
                sortingOrder: 1,
                showCheckboxes: true,
                checkBoxArray: [],
                bulletArray: [
                    .init(id: .generate(), title: "Create tasks list", sortingOrder: 0),
                    .init(id: .generate(), title: "Find tasks easier with advanced navigation ", sortingOrder: 1),
                    .init(id: .generate(), title: "Share your task list", sortingOrder: 2)
                ],
                taskType: .advanced
            ),
            TaskDTO(
                id: ObjectId.generate(),
                status: .none,
                title: "groceries_task_mock",
                dateOption: .today,
                timeOption: .none,
                timePeriod: .am,
                reminder: .none,
                colorName: Color.sectionColor.name,
                isCompleted: false,
                sortingOrder: 1,
                showCheckboxes: true,
                checkBoxArray: [
                    .init(id: .generate(), title: "Limon", sortingOrder: 0),
                    .init(id: .generate(), title: "Sugar", sortingOrder: 1),
                    .init(id: .generate(), title: "Soda", sortingOrder: 2)
                ],
                bulletArray: [],
                taskType: .advanced
            )
        ]
    }
}

protocol TaskItem {
    var id: ObjectId { get set }
    var title: String { get set }
    var sortingOrder: Int { get set }
}

extension Array where Element: TaskItem {
    func defaultSorting() -> [Element] {
        self
            .sorted(by: {$0.sortingOrder < $1.sortingOrder})
    }
}
