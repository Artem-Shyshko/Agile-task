//
//  CalendarViewModel.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 02.11.2023.
//

import SwiftUI

final class CalendarViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var showMonthList = false
    @Published var showYearList = false
    
    let currentYear = Date().dateComponents([.year]).year ?? 0
    let currentYearPlusThen = Calendar.current.date(
        byAdding: .year,
        value: 10,
        to: Date())?.dateComponents([.year]).year ?? 0
    let months = Calendar.current.standaloneMonthSymbols
    let calendarGridLayout = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    lazy var calendar = Calendar.current
    private lazy var dateYearAgo: Date = {
        let date = Date()
        return calendar.date(byAdding: .year, value: -1, to: date) ?? date
    }()
    
    // MARK: - Method
    
    func changeMoth(index: Int, current: inout Date) {
        var dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: current)
        dateComponents.month = index + 1
        current = Calendar.current.date(from: dateComponents)!
    }
    
    func changeYear(_ year: Int, current: inout Date) {
        var dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: current)
        dateComponents.year = year
        current = Calendar.current.date(from: dateComponents)!
    }
    
    func getWeekSymbols() -> [String] {
        let firstWeekday = 1
        let symbols = calendar.shortWeekdaySymbols
        
        return Array(symbols[firstWeekday-1..<symbols.count]) + symbols[0..<firstWeekday-1]
    }
    
    func addToCurrentDate(currentDate: inout Date, component: Calendar.Component, value: Int) {
        currentDate = calendar.date(byAdding: component, value: value, to: currentDate)!
    }
    
    func minusFromCurrentDate(currentDate: inout Date, component: Calendar.Component, value: Int) {
        guard currentDate > dateYearAgo else { return }
        currentDate = calendar.date(byAdding: component, value: -value, to: currentDate)!
    }
    
    func getAllDates(currentDate: Date) -> [Date] {
        
        let prevMonth = getDaysFromPrevMonth(currentDate: currentDate)
        let nextMonth = getDaysFromNextMonth(currentDate: currentDate)
        let currentMonth = getDaysFromCurrentMonth(currentDate: currentDate)
        
        var result: [Date] = []
        
        result.insert(contentsOf: prevMonth, at: 0)
        result.append(contentsOf: currentMonth)
        result.append(contentsOf: nextMonth)
        
        return result
    }
    
    func backToCurrentDateButtonAction(_ date: inout Date) {
        date = Date()
    }
    
    func isDisabledDate(_ date: Date) -> Bool {
        date < Date().byAdding(component: .day, value: -1)!.startDay
    }
}

private extension CalendarViewModel {
    func getDaysFromPrevMonth(currentDate: Date) -> [Date] {
        let startOfMonth = currentDate.startOfMonth.startDay
        let startOfMonthWeekday = calendar.component(.weekday, from: startOfMonth)
        let trailOfPreviousMonth = startOfMonthWeekday - 1
        
        return trailOfPreviousMonth > 0
        ? Array(1...trailOfPreviousMonth).compactMap {
            calendar.date(byAdding: .day, value: -$0, to: startOfMonth)?.startDay
        }.reversed()
        : []
    }
    
    func getDaysFromNextMonth(currentDate: Date) -> [Date] {
        let endOfMonth = currentDate.endOfMonth.startDay
        let starNextMonth = calendar.date(byAdding: .day, value: 1, to: endOfMonth) ?? endOfMonth
        let endOfMonthWeekday = calendar.component(.weekday, from: starNextMonth)
        let headOfNextMonth = 7 - endOfMonthWeekday
        
        return headOfNextMonth > 0
        ? Array(0...headOfNextMonth).compactMap {
            calendar.date(byAdding: .day, value: $0, to: starNextMonth)
        }
        : []
    }
    
    func getDaysFromCurrentMonth(currentDate: Date) -> [Date] {
        let monthRange = calendar.range(of: .day, in: .month, for: currentDate.startOfMonth)!
        return Array(monthRange).compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: currentDate.startOfMonth.startDay)?.startDay }
    }
}
