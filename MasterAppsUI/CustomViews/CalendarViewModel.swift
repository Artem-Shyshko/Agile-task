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
}
