//
//  TaskSettings.swift
//  Agile Task
//
//  Created by Artur Korol on 20.09.2023.
//

import Foundation
import RealmSwift
import MasterAppsUI

final class SettingsObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var startWeekFrom: WeekStarts = .monday
    @Persisted var taskDateFormat: TaskDateFormmat = .dayMonthYear
    @Persisted var timeFormat: TimeFormat = .twentyFour
    @Persisted var taskDateSorting: TaskDateSorting = .all
    @Persisted var addNewTaskIn: AddingNewTask? = .top
    @Persisted var completedTask: CompletedTask? = .moveToBottom
    @Persisted var defaultReminder: DefaultReminder = .oneHourBefore
    @Persisted var showPlusButton: Bool = true
    @Persisted var isPushNotificationEnabled: Bool = true
    @Persisted var rememberLastPickedOptionView: Bool = true
    @Persisted var taskSorting: TaskSorting? = .manual
    @Persisted var securityOption: SecurityOption = .none
}

extension SettingsObject {
    convenience init(dto: SettingsDTO) {
        self.init()
        
        id = dto.id
        startWeekFrom = dto.startWeekFrom
        taskDateFormat = dto.taskDateFormat
        timeFormat = dto.timeFormat
        taskDateSorting = dto.taskDateSorting
        addNewTaskIn = dto.addNewTaskIn
        completedTask = dto.completedTask
        defaultReminder = dto.defaultReminder
        showPlusButton = dto.showPlusButton
        isPushNotificationEnabled = dto.isPushNotificationEnabled
        rememberLastPickedOptionView = dto.rememberLastPickedOptionView
        taskSorting = dto.taskSorting
        securityOption = dto.securityOption
    }
}

enum TaskSorting: String, PersistableEnum, CaseIterable {
    case manual = "Manual (Drag and Drop)"
    case schedule = "Tasks with schedule on top"
    case reminders = "Tasks with reminders on top"
    case recurring = "Recurring tasks on top"
}

enum WeekStarts: String, PersistableEnum, CaseIterable {
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
}

enum TaskDateFormmat: String, PersistableEnum, CaseIterable {
    case dayMonthYear = "dd/mm/yy"
    case weekDayDayMonthYear = "Wed, dd/mm/yy"
    case monthDayYear = "mm/dd/yy"
    case weekDayMonthDayYear = "Wed, mm/dd/yy"
    case weekDayDayNumberShortMoth = "Wed, 22 Nov"
    case dayNumberShortMonthFullYear = "22 Nov 2024"
    case dayNumberShortMonth = "22 Nov"
}

enum AddingNewTask: String, PersistableEnum, CaseIterable {
    case bottom = "At the bottom of the list"
    case top = "On top of the list"
}

enum CompletedTask: String, PersistableEnum, CaseIterable {
    case hide = "Hide from the list"
    case moveToBottom = "Move to the bottom of the list"
}

enum DefaultReminder: String, PersistableEnum, CaseIterable {
    case same = "Same time as date"
    case oneHourBefore = "One hour before the date"
    case none = "None"
}

enum SecurityOption: String, PersistableEnum, CaseIterable {
    case password = "Password"
    case faceID = "Face ID"
    case none = "None"
}

extension TimeFormat: PersistableEnum {}
extension TaskDateSorting: PersistableEnum {}