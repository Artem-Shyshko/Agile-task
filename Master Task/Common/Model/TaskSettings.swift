//
//  TaskSettings.swift
//  Master Task
//
//  Created by Artur Korol on 20.09.2023.
//

import Foundation
import RealmSwift

final class TaskSettings: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var startWeekFrom: WeekStarts = .monday
    @Persisted var taskDateFormat: TaskDateFormmat = .dayFirst
    @Persisted var timeFormat: TimeFormat = .twentyFour
    @Persisted var taskDateSorting: TaskDateSorting = .today
    @Persisted var addNewTaskIn: AddingNewTask = .top
    @Persisted var completedTask: CompletedTask = .hide
    @Persisted var defaultReminder: DefaultReminder = .oneHourBefore
    @Persisted var showPlusButton: Bool = true
    @Persisted var isPushNotificationEnabled: Bool = true
    @Persisted var rememberLastPickedOptionView: Bool = true
    @Persisted var taskSorting: TaskSorting = .schedule
    @Persisted var securityOption: SecurityOption = .none
}

extension TaskSettings {
    private static var config = Realm.Configuration(schemaVersion: 1)
    private static var realm = try! Realm(configuration: config)
    
    func saveSettings(completion: @escaping (() -> Void)) {
        guard let settings = TaskSettings.realm.object(ofType: TaskSettings.self, forPrimaryKey: self.id) else { return }
        let realm = settings.thaw()!.realm!
        
        do {
            try realm.write {
                completion()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

enum TaskSorting: String, PersistableEnum, CaseIterable {
    case manual = "Manual"
    case creation = "By creation date on the top"
    case schedule = "By schedule on the top"
    case nonSchedule = "Non-scheduled on the top"
    case modifiedDate = "By modified date on the top"
    case reminders = "By reminders on the top"
    case recurring = "By recurring on the top"
}

enum WeekStarts: String, PersistableEnum, CaseIterable {
    case sunday = "Sunday"
    case monday = "Monday"
}

enum TaskDateFormmat: String, PersistableEnum, CaseIterable {
    case dayFirst = "dd/mm/yy"
    case monthFirst = "mm/dd/yy"
}

enum TaskDateSorting: String, PersistableEnum, CaseIterable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
    case all = "All"
}

enum AddingNewTask: String, PersistableEnum, CaseIterable {
    case bottom = "At the bottom of the list"
    case top = "At the top of the list"
}

enum CompletedTask: String, PersistableEnum, CaseIterable {
    case leave = "Leave in the list"
    case hide = "Hide from the list"
    case moveToBottom = "Move to the button of the list"
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

enum TimeFormat: String, PersistableEnum, CaseIterable {
    case twentyFour = "24h"
    case twelve = "12h"
}
