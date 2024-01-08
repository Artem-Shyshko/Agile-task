//
//  TaskDataModel.swift
//  MasterTaskWidgetExtension
//
//  Created by Artur Korol on 13.12.2023.
//

import Foundation

class TaskDataModel {
    static let shared = TaskDataModel()
    let taskRepo: TaskRepository = TaskRepositoryImpl()
    let settingsRepo: SettingsRepository = SettingsRepositoryImpl()
    var tasks = [TaskDTO]()
    var settings: SettingsDTO
    
    private init() {
        settings = settingsRepo.get()
        getTasks()
    }
    
    func getTasks() {
        let loadedTasks = taskRepo.getTaskList().filter { !$0.isCompleted }
        tasks = groupedTasks(with: loadedTasks, settings: settings)
    }
    
    func groupedTasks(with tasks: [TaskDTO], settings: SettingsDTO) -> [TaskDTO] {
        
        let gropedTasks = Dictionary(grouping: tasks, by: \.parentId)
        
        var tasks: [TaskDTO] = []
        gropedTasks.keys.forEach { id in
            
            guard let group = gropedTasks[id] else { return }
            
            if group.count > 1 {
                if let task = group.first(where: {
                    $0.createdDate.dateComponents([.day, .month, .year]) == Date().dateComponents([.day, .month, .year])
                }) {
                    tasks.append(task)
                }
            } else if group.count == 1 {
                if let task = group.first {
                    tasks.append(task)
                }
            }
        }
        
        return sortedTasks(in: tasks)
    }
    
    func sortedTasks(in taskArray: [TaskDTO]) -> [TaskDTO] {
        
        return taskArray
            .sorted(by: {
                switch settings.taskSorting {
                case .manual:
                    return $0.sortingOrder > $1.sortingOrder
                case .schedule:
                    if let lhsDueDate = $0.date, let rhsDueDate = $1.date {
                        return lhsDueDate < rhsDueDate
                    } else if $0.date == nil && $1.date != nil {
                        return false
                    } else {
                        return true
                    }
                case .reminders:
                    return $0.isReminder
                case .recurring:
                    return $0.isRecurring
                }
            })
    }
    
    func dateFormat() -> String {
        let settings = settingsRepo.get()
        
        switch settings.taskDateFormat {
        case .dayMonthYear:
            return "dd/MM/yy"
        case .weekDayDayMonthYear:
            return "EE, dd/MM/yy"
        case .monthDayYear:
            return "MM/dd/yy"
        case .weekDayMonthDayYear:
            return "EE, MM/dd/yy"
        case .weekDayDayNumberShortMoth:
            return "EE, dd MMM"
        case .dayNumberShortMonthFullYear:
            return "dd MMM yyyy"
        case .dayNumberShortMonth:
            return "dd MMM"
        }
    }
}
