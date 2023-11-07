//
//  SettingsTaskViewModel.swift
//  Master Task
//
//  Created by Artur Korol on 02.10.2023.
//

import Foundation

final class SettingsTaskViewModel: ObservableObject {
    @Published var startWeekFrom: WeekStarts = .sunday
    @Published var timeFormat: TimeFormat = .twentyFour
    @Published var taskDateFormat: TaskDateFormmat = .dayFirst
    @Published var taskDateSorting: TaskDateSorting = .today
    @Published var addNewTaskIn: AddingNewTask = .top
    @Published var completedTask: CompletedTask = .leave
    @Published var defaultReminder: DefaultReminder = .none
    @Published var showPlusButton = true
    @Published var isPushNotificationEnabled = true
    @Published var rememberLastPickedOptionView = true
    
    func getAppVersion() -> String {
      if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        return version
      } else {
        return "x.x"
      }
    }
    
    func loadSettings(from settings: TaskSettings) {
        startWeekFrom = settings.startWeekFrom
        taskDateFormat = settings.taskDateFormat
//        timeFormat = settings.timeFormat
        taskDateSorting = settings.taskDateSorting
        addNewTaskIn = settings.addNewTaskIn
        completedTask = settings.completedTask
        defaultReminder = settings.defaultReminder
        showPlusButton = settings.showPlusButton
        isPushNotificationEnabled = settings.isPushNotificationEnabled
        rememberLastPickedOptionView = settings.rememberLastPickedOptionView
    }
}
