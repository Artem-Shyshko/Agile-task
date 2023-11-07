//
//  TasksViewModel.swift
//  Master Task
//
//  Created by Artur Korol on 08.08.2023.
//

import Foundation
import RealmSwift

final class TaskListViewModel: ObservableObject {
    @Published var isSearchBarHidden: Bool = true
    @Published var searchText: String = ""
    @Published var currentDate: Date = Date()
    @Published var selectedCalendarDate: Date = Date()
    var calendar = Calendar.current
    let sortingManager = SortingManager()
    var allTask = Account.allTasks()
    private lazy var dateYearAgo: Date = {
        let date = MasterTaskConstants.shared.currentDate
        return calendar.date(byAdding: .year, value: -1, to: date) ?? date
    }()
    var settings: TaskSettings {
        let realm = try! Realm()
        return realm.objects(TaskSettings.self).first!
    }
    
    func addToCurrentDate(component: Calendar.Component, value: Int) {
        currentDate = calendar.date(byAdding: component, value: value, to: currentDate)!
    }
    
    func minusFromCurrentDate(component: Calendar.Component, value: Int) {
        guard currentDate > dateYearAgo else { return }
        currentDate = calendar.date(byAdding: component, value: -value, to: currentDate)!
    }
    
    func getAllDates(weekStarts: WeekStarts) -> [Date] {
        
        let prevMonth = getDaysFromPrevMonth(weekStarts: weekStarts)
        let nextMonth = getDaysFromNextMonth(weekStarts: weekStarts)
        let currentMonth = getDaysFromCurrentMonth()
        
        var result: [Date] = []
        
        result.insert(contentsOf: prevMonth, at: 0)
        result.append(contentsOf: currentMonth)
        result.append(contentsOf: nextMonth)
        
        return result
    }
    
    func getWeekSymbols(weekStarts: WeekStarts) -> [String] {
        let firstWeekday = weekStarts == .monday ? 2 : 1
        let symbols = calendar.shortWeekdaySymbols
        
        return Array(symbols[firstWeekday-1..<symbols.count]) + symbols[0..<firstWeekday-1]
    }
    
    func calendarTaskSorting(taskList: [TaskObject]) -> [TaskObject] {
        if selectedCalendarDate.monthAndYearString == currentDate.monthAndYearString {
            return sortingManager.filterTask(
                taskArray: taskList,
                date: selectedCalendarDate
            )
        } else {
            return sortingManager.filterTaskByMonth(
                taskArray: taskList,
                date: currentDate
            )
        }
    }
    func createWeekHeaders(tasks: [TaskObject]) -> [String] {
        calendar.firstWeekday = settings.startWeekFrom == .monday ? 2 : 1
        let sortedDates = Set(tasks
            .filter {
                ($0.date ?? $0.createdDate).dateComponents([.weekOfYear, .year], using: calendar)
                == currentDate.dateComponents([.weekOfYear, .year], using: calendar)
            }
            .map { $0.date ?? $0.createdDate })
            .sorted { (date1, date2) -> Bool in
                return date1 < date2
            }
        
        return sortedDates.map { $0.fullDayShortDateFormat }
    }
}

private extension TaskListViewModel {
    func getDaysFromPrevMonth(weekStarts: WeekStarts) -> [Date] {
        let startOfMonth = currentDate.startOfMonth.startDay
        let startOfMonthWeekday = calendar.component(.weekday, from: startOfMonth)
        
        var trailOfPreviousMonth = startOfMonthWeekday - calendar.firstWeekday
        
        if weekStarts == .monday && startOfMonthWeekday == 1 {
            trailOfPreviousMonth = 7 - startOfMonthWeekday
        }
        
        return trailOfPreviousMonth > 0
        ? Array(1...trailOfPreviousMonth).compactMap {
            calendar.date(byAdding: .day, value: -$0, to: startOfMonth)?.startDay
        }.reversed()
        : []
    }
    
    func getDaysFromNextMonth(weekStarts: WeekStarts) -> [Date] {
        let endOfMonth = currentDate.endOfMonth
        let endOfMonthWeekday = calendar.component(.weekday, from: endOfMonth)
        
        let startOfMonth = currentDate.startOfMonth.startDay
        let startOfMonthWeekday = calendar.component(.weekday, from: startOfMonth)
        
        var headOfNextMonth = 7 - endOfMonthWeekday
        
        if weekStarts == .monday && startOfMonthWeekday == 1 {
            headOfNextMonth = 8 - endOfMonthWeekday
        }
        
        return headOfNextMonth > 0
        ? Array(0...headOfNextMonth).compactMap {
            calendar.date(byAdding: .day, value: $0, to: endOfMonth)
        }
        : []
    }
    
    func getDaysFromCurrentMonth() -> [Date] {
        let monthRange = calendar.range(of: .day, in: .month, for: currentDate.startOfMonth)!
        return Array(monthRange).compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: currentDate.startOfMonth.startDay)?.startDay }
    }
}

extension TaskListViewModel: TaskGroupViewProtocol {
    func completeTask(_ tasks: [TaskObject]) {
        tasks.forEach { task in
            let realm = try! Realm()
            guard let edited = realm.object(ofType: TaskObject.self, forPrimaryKey: task.id) else { return }
            do {
                try realm.write {
                    edited.isCompleted.toggle()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

protocol TaskGroupViewProtocol {
    func completeTask(_ tasks: [TaskObject])
}
