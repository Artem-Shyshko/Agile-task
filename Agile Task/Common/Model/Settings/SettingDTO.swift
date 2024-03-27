//
//  SettingDTO.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 27.12.2023.
//

import Foundation
import RealmSwift
import MasterAppsUI

struct SettingsDTO {
    var id: ObjectId
    var appLanguage: AppLanguage = .english
    var startWeekFrom: WeekStarts = .monday
    var taskDateFormat: TaskDateFormmat = .dayMonthYear
    var timeFormat: TimeFormat = .twentyFour
    var taskDateSorting: TaskDateSorting = .today
    var addNewTaskIn: AddingNewTask = .top
    var completedTask: CompletedTask = .hide
    var defaultReminder: DefaultReminder = .oneHourBefore
    var dailyReminderOption: DailyReminderOption = .custom
    var reminderTime: Date = Date()
    var reminderTimePeriod: TimePeriod = .am
    var showPlusButton: Bool = true
    var isShowingInfoTips: Bool = true
    var isPushNotificationEnabled: Bool = true
    var rememberLastPickedOptionView: Bool = true
    var taskSorting: TaskSorting = .manual
    var securityOption: SecurityOption = .none
}

extension SettingsDTO {
    init(object: SettingsObject) {
        id = object.id
        appLanguage = object.appLanguage ?? language
        startWeekFrom = object.startWeekFrom
        taskDateFormat = object.taskDateFormat
        timeFormat = object.timeFormat
        taskDateSorting = object.taskDateSorting
        addNewTaskIn = object.addNewTaskIn ?? .top
        completedTask = object.completedTask ?? .moveToBottom
        dailyReminderOption = object.dailyReminderOption ?? .custom
        reminderTime = object.reminderTime ?? _reminderTime
        reminderTimePeriod = object.reminderTimePeriod ?? .am
        defaultReminder = object.defaultReminder
        showPlusButton = object.showPlusButton
        isPushNotificationEnabled = object.isPushNotificationEnabled
        isShowingInfoTips = object.isShowingInfoTips ?? true
        rememberLastPickedOptionView = object.rememberLastPickedOptionView
        taskSorting = object.taskSorting ?? .manual
        securityOption = object.securityOption
    }
    
    private var language: AppLanguage {
        guard let language = Locale.current.language.languageCode?.identifier else { return .english }
        
        switch language {
        case "uk":
            UserDefaults.standard.set(language, forKey: Constants.shared.appLanguage)
            return .ukrainian
        default:
            UserDefaults.standard.set("en", forKey: Constants.shared.appLanguage)
            return .english
        }
    }
    
    static var region: String {
        guard let region = Locale.current.region?.identifier else { return "US"}
        
        return region
    }
}

private extension SettingsDTO {
    var _reminderTime: Date {
        Constants.shared.calendar.date(
            bySettingHour: 9,
            minute: 00,
            second: 0, of: Date()
        )!
    }
}

extension SettingsDTO: Hashable {}

enum DailyReminderOption: String, PersistableEnum, CaseIterable {
    case none = "None"
    case custom = "Custom"
}
