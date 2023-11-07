//
//  NewTaskViewModel.swift
//  Master Task
//
//  Created by Artur Korol on 11.08.2023.
//

import SwiftUI
import RealmSwift

enum RecurringEnds: String, CaseIterable {
    case never = "Never"
    case on = "On"
    case after = "After"
}

class NewTaskViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var newGroupName: String = ""
    @Published var date: Date = Date()
    @Published var selectedDateType: DateType = .none
    @Published var account: String = ""
    @Published var recurringDate: Date = Date()
    @Published var reminder: Reminder = .none
    @Published var selectedRecurringOption: RecurringOptions = .none
    @Published var reminderDate: Date = Date()
    @Published var selectedColor: Color = .sectionColor
    @Published var showColorPanel = false
    
    // MARK: - Recurring view properties
    
    @Published var repeatCount: String = "0"
    @Published var repeatEvery: RepeatRecurring = .weeks
    @Published var recurringEnds: RecurringEnds = .never
    @Published var recurringEndsDate: Date = Date()
    @Published var recurringEndsAfterOccurrences = "2"
    @Published var weekDays = Calendar.current.standaloneWeekdaySymbols
    @Published var selectedRepeatOnDays: [String] = []
    @Published var checkBoxes: [CheckBoxObject] = []
    
    let realm = try! Realm()
    var colors: [Color] = [.sectionColor, .nyanza, .lemonСhiffon, .periwinkle, .teaRose, .jordyBlue, .mauve, .mindaro]
    lazy var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = MasterTaskConstants.shared.local
        
        return calendar
    }()
    
    private let tasksLimit = 20
    
    // MARK: - Methods
    
    func addNotification(with localNotificationManager: LocalNotificationManager, for task: TaskObject) {
        Task {
            await localNotificationManager.addNotification(to: task)
        }
    }
    
    func createTask(in storage: ObservedResults<TaskObject>) -> TaskObject {
        let task = TaskObject(
            parentId: nil,
            title: title,
            date: selectedDateType != .none ? date : nil,
            account: self.account,
            recurring: selectedRecurringOption,
            reminder: reminder,
            reminderDate: reminder == .custom ? reminderDate : date,
            createdDate: Date(),
            colorName: selectedColor.name
        )
        task.checkBoxList.append(objectsIn: checkBoxes)
        
        return task
    }
    
    func updateTask(task: TaskObject) -> TaskObject {
        task.title = title
        task.date = selectedDateType != .none ? date : nil
        task.account = account
        task.recurring = selectedRecurringOption
        task.reminder = reminder
        task.reminderDate = reminder == .custom ? reminderDate : date
        task.colorName = selectedColor.name
        
        return task
    }
    
    func createRecurringTask(
        for account: Account,
        with parent: TaskObject,
        on date: Date
    ) -> TaskObject {
        TaskObject(
            parentId: parent.parentId,
            title: parent.title,
            date: date,
            account: parent.account,
            recurring: parent.recurring,
            reminder: parent.reminder,
            reminderDate: parent.reminderDate,
            createdDate: date,
            colorName: parent.colorName
        )
    }
    
    func addRecurringRepeatingCount() {
        repeatCount = String((Int(repeatCount) ?? 0) + 1)
    }
    
    func minusRecurringRepeatingCount() {
        if (Int(repeatCount) ?? 0) > 0 {
            repeatCount = String((Int(repeatCount) ?? 0) - 1)
        }
    }
    
    func addRecurringEndsAfterOccurrences() {
        recurringEndsAfterOccurrences = String((Int(recurringEndsAfterOccurrences) ?? 0) + 1)
    }
    
    func minusRecurringEndsAfterOccurrences() {
        if (Int(recurringEndsAfterOccurrences) ?? 0) > 0 {
            recurringEndsAfterOccurrences = String((Int(recurringEndsAfterOccurrences) ?? 0) - 1)
        }
    }
    
    func controlSelectedDay(isSelectDay: Bool, dayName: String) {
        if isSelectDay {
            selectedRepeatOnDays.append(dayName)
        } else {
            selectedRepeatOnDays.removeAll(where: {$0 == dayName})
        }
    }
    
    func writeRecurringTaskArray(for task: TaskObject, selectedAccount: Account) {
        do {
            let account = realm.object(ofType: Account.self, forPrimaryKey: selectedAccount.id)!
            let realm = try Realm()
            try realm.write {
                if selectedRecurringOption == .custom {
                    let taskArray = createCustomTaskRecurringArray(for: task, account: selectedAccount)
                    account.tasksList.append(objectsIn: taskArray)
                } else if selectedRecurringOption != .none {
                    let taskArray = createTaskRecurringArray(for: task, account: selectedAccount)
                    account.tasksList.append(objectsIn: taskArray)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func writeEditedTask(_ task: TaskObject) {
        guard var edited = realm.object(ofType: TaskObject.self, forPrimaryKey: task.id) else { return }
        do {
            try realm.write {
                edited = updateTask(task: edited)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func canCreateTask(allTasks: [TaskObject], hasSubscription: Bool) -> Bool {
        guard !hasSubscription else { return  true }
        
        if tasksLimit <= allTasks.count {
            return false
        } else {
            return true
        }
    }
}

// MARK: - Private Methods

private extension NewTaskViewModel {
    func createTaskRecurringArray(
        for task: TaskObject,
        account: Account
    ) -> [TaskObject] {
        let repeatEveryNextAddingValue = 1
        let endsDate: Date = calendar.date(byAdding: .year, value: 1, to: date) ?? date
        var taskDate = task.createdDate
        var createdTaskArray: [TaskObject] = []
        
        while taskDate <= endsDate {
            switch selectedRecurringOption {
            case .daily:
                taskDate = calendar.date(byAdding: .day, value: repeatEveryNextAddingValue, to: taskDate) ?? date
            case .weekly:
                taskDate = calendar.date(byAdding: .weekday, value: repeatEveryNextAddingValue, to: taskDate) ?? date
            case .monthly:
                taskDate = calendar.date(byAdding: .month, value: repeatEveryNextAddingValue, to: taskDate) ?? date
            case .yearly:
                taskDate = calendar.date(byAdding: .year, value: repeatEveryNextAddingValue, to: taskDate) ?? date
            case .none, .custom:
                break
            }
            
            let task = createRecurringTask(for: account, with: task, on: taskDate)
            createdTaskArray.append(task)
        }
        
        return createdTaskArray
    }
    
    func createCustomTaskRecurringArray(
        for task: TaskObject,
        account: Account
    ) -> [TaskObject] {
        let repeatCount = Int(repeatCount) ?? 1
        var endsDate: Date
        var taskDate = task.createdDate
        var recurringEndsAfterOccurrences = Int(recurringEndsAfterOccurrences) ?? 0
        var createdTaskArray: [TaskObject] = []
        
        switch recurringEnds {
        case .on:
            endsDate = recurringEndsDate
        case .after, .never:
            endsDate = calendar.date(byAdding: .year, value: 1, to: date) ?? date
        }
        
        while taskDate <= endsDate {
            if recurringEnds == .after {
                if recurringEndsAfterOccurrences >= 0 {
                    recurringEndsAfterOccurrences -= 1
                } else {
                    break
                }
            }
            
            switch repeatEvery {
            case .days:
                taskDate = calendar.date(byAdding: .day, value: repeatCount, to: taskDate) ?? date
            case .weeks:
                taskDate = calendar.date(byAdding: .weekOfMonth, value: repeatCount, to: taskDate) ?? date
                let weekDays = taskDate.daysOfWeek(using: calendar)
                
                weekDays.forEach { day in
                    let dayName = day.format("EEEE")
                    if selectedRepeatOnDays.contains(dayName) {
                        let task = createRecurringTask(for: account, with: task, on: day)
                        createdTaskArray.append(task)
                    }
                }
            case .month:
                taskDate = calendar.date(byAdding: .month, value: repeatCount, to: taskDate) ?? date
            case .years:
                taskDate = calendar.date(byAdding: .year, value: repeatCount, to: taskDate) ?? date
            }
            
            if repeatEvery != .weeks {
                let task = createRecurringTask(for: account, with: task, on: taskDate)
                createdTaskArray.append(task)
            }
            
            if repeatCount == 0 {
                break
            }
        }
        
        return createdTaskArray
    }
}
