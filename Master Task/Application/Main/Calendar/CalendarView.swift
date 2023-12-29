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
  var settings: SettingsDTO
  @Binding var tasks: [TaskDTO]
  
  var body: some View {
    VStack(spacing: 11) {
      CustomCalendarView(
          selectedCalendarDay: $viewModel.selectedCalendarDate,
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
    CalendarView(viewModel: .constant(TaskListViewModel()), settings: SettingsDTO(object: SettingsObject()), tasks: .constant([TaskDTO(object: TaskObject())]))
      .environmentObject(AppThemeManager())
  }
}
