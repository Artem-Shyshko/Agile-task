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
    @Published var calendar = Calendar.current
    
    let currentYear = Date().dateComponents([.year]).year ?? 0
    let currentYearPlusThen = Calendar.current.date(
        byAdding: .year,
        value: 10,
        to: Date())?.dateComponents([.year]).year ?? 0
    let calendarGridLayout = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var fourteenYersAgo: Int {
        calendar.date(
            byAdding: .year,
            value: -14,
            to: Date()
        )?.dateComponents([.year]).year ?? 0
    }
    
    var sixteenYersInFuture: Int {
        calendar.date(
            byAdding: .year,
            value: 16,
            to: Date()
        )?.dateComponents([.year]).year ?? 0
    }
    
    private lazy var pastDate = Date()
    
    // MARK: - Method
    
    func changeMoth(index: Int, current: inout Date) {
        var dateComponents = calendar.dateComponents([.day, .month, .year], from: current)
        dateComponents.month = index + 1
        current = calendar.date(from: dateComponents)!
    }
    
    func changeYear(_ year: Int, current: inout Date) {
        var dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: current)
        dateComponents.year = year
        current = calendar.date(from: dateComponents)!
    }
    
    func getWeekSymbols() -> [String] {
        let firstWeekday = calendar.firstWeekday
        let symbols = calendar.shortWeekdaySymbols
        
        return Array(symbols[firstWeekday-1..<symbols.count]) + symbols[0..<firstWeekday-1]
    }
    
    func getMonthSymbolFor(_ date: Date) -> String {
        let monthIndex = calendar.component(.month, from: date) - 1
        let monthSymbols = calendar.monthSymbols
        
        return monthSymbols[monthIndex].capitalized
    }
    
    func addToCurrentDate(currentDate: inout Date, component: Calendar.Component, value: Int) {
        currentDate = calendar.date(byAdding: component, value: value, to: currentDate)!
    }
    
    func minusFromCurrentDate(currentDate: inout Date, component: Calendar.Component, value: Int) {
        guard currentDate > pastDate else { return }
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
    
    func numberOfWeeksInYear(_ year: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: 1, day: 1)
        let date = calendar.date(from: dateComponents)!
        if let range = calendar.range(of: .weekOfYear, in: .yearForWeekOfYear, for: date) {
            return range.count
        }
        
        return 1
    }
    
    func changeWeek(_ week: Int, current: inout Date) {
        var dateComponents = calendar.dateComponents([.yearForWeekOfYear], from: current)
        dateComponents.weekOfYear = week
        current = calendar.date(from: dateComponents)!
    }
    
    func canGetPreviousYear(from date: Date) -> Bool {
        let currentYearComponent = Date().dateComponents([.year]).year ?? 2010
        let dateYearComponent = date.dateComponents([.day, .month, .year]).year ?? 2010
        let pastDate = currentYearComponent - 14
        return dateYearComponent > pastDate
    }
}

private extension CalendarViewModel {
    func getDaysFromPrevMonth(currentDate: Date) -> [Date] {
        let startOfMonth = currentDate.startOfMonth.startDay
        let startOfMonthWeekday = calendar.component(.weekday, from: startOfMonth)
        let startWeekDay = startOfMonthWeekday - calendar.firstWeekday
        let trailOfPreviousMonth = startWeekDay > 0 ? startWeekDay : startWeekDay + 7
        
        return Array(1...trailOfPreviousMonth).compactMap {
            calendar.date(byAdding: .day, value: -$0, to: startOfMonth)
        }.reversed()
    }
    
    func getDaysFromNextMonth(currentDate: Date) -> [Date] {
        let endOfMonth = currentDate.endOfMonth.startDay
        let starNextMonth = calendar.date(byAdding: .day, value: 1, to: endOfMonth) ?? endOfMonth
        let endOfMonthWeekday = calendar.component(.weekday, from: starNextMonth)
        var headOfNextMonth = 7 - endOfMonthWeekday
        headOfNextMonth += calendar.firstWeekday == 2 ? 1 : 0
        
        return headOfNextMonth > 0
        ? Array(0...headOfNextMonth).compactMap {
            calendar.date(byAdding: .day, value: $0, to: starNextMonth)
        }
        : []
    }
    
    func getDaysFromCurrentMonth(currentDate: Date) -> [Date] {
        let monthRange = calendar.range(of: .day, in: .month, for: currentDate.startOfMonth)!
        return Array(monthRange).compactMap {
            calendar.date(byAdding: .day, value: $0 - 1, to: currentDate.startOfMonth.startDay)?.startDay
        }
    }
}
