//
//  SortingManager.swift
//  Master Task
//
//  Created by Artur Korol on 13.09.2023.
//

import Foundation

struct SortingManager {
    let curentDate = Date()
    func sortedTasks(with tasks: [TaskObject], settings: TaskSettings) -> [TaskObject] {
        Array(Set(tasks))
            .sorted(by: {
                switch settings.taskSorting {
                case .manual:
                    break
                case .creation:
                    return  $0.createdDate > $1.createdDate
                case .schedule:
                    break
                case .nonSchedule:
                    break
                case .modifiedDate:
                    break
                case .reminders:
                    return $0.isReminder
                case .recurring:
                    return $0.isRecurring
                }
                return false
            })
            .filter {
                guard settings.completedTask == .hide else { return true }
                
                return $0.isCompleted == false
            }
            .sorted(by: {
                guard settings.completedTask == .moveToBottom else { return false }
                
                return !$0.isCompleted && $1.isCompleted
            })
    }
    
    func filterTask(taskArray: [TaskObject], date: Date) -> [TaskObject] {
        taskArray
            .lazy
            .filter { ($0.date ?? curentDate).fullDayShortDateFormat == date.fullDayShortDateFormat }
    }
    
    func filterTaskByMonth(taskArray: [TaskObject], date: Date) -> [TaskObject] {
        taskArray
            .lazy
            .filter { ($0.date ?? curentDate).monthAndYearString == date.monthAndYearString }
    }
}
