//
//  Date+Ext.swift
//  Agile Task
//
//  Created by Artur Korol on 08.08.2023.
//

import Foundation

extension Date {
    func format(_ format: String) -> String {
        Constants.shared.dateFormatter.dateFormat = format
        
        return Constants.shared.dateFormatter.string(from: self)
    }
    
    var startDay: Date {
        let calendar = Constants.shared.calendar
        var components = calendar.dateComponents(in: .autoupdatingCurrent, from: self)
        components.timeZone = .gmt
        components.hour = 0
        components.minute = 0
        components.second = 0
        return calendar.date(from: components)!
    }
    
    var startOfMonth: Date {
        let calendar = Constants.shared.calendar
        let components = calendar.dateComponents([.year, .month], from: self)
        return  calendar.date(from: components)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.hour = -2
        components.second = -1
        return Constants.shared.calendar.date(byAdding: components, to: startOfMonth.startDay)!
    }
    
    /// Return string value of week number.
    ///
    /// - Returns: w format
    var weekString: String {
        self.format("w")
    }
    
    /// Return string with full month format.
    ///
    /// - Returns: MMMM format
    var monthString: String {
        self.format("MMMM")
    }
    
    /// Return string with full month and year format.
    ///
    /// - Returns: MMMM YYYY  format
    var monthAndYearString: String {
        self.format("MMMM yy")
    }
    
    /// Return string with day name day number, month number, year with last two digits.
    ///
    /// - Returns: EE d/M/yy format
    var shortDateFormat: String {
        self.format("EE d/M/yy")
    }
    
    /// Return string with day name day number, month number, year with last two digits.
    ///
    /// - Returns: EE d/M/yy format
    var fullDayShortDateFormat: String {
        self.format("EEEE d/M/yy")
    }
    
    /// Return string with day name.
    ///
    /// - Returns: EEEE  format
    var fullDayNameFormat: String {
        self.format("EEEE")
    }
    
    /// Return full date string.
    ///
    /// - Returns: EE d/M/yy format
    var fullDateFormat: String {
        self.description
    }
    
    func byAdding(component: Calendar.Component, value: Int, wrappingComponents: Bool = false, using calendar: Calendar = Constants.shared.calendar) -> Date? {
        calendar.date(byAdding: component, value: value, to: self, wrappingComponents: wrappingComponents)
    }
    
    func dateComponents(_ components: Set<Calendar.Component>, using calendar: Calendar = Constants.shared.calendar) -> DateComponents {
        calendar.dateComponents(components, from: self)
    }
    
    func startOfWeek(using calendar: Calendar = Constants.shared.calendar) -> Date {
        calendar.date(from: dateComponents([.yearForWeekOfYear, .weekOfYear], using: calendar))!
    }
    
    var noon: Date {
        Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    func daysOfWeek(using calendar: Calendar = Constants.shared.calendar) -> [Date] {
        let startOfWeek = self.startOfWeek(using: calendar).noon
        return (0...6).map { startOfWeek.byAdding(component: .day, value: $0, using: calendar)! }
    }
    
    func isSameDay(with date: Date) -> Bool {
        self.dateComponents([.day, .month, .year]) == date.dateComponents([.day, .month, .year])
    }
    
    func isSameMonth(with date: Date) -> Bool {
        self.dateComponents([.month, .year]) == date.dateComponents([.month, .year])
    }
    
    func isSameWeek(with date: Date) -> Bool {
        self.dateComponents([.year, .weekOfYear]) == date.dateComponents([.year, .weekOfYear])
    }
    
    var isNotPastDay: Bool {
        self > Date().byAdding(component: .day, value: -1)!.startDay
    }
}
