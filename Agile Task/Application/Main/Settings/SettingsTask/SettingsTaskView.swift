//
//  SettingsTaskView.swift
//  Agile Task
//
//  Created by Artur Korol on 16.08.2023.
//

import SwiftUI
import RealmSwift
import MasterAppsUI

struct SettingsTaskView: View {
  @StateObject var viewModel: SettingsTaskViewModel
  @Environment(\.dismiss) var dismiss
  @Environment(\.scenePhase) var scenePhase
  
  var body: some View {
    VStack {
      navigationBar()
      VStack(alignment: .leading, spacing: Constants.shared.listRowSpacing) {
        weekStartsOnSection()
        dateSection()
        timeSection()
        defaultSortingSection()
        newTasksSection()
        completedTaskSection()
        addPlusButton()
        pushNotificationView()
        deleteAllTasksButton()
        versionView()
        Spacer()
      }
    }
    .modifier(TabViewChildModifier())
    .onChange(of: viewModel.settings) { _ in
      viewModel.settingsRepository.save(viewModel.settings)
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

// MARK: - SettingsTaskView_Previews

struct SettingsTaskView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsTaskView(viewModel: SettingsTaskViewModel())
  }
}
