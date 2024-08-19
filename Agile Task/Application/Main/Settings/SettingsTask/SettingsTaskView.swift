//
//  SettingsTaskView.swift
//  Agile Task
//
//  Created by Artur Korol on 16.08.2023.
//

import SwiftUI
import RealmSwift

struct SettingsTaskView: View {
  @StateObject var viewModel: SettingsTaskViewModel
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
          newTaskFeaturesSection()
          dateSection()
          timeSection()
          defaultSortingSection()
          newTasksSection()
          completedTaskSection()
          dailyReminder()
          addPlusButton()
          сompletionСircleView()
          pushNotificationView()
          addInfoTipsButton()
          deleteAllTasksButton()
          versionView()
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
    .alert("Are you sure you want to delete all tasks?", isPresented: $viewModel.isShowingAlert) {
      Button("Cancel", role: .cancel) {}
      
      Button("Delete") {
        viewModel.deleteAllTasks()
      }
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

private extension SettingsTaskView {
  
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
  }
  
  func languageSection() -> some View {
    CustomPickerView(
      title: "Language",
      options: AppLanguage.allCases,
      selection: $viewModel.settings.appLanguage
    )
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
  }
  
  func newTasksSection() -> some View {
    CustomPickerView(
      title: "New tasks",
      options: AddingNewTask.allCases,
      selection: $viewModel.settings.addNewTaskIn
    )
  }
  
  func defaultSortingSection() -> some View {
    CustomPickerView(
      title: "Default screen view",
      options: TaskDateSorting.allCases,
      selection: $viewModel.settings.taskDateSorting
    )
  }
  
  func completedTaskSection() -> some View {
    CustomPickerView(
      title: "Completed tasks",
      options: CompletedTask.allCases,
      selection: $viewModel.settings.completedTask
    )
  }
  
  func newTaskFeaturesSection() -> some View {
    CustomPickerView(
      title: "New task features",
      options: TaskType.allCases,
      selection: $viewModel.settings.newTaskFeature
    )
  }
  
  func dailyReminder() -> some View {
    VStack(alignment: .leading, spacing: Constants.shared.listRowSpacing) {
      CustomPickerView(
        title: "daily_reminder",
        options: DailyReminderOption.allCases,
        selection: $viewModel.settings.dailyReminderOption
      )
      
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
  
  func сompletionСircleView() -> some View {
          Button {
              viewModel.сompletionСircleAction()
          } label: {
              HStack {
                  if viewModel.settings.сompletionСircle {
                      checkMark
                  }
                  
                  Text("settings_сompletion_сircle")
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
  
  func deleteAllTasksButton() -> some View {
    Button {
      viewModel.isShowingAlert = true
    } label: {
      Text("Delete all tasks")
        .frame(maxWidth: .infinity, alignment: .leading)
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
  
  func versionView() -> some View {
    Text("Version \(viewModel.getAppVersion())")
      .hAlign(alignment: .trailing)
      .padding(.vertical)
  }
}

private extension SettingsTaskView {
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
    SettingsTaskView(viewModel: SettingsTaskViewModel(appState: AppState()))
  }
}
