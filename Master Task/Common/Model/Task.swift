//
//  Task.swift
//  Master Task
//
//  Created by Artur Korol on 09.08.2023.
//

import RealmSwift
import MasterAppsUI

class TaskObject: Object, ObjectKeyIdentifiable, CalendarItem {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var parentId: ObjectId? = nil
    @Persisted var title: String
    @Persisted var date: Date?
    @Persisted var account: String
    @Persisted var recurring: RecurringOptions
    @Persisted var reminder: Reminder
    @Persisted var reminderDate: Date?
    @Persisted var createdDate: Date = Date()
    @Persisted var colorName: String
    @Persisted var isCompleted: Bool = false
    @Persisted var checkBoxList: List<CheckBoxObject>
    
    @Persisted(originProperty: "tasksList") var assignee: LinkingObjects<Account>
    
    convenience init(
        parentId: ObjectId?,
        title: String,
        date: Date?,
        account: String,
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
        self.account = account
        self.recurring = recurring
        self.reminder = reminder
        self.reminderDate = reminderDate
        self.createdDate = createdDate
        self.colorName = colorName
    }
    
    var isReminder: Bool {
        switch reminder {
//        case .typical, .whenStart, .fiveMinBefore, .custom:
        case .custom:
            return true
        case .none:
            return false
        }
    }
    
    var isRecurring: Bool {
        switch recurring {
        case .none:
           return false
        case .daily, .weekly, .monthly, .yearly, .custom:
            return true
        }
    }
}

enum Reminder: String, PersistableEnum, CaseIterable {
    case none = "None"
//    case typical = "Typical (1 hour before)"
//    case dontHave = "Don't have"
//    case whenStart = "When start"
//    case fiveMinBefore = "5 min before"
    case custom = "Custom"
}

extension TaskObject {
    private static var config = Realm.Configuration(schemaVersion: 1)
    private static var realm = try! Realm(configuration: config)
    
    static func findAll() -> Results<TaskObject> {
        realm.objects(self)
    }
    
    static func editTask(_ updatedTask: TaskObject, oldTask: TaskObject) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(updatedTask, update: .all)
            }
        } catch {
            print(error)
        }
    }
    
    static func add(_ task: TaskObject) {
        realm.writeAsync {
            realm.add(task, update: .all)
        }
    }
    
    static func delete(_ task: TaskObject) {
        let actualTask = realm.object(ofType: TaskObject.self, forPrimaryKey: task.id)!
        try! realm.write {
            realm.delete(actualTask)
        }
    }
}

enum RecurringOptions: String, CaseIterable, PersistableEnum {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case custom = "Custom"
}

enum DateType: String, CaseIterable, PersistableEnum {
    case none = "None"
    case set = "Set"
}
