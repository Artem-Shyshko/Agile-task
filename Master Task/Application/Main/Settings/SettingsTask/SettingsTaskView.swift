//
//  SettingsTaskView.swift
//  Master Task
//
//  Created by Artur Korol on 16.08.2023.
//

import SwiftUI
import RealmSwift

struct SettingsTaskView: View {
  @StateObject var viewModel: SettingsTaskViewModel
  @EnvironmentObject var themeManager: AppThemeManager
  
  @ObservedResults(TaskObject.self) var taskList
  @Environment(\.realm) var realm
  
  var settings: TaskSettings {
    realm.objects(TaskSettings.self).first!
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      weekSection()
      dateSection()
      timeSection()
      defaultSection()
      completedTaskSection()
      defaultReminderSection()
      addPlusButton()
      rememberLastPickedOptionView()
      pushNotificationView()
      versionView()
      Spacer()
    }
    .navigationTitle("Task settings")
    .padding(.top, 25)
    .modifier(TabViewChildModifier())
    .navigationBarBackButtonHidden(false)
    .onAppear {
      viewModel.loadSettings(from: settings)
    }
    .onDisappear(perform: {
      settings.saveSettings {
        settings.startWeekFrom = viewModel.startWeekFrom
        settings.taskDateFormat = viewModel.taskDateFormat
        settings.timeFormat = viewModel.timeFormat
        settings.taskDateSorting = viewModel.taskDateSorting
        settings.addNewTaskIn = viewModel.addNewTaskIn
        settings.completedTask = viewModel.completedTask
        settings.defaultReminder = viewModel.defaultReminder
        settings.showPlusButton = viewModel.showPlusButton
        settings.isPushNotificationEnabled = viewModel.isPushNotificationEnabled
        settings.rememberLastPickedOptionView = viewModel.rememberLastPickedOptionView
      }
    })
  }
}

// MARK: - Private Views

private extension SettingsTaskView {
  func weekSection() -> some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Week starts:")
        Spacer()
        Picker("", selection: $viewModel.startWeekFrom) {
          ForEach(WeekStarts.allCases, id: \.self) {
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
  
  func dateSection() -> some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Date:")
        Spacer()
        Picker("", selection: $viewModel.taskDateFormat) {
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
        Text("Time:")
        Spacer()
        Picker("", selection: $viewModel.timeFormat) {
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
  
  func defaultSection() -> some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Default view:")
        Spacer()
        
        Picker("", selection: $viewModel.taskDateSorting) {
          ForEach(TaskDateSorting.allCases, id: \.self) {
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
        Text("Completed tasks:")
        Spacer()
        Picker("", selection: $viewModel.completedTask) {
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
  
  func defaultReminderSection() -> some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Reminder by default")
        Spacer()
        Picker("", selection: $viewModel.defaultReminder) {
          ForEach(DefaultReminder.allCases, id: \.self) {
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
      settings.saveSettings {
        settings.showPlusButton.toggle()
      }
      viewModel.showPlusButton.toggle()
    } label: {
      HStack {
        checkMark
          .opacity(settings.showPlusButton ? 1 : 0)
        
        Text("Show add button at the bottom right")
      }
    }
    .padding(.vertical, 10)
    .modifier(SectionStyle())
  }
  
  func rememberLastPickedOptionView() -> some View {
    Button {
      settings.saveSettings {
        settings.rememberLastPickedOptionView.toggle()
      }
      viewModel.rememberLastPickedOptionView.toggle()
    } label: {
      HStack {
        checkMark
          .opacity(settings.rememberLastPickedOptionView ? 1 : 0)
        
        Text("Remember last picked options")
      }
    }
    .padding(.vertical, 10)
    .modifier(SectionStyle())
  }
  
  func pushNotificationView() -> some View {
    Button {
      settings.saveSettings {
        settings.isPushNotificationEnabled.toggle()
      }
      viewModel.isPushNotificationEnabled.toggle()
    } label: {
      HStack {
        checkMark
          .opacity(settings.isPushNotificationEnabled ? 1 : 0)
        
        Text("Push notifications")
      }
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
  @Environment(\.colorScheme) var colorScheme
  
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
      if theme.selectedTheme.name == "System" {
        if colorScheme == .dark {
          Color.black
        } else {
          Color.greenGradient
        }
      } else {
        theme.selectedTheme.backgroundColor
        theme.selectedTheme.backgroundGradient
      }
    }
    .ignoresSafeArea()
  }
}
