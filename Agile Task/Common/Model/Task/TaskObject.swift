//
//  Task.swift
//  Agile Task
//
//  Created by Artur Korol on 09.08.2023.
//

import RealmSwift
import MasterAppsUI
import SwiftUI

class TaskObject: Object, ObjectKeyIdentifiable, CalendarItem {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var parentId: ObjectId
    @Persisted var status: TaskStatus?
    @Persisted var title: String
    @Persisted var taskDescription: String?
    @Persisted var date: Date?
    @Persisted var dateOption: DateType = .none
    @Persisted var time: Date?
    @Persisted var timeOption: TimeOption
    @Persisted var timePeriod: TimePeriod
    @Persisted var recurring: RecurringConfiguration?
    @Persisted var reminder: Reminder?
    @Persisted var reminderDate: Date?
    @Persisted var createdDate: Date = Date()
    @Persisted var modificationDate: Date?
    @Persisted var completedDate: Date?
    @Persisted var colorName: String = Color.sectionColor.name
    @Persisted var isCompleted: Bool = false
    @Persisted var sortingOrder: Int = 0
    @Persisted var showCheckboxes = true
    @Persisted var checkBoxList: RealmSwift.List<CheckboxObject>
    @Persisted var bulletList: RealmSwift.List<BulletObject>
    
    @Persisted(originProperty: "tasks") var assignee: LinkingObjects<ProjectObject>
    
    convenience init(id: ObjectId = ObjectId(), status: TaskStatus = .none, title: String, description: String? = nil, date: Date? = nil, dateOption: DateType = .none, time: Date? = nil, timeOption: TimeOption = .none, timePeriod: TimePeriod, recurring: RecurringConfiguration? = nil, reminder: Reminder = .none, reminderDate: Date? = nil, createdDate: Date = Date(), modificationDate: Date? = nil, completedDate: Date? = nil, colorName: String, isCompleted: Bool, sortingOrder: Int, showCheckboxes: Bool = true, checkBoxList: [CheckboxObject], bulletList: [BulletObject]) {
        self.init()
        self.id = id
        self.parentId = id
        self.status = status
        self.title = title
        self.taskDescription = description
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
        self.checkBoxList.append(objectsIn: checkBoxList)
        self.bulletList.append(objectsIn: bulletList)
    }
    
    var isReminder: Bool {
        guard let reminder else { return false }
        
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
        reminder = dto.reminder
        reminderDate = dto.reminderDate
        createdDate = dto.createdDate
        modificationDate = dto.modificationDate
        completedDate = dto.completedDate
        colorName = dto.colorName
        isCompleted = dto.isCompleted
        showCheckboxes = dto.showCheckboxes
        sortingOrder = dto.sortingOrder
        if let recurring = dto.recurring {
            self.recurring = RecurringConfiguration(recurring)
        }
        
        dto.checkBoxArray.forEach { checkBoxList.append(CheckboxObject($0)) }
        dto.bulletArray.forEach { bulletList.append(BulletObject($0)) }
    }
}

// MARK: - Reminder

enum Reminder: String, PersistableEnum, CaseIterable, Hashable, CustomStringConvertible {
    case none = "None"
    case inOneHour = "In 1 hour"
    case tomorrow = "Tomorrow"
    case nextWeek = "Next week"
    case withRecurring = "Recurring"
    case custom = "Custom"
    
    var description: String {
        self.rawValue
    }
}

// MARK: - RecurringOptions

enum RecurringOptions: String, CaseIterable, PersistableEnum, Hashable, CustomStringConvertible {
    case none = "None"
    case daily = "Daily"
    case inADay = "In a day"
    case weekdays = "Weekdays (Mon to Fri)"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case custom = "Custom"
    
    var description: String {
        self.rawValue
    }
}

// MARK: - DateType

enum DateType: String, CaseIterable, PersistableEnum, Hashable, CustomStringConvertible {
    case none = "None"
    case today = "Today"
    case tomorrow = "Tomorrow"
    case nextWeek = "Next Week"
    case custom = "Custom"
    
    var description: String {
        self.rawValue
    }
}

// MARK: - TimeOption

enum TimeOption: String, CaseIterable, PersistableEnum, Hashable, CustomStringConvertible {
    case none = "None"
    case inOneHour = "In 1 hour"
    case custom = "Custom"
    
    var description: String {
        self.rawValue
    }
}

extension TimePeriod: PersistableEnum {}


// MARK: - TaskStatus

enum TaskStatus: String, CaseIterable, PersistableEnum, Hashable, CustomStringConvertible {
    case none = "None"
    case `do` = "To do"
    case hold = "On hold"
    case important = "Important"
    case urgent = "Urgent"
    case high = "High priority"
    case like = "Like"
    case love = "Love"
    
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
    
    var description: String {
        self.rawValue
    }
}

enum RecurringEnds: String, CaseIterable, PersistableEnum {
    case never = "Never"
    case on = "On"
    case after = "After"
}

enum RepeatRecurring: String, CaseIterable, PersistableEnum {
    case days = "days"
    case weeks = "weeks"
    case month = "month"
    case years = "years"
}

class RecurringConfiguration: EmbeddedObject {
    @Persisted var date: Date = Date()
    @Persisted var option: RecurringOptions = .none
    @Persisted var repeatCount: String = "0"
    @Persisted var repeatEvery: RepeatRecurring = .weeks
    @Persisted var endsOption: RecurringEnds = .never
    @Persisted var endsDate: Date = Date()
    @Persisted var endsAfterOccurrences = "2"
    @Persisted var repeatOnDays: RealmSwift.List<String>
}

extension RecurringConfiguration {
    convenience init(_ dto: RecurringConfigurationDTO) {
        self.init()
        date = dto.date
        option = dto.option
        repeatCount = dto.repeatCount
        repeatEvery = dto.repeatEvery
        endsOption = dto.endsOption
        endsDate = dto.endsDate
        endsAfterOccurrences = dto.endsAfterOccurrences
        
        dto.repeatOnDays.forEach { repeatOnDays.append($0) }
    }
}

struct RecurringConfigurationDTO {
    var date: Date = Date()
    var option: RecurringOptions = .none
    var repeatCount: String = "0"
    var repeatEvery: RepeatRecurring = .weeks
    var endsOption: RecurringEnds = .never
    var endsDate: Date = Date()
    var endsAfterOccurrences = "2"
    var repeatOnDays: [String] = []
}

extension RecurringConfigurationDTO {
    init(_ object: RecurringConfiguration) {
        self.init()
        date = object.date
        option = object.option
        repeatCount = object.repeatCount
        repeatEvery = object.repeatEvery
        endsOption = object.endsOption
        endsDate = object.endsDate
        endsAfterOccurrences = object.endsAfterOccurrences
        
        object.repeatOnDays.forEach { repeatOnDays.append($0) }
    }
}

extension RecurringConfigurationDTO {
    static var mock: Self {
        RecurringConfigurationDTO(
            date: Date(),
            option: .custom,
            repeatCount: "0",
            repeatEvery: .days,
            endsOption: .on,
            endsDate: Date(),
            endsAfterOccurrences: "1",
            repeatOnDays: []
        )
    }
}
