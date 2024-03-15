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
    var showPlusButton: Bool = true
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
        defaultReminder = object.defaultReminder
        showPlusButton = object.showPlusButton
        isPushNotificationEnabled = object.isPushNotificationEnabled
        rememberLastPickedOptionView = object.rememberLastPickedOptionView
        taskSorting = object.taskSorting ?? .manual
        securityOption = object.securityOption
    }
    
    private var language: AppLanguage {
        guard let region = Locale.current.region?.identifier else { return .english }
        
        switch region {
        case "UA":
            return .ukrainian
        default:
            return .english
        }
    }
}

extension SettingsDTO: Hashable {}
