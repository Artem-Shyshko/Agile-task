//
//  SettingsTaskView.swift
//  Master Task
//
//  Created by Artur Korol on 16.08.2023.
//

import SwiftUI
import RealmSwift
import MasterAppsUI

struct SettingsTaskView: View {
  @StateObject var viewModel: SettingsTaskViewModel
  @EnvironmentObject var themeManager: AppThemeManager
  @Environment(\.dismiss) var dismiss
  @Environment(\.scenePhase) var scenePhase
  
  var body: some View {
    VStack(alignment: .leading, spacing: Constants.shared.listRowSpacing) {
      dateSection()
      timeSection()
      newTasksSection()
      completedTaskSection()
      addPlusButton()
      pushNotificationView()
      deleteAllTasksButton()
      versionView()
      Spacer()
    }
    .navigationTitle("Settings")
    .padding(.top, 25)
    .modifier(TabViewChildModifier())
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        backButton {
          dismiss.callAsFunction()
        }
      }
    }
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
  func dateSection() -> some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Date")
        Spacer()
        Picker("", selection: $viewModel.settings.taskDateFormat) {
          ForEach(TaskDateFormmat.allCases, id: \.self) {
            Text($0.rawValue)
              .tag($0.rawValue)
          }
        }
        .padding(.vertical, 3)
        .pickerStyle(.menu)
      }
    }
    .modifier(SectionStyle())
  }
  
  func timeSection() -> some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Time")
        Spacer()
        Picker("", selection: $viewModel.settings.timeFormat) {
          ForEach(TimeFormat.allCases, id: \.self) {
            Text($0.rawValue)
              .tag($0.rawValue)
          }
        }
        .pickerStyle(.menu)
      }
    }
    .padding(.vertical, 3)
    .modifier(SectionStyle())
  }
  
  func newTasksSection() -> some View {
    VStack(alignment: .leading) {
      HStack {
        Text("New tasks")
        Spacer()
        Picker("", selection: $viewModel.settings.addNewTaskIn) {
          ForEach(AddingNewTask.allCases, id: \.self) {
            Text($0.rawValue)
              .tag($0.rawValue)
          }
        }
        .pickerStyle(.menu)
      }
    }
    .padding(.vertical, 3)
    .modifier(SectionStyle())
  }
  
  func completedTaskSection() -> some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Completed tasks")
        Spacer()
        Picker("", selection: $viewModel.settings.completedTask) {
          ForEach(CompletedTask.allCases, id: \.self) {
            Text($0.rawValue)
              .tag($0.rawValue)
          }
        }
        .pickerStyle(.menu)
      }
    }
    .padding(.vertical, 3)
    .modifier(SectionStyle())
  }
  
  func addPlusButton() -> some View {
    Button {
      viewModel.addPlusButtonAction()
    } label: {
      HStack {
        if viewModel.settings.showPlusButton {
          checkMark
        }
        
        Text("Additional add button")
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

struct TabViewChildModifier: ViewModifier {
  @EnvironmentObject var theme: AppThemeManager
  
  func body(content: Content) -> some View {
    ZStack {
      background()
      
      content
        .padding(.horizontal, 5)
    }
    .scrollContentBackground(.hidden)
    .navigationBarBackButtonHidden()
    .onAppear {
      UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
  }
  
  func background() -> some View {
    ZStack {
      theme.selectedTheme.backgroundColor
      theme.selectedTheme.backgroundGradient
    }
    .ignoresSafeArea()
  }
}
