//
//  TaskSettings.swift
//  Agile Task
//
//  Created by Artur Korol on 20.09.2023.
//

import Foundation
import RealmSwift

final class SettingsObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var appLanguage: AppLanguage?
    @Persisted var startWeekFrom: WeekStarts = .monday
    @Persisted var taskDateFormat: TaskDateFormmat = .monthDayYear
    @Persisted var timeFormat: TimeFormat = .twelve
    @Persisted var taskDateSorting: TaskDateSorting = .all
    @Persisted var addNewTaskIn: AddingNewTask? = .top
    @Persisted var completedTask: CompletedTask? = .moveToBottom
    @Persisted var defaultReminder: DefaultReminder = .oneHourBefore
    @Persisted var dailyReminderOption: DailyReminderOption?
    @Persisted var reminderTime: Date?
    @Persisted var reminderTimePeriod: TimePeriod?
    @Persisted var newTaskFeature: TaskType?
    @Persisted var showPlusButton: Bool = true
    @Persisted var isShowingInfoTips: Bool?
    @Persisted var isPushNotificationEnabled: Bool = true
    @Persisted var rememberLastPickedOptionView: Bool = true
    @Persisted var taskSorting: TaskSorting? = .manual
    @Persisted var securityOption: SecurityOption = .none
    @Persisted var сompletionСircle: Bool = true
    @Persisted var hapticFeedback: Bool = true
    @Persisted var sortingType: SortingType = .manualy
    @Persisted var recordsSecurity: RecordsSecurity = .password
}

extension SettingsObject {
    convenience init(dto: SettingsDTO) {
        self.init()
        
        id = dto.id
        appLanguage = dto.appLanguage
        startWeekFrom = dto.startWeekFrom
        taskDateFormat = dto.taskDateFormat
        timeFormat = dto.timeFormat
        taskDateSorting = dto.taskDateSorting
        addNewTaskIn = dto.addNewTaskIn
        dailyReminderOption = dto.dailyReminderOption
        reminderTime = dto.reminderTime
        reminderTimePeriod = dto.reminderTimePeriod
        completedTask = dto.completedTask
        defaultReminder = dto.defaultReminder
        showPlusButton = dto.showPlusButton
        newTaskFeature = dto.newTaskFeature
        isPushNotificationEnabled = dto.isPushNotificationEnabled
        isShowingInfoTips = dto.isShowingInfoTips
        rememberLastPickedOptionView = dto.rememberLastPickedOptionView
        taskSorting = dto.taskSorting
        securityOption = dto.securityOption
        сompletionСircle = dto.сompletionСircle
        hapticFeedback = dto.hapticFeedback
        sortingType = dto.sortingType
        recordsSecurity = dto.recordsSecurity
    }
}

enum TaskSorting: String, PersistableEnum, CaseIterable {
    case manual = "Manual (Drag and Drop)"
    case schedule = "Tasks with schedule on top"
    case reminders = "Tasks with reminders on top"
    case recurring = "Recurring tasks on top"
    
    var description: String {
        self.rawValue
    }
}

enum WeekStarts: String, PersistableEnum, CaseIterable, CustomStringConvertible {
    case sunday = "Sunday"
    case monday = "Monday"
    
    var value: Int {
        switch self {
        case .sunday:
            return 1
        case .monday:
            return 2
        }
    }
    
    var description: String {
        self.rawValue
    }
}

enum TaskDateFormmat: String, PersistableEnum, CaseIterable, CustomStringConvertible {
    case dayMonthYear = "dd/mm/yy"
    case weekDayDayMonthYear = "Wed, dd/mm/yy"
    case monthDayYear = "mm/dd/yy"
    case weekDayMonthDayYear = "Wed, mm/dd/yy"
    case weekDayDayNumberShortMoth = "Wed, 22 Nov"
    case dayNumberShortMonthFullYear = "22 Nov 2024"
    case dayNumberShortMonth = "22 Nov"
    
    var description: String {
        self.rawValue
    }
}

enum AddingNewTask: String, PersistableEnum, CaseIterable, Hashable, CustomStringConvertible  {
    case bottom = "At the bottom of the list"
    case top = "On top of the list"
    
    var description: String {
        self.rawValue
    }
}

enum AppLanguage: String, PersistableEnum, CaseIterable, Hashable, CustomStringConvertible  {
    case english = "English"
    case ukrainian = "Ukrainian"
    
    var description: String {
        self.rawValue
    }
    
    var identifier: String {
        switch self {
        case .english:
            return "en"
        case .ukrainian:
            return "uk"
        }
    }
}

enum CompletedTask: String, PersistableEnum, CaseIterable, CustomStringConvertible {
    case hide = "Hide from the list"
    case moveToBottom = "Move to the bottom of the list"
    
    var description: String {
        self.rawValue
    }
}

enum DefaultReminder: String, PersistableEnum, CaseIterable, CustomStringConvertible {
    case same = "Same time as date"
    case oneHourBefore = "One hour before the date"
    case none = "None"
    
    var description: String {
        self.rawValue
    }
}

enum SecurityOption: String, PersistableEnum, CaseIterable, CustomStringConvertible {
    case password = "Password"
    case faceID = "Face ID"
    case none = "None"
    
    var description: String {
        self.rawValue
    }
}

extension TimeFormat: PersistableEnum, CustomStringConvertible {
    public var description: String {
        self.rawValue
    }
}

enum TaskDateSorting: String, PersistableEnum, CaseIterable, CustomStringConvertible {
  case all = "All"
  case today = "Today"
  case week = "Week"
  case month = "Month"
    
    public var description: String {
        self.rawValue
    }
}

enum TaskType: String, CaseIterable, CustomStringConvertible, PersistableEnum {
    case light = "task_type_light"
    case advanced = "task_type_advanced"
    
    var description: String {
        self.rawValue
    }
}

enum TimePeriod: String, CaseIterable {
    case pm = "PM"
    case am = "AM"
}

enum TimeFormat: String, CaseIterable {
    case twentyFour = "24h"
    case twelve = "12h"
}
