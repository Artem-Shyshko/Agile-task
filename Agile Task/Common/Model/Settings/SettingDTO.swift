//
//  SettingDTO.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 27.12.2023.
//

import Foundation
import RealmSwift

struct SettingsDTO {
    var id: ObjectId
    var appLanguage: AppLanguage = .english
    var startWeekFrom: WeekStarts = .monday
    var taskDateFormat: TaskDateFormmat = .monthDayYear
    var timeFormat: TimeFormat = .twelve
    var taskDateSorting: TaskDateSorting = .today
    var addNewTaskIn: AddingNewTask = .top
    var completedTask: CompletedTask = .hide
    var newTaskFeature: TaskType = .advanced
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
    var сompletionСircle: Bool = true
    var hapticFeedback: Bool = true
    var sortingType: SortingType = .manualy
    var recordsSecurity: RecordsSecurity = .password
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
        newTaskFeature = object.newTaskFeature ?? .light
        defaultReminder = object.defaultReminder
        showPlusButton = object.showPlusButton
        isPushNotificationEnabled = object.isPushNotificationEnabled
        isShowingInfoTips = object.isShowingInfoTips ?? true
        сompletionСircle = object.сompletionСircle
        rememberLastPickedOptionView = object.rememberLastPickedOptionView
        taskSorting = object.taskSorting ?? .manual
        securityOption = object.securityOption
        hapticFeedback = object.hapticFeedback
        sortingType = object.sortingType
        recordsSecurity = object.recordsSecurity
    }
    
    private var language: AppLanguage {
        guard let language = Locale.current.language.languageCode?.identifier, UserDefaults.standard.string(forKey: Constants.shared.appLanguage) == nil else { return .english }
        
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

enum DailyReminderOption: String, PersistableEnum, CaseIterable, CustomStringConvertible {
    case none = "None"
    case custom = "Custom"
    
    var description: String {
        self.rawValue
    }
}

enum RecordsSecurity: String, PersistableEnum, CaseIterable, CustomStringConvertible {
    case password = "Password"
    case faceID = "Face ID"
    
    var description: String {
        switch self {
        case .password:
            "password_title"
        case .faceID:
            "face_id_title"
        }
    }
    
    var securityOption: SecurityOption {
        switch self {
        case .password:
            return .password
        case .faceID:
            return .faceID
        }
    }
}
