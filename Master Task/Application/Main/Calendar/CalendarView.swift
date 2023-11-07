//
//  CalendarView.swift
//  Master Task
//
//  Created by Artur Korol on 25.08.2023.
//

import SwiftUI
import RealmSwift
import MasterAppsUI

struct CalendarView: View {
  @EnvironmentObject var theme: AppThemeManager
  @Binding var viewModel: TaskListViewModel
  var settings: TaskSettings
  @Binding var tasks: [TaskObject]
  
  private let sortingManager = SortingManager()
  
  var body: some View {
    VStack(spacing: 11) {
      CustomCalendarView(
        selectedCalendarDay: $viewModel.selectedCalendarDate,
        calendarDates: .constant(viewModel.getAllDates(weekStarts: settings.startWeekFrom)),
        weekDayTitles: viewModel.getWeekSymbols(weekStarts: settings.startWeekFrom),
        currentDate: $viewModel.currentDate,
        item: tasks,
        currentMonthDatesColor: theme.selectedTheme.sectionTextColor,
        backgroundColor: theme.selectedTheme.sectionColor
      )
    }
    .foregroundColor(.textColor)
    .scrollContentBackground(.hidden)
  }
}

// MARK: - CalendarView_Previews

struct CalendarView_Previews: PreviewProvider {
  static var previews: some View {
    CalendarView(viewModel: .constant(TaskListViewModel()), settings: TaskSettings(), tasks: .constant([MasterTaskConstants.mockTask]))
      .environmentObject(AppThemeManager())
  }
}
