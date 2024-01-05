//
//  Task.swift
//  Master Task
//
//  Created by Artur Korol on 09.08.2023.
//

import RealmSwift
import MasterAppsUI
import SwiftUI

class TaskObject: Object, ObjectKeyIdentifiable, CalendarItem {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var parentId: ObjectId
    @Persisted var status: TaskStatus
    @Persisted var title: String
    @Persisted var taskDescription: String?
    @Persisted var date: Date?
    @Persisted var dateOption: DateType = .none
    @Persisted var time: Date?
    @Persisted var timeOption: TimeOption
    @Persisted var timePeriod: TimePeriod
    @Persisted var recurring: RecurringOptions
    @Persisted var reminder: Reminder
    @Persisted var reminderDate: Date?
    @Persisted var createdDate: Date = Date()
    @Persisted var modificationDate: Date?
    @Persisted var completedDate: Date?
    @Persisted var colorName: String = Color.sectionColor.name
    @Persisted var isCompleted: Bool = false
    @Persisted var sortingOrder: Int = 0
    @Persisted var showCheckboxes = true
    @Persisted var checkBoxList: RealmSwift.List<CheckboxObject>
    
    convenience init(
        parentId: ObjectId,
        title: String,
        date: Date?,
        recurring: RecurringOptions,
        reminder: Reminder,
        reminderDate: Date?,
        createdDate: Date,
        colorName: String
    ) {
        self.init()
        self.parentId = parentId
        self.title = title
        self.date = date
        self.dateOption = dateOption
        self.recurring = recurring
        self.reminder = reminder
        self.reminderDate = reminderDate
        self.createdDate = createdDate
        self.colorName = colorName
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
        switch recurring {
        case .none:
            return false
        case .daily, .weekly, .monthly, .yearly, .custom, .weekdays:
            return true
        }
    }
}

// MARK: - Convenience init

extension TaskObject {
    convenience init(_ dto: TaskDTO) {
        self.init()
        id = dto.id
        parentId = dto.parentId
        status = dto.status
        title = dto.title
        taskDescription = dto.description
        date = dto.date
        dateOption = dto.dateOption
        time = dto.time
        timeOption = dto.timeOption
        timePeriod = dto.timePeriod
        recurring = dto.recurring
        reminder = dto.reminder
        reminderDate = dto.reminderDate
        createdDate = dto.createdDate
        modificationDate = dto.modificationDate
        completedDate = dto.completedDate
        colorName = dto.colorName
        isCompleted = dto.isCompleted
        showCheckboxes = dto.showCheckboxes
        sortingOrder = dto.sortingOrder
        
        dto.checkBoxArray.forEach { checkBoxList.append(CheckboxObject($0)) }
    }
}

// MARK: - Reminder

enum Reminder: String, PersistableEnum, CaseIterable {
    case none = "None"
    case inOneHour = "In 1 hour"
    case tomorrow = "Tomorrow at 12 hour"
    case nextWeek = "Next Week at 12 hour"
    case withRecurring = "With recurring"
    case custom = "Custom"
}

// MARK: - RecurringOptions

enum RecurringOptions: String, CaseIterable, PersistableEnum {
    case none = "None"
    case daily = "Daily"
    case weekdays = "Weekdays (Mon to Fri)"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case custom = "Custom"
}

// MARK: - DateType

enum DateType: String, CaseIterable, PersistableEnum {
    case none = "None"
    case today = "Today"
    case tomorrow = "Tomorrow"
    case nextWeek = "Next Week"
    case custom = "Custom"
}

// MARK: - TimeOption

enum TimeOption: String, CaseIterable, PersistableEnum {
    case none = "None"
    case inOneHour = "In 1 hour"
    case custom = "Custom"
}

extension TimePeriod: PersistableEnum {}


// MARK: - TaskStatus

enum TaskStatus: String, CaseIterable, PersistableEnum {
    case none = "None"
    case `do` = "Do"
    case high = "High"
    case hold = "Hold"
    case urgent = "Urgent"
    case important = "Important"
    case love = "Love"
    case like = "Like"
    
    var iconName: String {
        switch self {
        case .none:
            return ""
        case .do:
            return "Do"
        case .high:
            return "High"
        case .hold:
            return "Hold"
        case .urgent:
            return "Urgent"
        case .important:
            return "Important"
        case .love:
            return "Love"
        case .like:
            return "Like"
        }
    }
}
