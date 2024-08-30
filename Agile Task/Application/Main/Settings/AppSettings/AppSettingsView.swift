//
//  SettingsTaskView.swift
//  Agile Task
//
//  Created by Artur Korol on 16.08.2023.
//

import SwiftUI
import RealmSwift

struct AppSettingsView: View {
  @StateObject var viewModel: AppSettingsViewModel
  @EnvironmentObject var lnManager: LocalNotificationManager
  @EnvironmentObject var appState: AppState
  @Environment(\.dismiss) var dismiss
  @Environment(\.scenePhase) var scenePhase
  
  var body: some View {
    VStack(spacing: Constants.shared.viewSectionSpacing) {
      navigationBar()
      ScrollView {
        VStack(alignment: .leading, spacing: Constants.shared.listRowSpacing) {
          languageSection()
          weekStartsOnSection()
          dateSection()
          timeSection()
          dailyReminder()
          addPlusButton()
          pushNotificationView()
          addInfoTipsButton()
          Spacer()
        }
      }
      .padding(.bottom, 5)
    }
    .modifier(TabViewChildModifier())
    .onChange(of: viewModel.settings) { _ in
      viewModel.appState.settingsRepository!.save(viewModel.settings)
      appState.settings = viewModel.settings
    }
    .onAppear(perform: {
      Task {
        try? await viewModel.getPermissionState()
      }
    })
    .onChange(of: scenePhase) { newValue in
      if newValue == .active {
        Task {
          try? await viewModel.getPermissionState()
        }
      }
    }
    .onChange(of: viewModel.settings.dailyReminderOption) { newValue in
      setupReminder(with: newValue)
    }
    .onChange(of: viewModel.isTypedTime) { _ in
      setupReminder(with: viewModel.settings.dailyReminderOption)
    }
  }
}

// MARK: - Private Views

private extension AppSettingsView {
  
  func navigationBar() -> some View {
    NavigationBarView(
      leftItem: backButton(),
      header: NavigationTitle("Settings"),
      rightItem: EmptyView()
    )
  }
  
  func backButton() -> some View {
    backButton {
      dismiss.callAsFunction()
    }
  }
  
  func dateSection() -> some View {
    CustomPickerView(
      title: "Date",
      options: TaskDateFormmat.allCases,
      selection: $viewModel.settings.taskDateFormat
    )
    .modifier(SectionStyle())
  }
  
  func languageSection() -> some View {
    CustomPickerView(
      title: "Language",
      options: AppLanguage.allCases,
      selection: $viewModel.settings.appLanguage
    )
    .modifier(SectionStyle())
    .onChange(of: viewModel.settings.appLanguage) { newValue in
      UserDefaults.standard.set(newValue.identifier, forKey: Constants.shared.appLanguage)
    }
  }
  
  func timeSection() -> some View {
    CustomPickerView(
      title: "Time",
      options: TimeFormat.allCases,
      selection: $viewModel.settings.timeFormat
    )
    .modifier(SectionStyle())
  }
  
  func dailyReminder() -> some View {
    VStack(alignment: .leading, spacing: Constants.shared.listRowSpacing) {
      CustomPickerView(
        title: "daily_reminder",
        options: DailyReminderOption.allCases,
        selection: $viewModel.settings.dailyReminderOption
      )
      .modifier(SectionStyle())
      
      if viewModel.settings.dailyReminderOption == .custom {
        RecurringTimeView(
          reminderTime: $viewModel.settings.reminderTime,
          timePeriod: $viewModel.settings.reminderTimePeriod,
          isTypedTime: $viewModel.isTypedTime,
          timeFormat: viewModel.settings.timeFormat,
          isFocus: false
        )
      }
    }
  }
  
  func weekStartsOnSection() -> some View {
    CustomPickerView(
      title: "Week starts on",
      options: WeekStarts.allCases,
      selection: $viewModel.settings.startWeekFrom
    )
    .modifier(SectionStyle())
    .onChange(of: viewModel.settings.startWeekFrom) { newValue in
      UserDefaults.standard.set(newValue.value, forKey: "WeekStart")
    }
  }
  
  func addPlusButton() -> some View {
    Button {
      viewModel.addPlusButtonAction()
    } label: {
      HStack {
        if viewModel.settings.showPlusButton {
          checkMark
        }
        
        Text("Quick input button")
      }
    }
    .padding(.vertical, 10)
    .modifier(SectionStyle())
  }
  
  func addInfoTipsButton() -> some View {
    Button {
      viewModel.turnOnTips()
    } label: {
      HStack {
        if viewModel.settings.isShowingInfoTips {
          checkMark
        }
        
        Text("settings_info_tips")
      }
    }
    .padding(.vertical, 10)
    .modifier(SectionStyle())
  }
  
  func pushNotificationView() -> some View {
    Button {
      viewModel.requestNotificationPermission()
    } label: {
      HStack {
        if viewModel.isNotificationAccess {
          checkMark
        }
        
        Text("Push notifications")
      }
    }
    .padding(.vertical, 10)
    .modifier(SectionStyle())
  }

  var checkMark: some View {
    Image("Check")
      .renderingMode(.template)
      .resizable()
      .scaledToFit()
      .frame(width: 13, height: 13)
  }
}

private extension AppSettingsView {
  func setupReminder(with option: DailyReminderOption) {
    switch option {
    case .custom:
      Task {
        await lnManager.addDailyNotification(
          for: viewModel.settings.reminderTime,
          format: viewModel.settings.timeFormat,
          period: viewModel.settings.reminderTimePeriod, 
          tasks: viewModel.appState.projectRepository!.getSelectedProject().tasks
        )
      }
    case .none:
      lnManager.deleteNotification(with: Constants.shared.dailyNotificationID)
    }
  }
}

// MARK: - SettingsTaskView_Previews

struct SettingsTaskView_Previews: PreviewProvider {
  static var previews: some View {
    AppSettingsView(viewModel: AppSettingsViewModel(appState: AppState()))
  }
}
