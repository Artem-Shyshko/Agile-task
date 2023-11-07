//
//  TasksView.swift
//  Master Task
//
//  Created by Artur Korol on 08.08.2023.
//

import SwiftUI
import RealmSwift
import MasterAppsUI

struct TaskListView: View {
  
  // MARK: - Properties
  
  @ObservedObject private var viewModel = TaskListViewModel()
  @EnvironmentObject var userState: UserState
  @EnvironmentObject var notificationManager: LocalNotificationManager
  @EnvironmentObject var theme: AppThemeManager
  
  @ObservedResults(TaskSettings.self) var savedTaskSettings
  @ObservedResults(Account.self, where: ( { $0.isSelected } )) var selectedSavedAccount
  
  private let sortingManager = SortingManager()
  private var taskSettings: TaskSettings {
    savedTaskSettings.first ?? TaskSettings()
  }
  private var selectedAccount: Account {
    selectedSavedAccount.first!
  }
  
  var selectedCalendarTab = false
  @State var calendarSorting: TaskDateSorting = .month
  @State var taskDateSorting: TaskDateSorting = .today
  @Binding var path: [TaskListNavigationView]
  
  // MARK: - Computed Properties
  
  private var filteredTaskByAccount: [TaskObject] {
    guard let tasksList = selectedSavedAccount.first?.tasksList else {
      return []
    }
    
    let tasks = Array(tasksList)
    if !viewModel.searchText.isEmpty {
      return tasks
        .filter({$0.title.contains(viewModel.searchText)})
    } else {
      return tasks
    }
  }
  
  private var taskGropedByDate: [String: [TaskObject]] {
    Dictionary(grouping: filteredTaskByAccount) { $0.date?.fullDayShortDateFormat ?? $0.createdDate.fullDayShortDateFormat }
  }
  
  var sectionHeaders: [String] {
    switch selectedCalendarTab ? calendarSorting : taskDateSorting {
    case .today:
      return Array(Set(filteredTaskByAccount
        .map { $0.date?.fullDayShortDateFormat ?? Date().fullDayShortDateFormat }
        .filter { $0 == viewModel.currentDate.fullDayShortDateFormat }))
    case .week :
      return Array(Set(viewModel.createWeekHeaders(tasks: filteredTaskByAccount)))
    case .month:
      return Array(Set(viewModel.calendarTaskSorting(taskList: filteredTaskByAccount)
        .map { $0.date?.fullDayShortDateFormat ?? Date().fullDayShortDateFormat }))
    case .all:
      return Array(Set(filteredTaskByAccount
        .map { $0.date?.fullDayShortDateFormat ?? Date().fullDayShortDateFormat }))
    }
  }
  
  func sectionContent(_ key: String) -> [TaskObject] {
    switch selectedCalendarTab ? calendarSorting : taskDateSorting {
    case .today:
      return (taskGropedByDate[key] ?? [])
        .filter { ($0.date ?? Date()).shortDateFormat == viewModel.currentDate.shortDateFormat }
    case .week:
      return (taskGropedByDate[key] ?? [])
        .filter { 
          ($0.date ?? Date()).dateComponents([.weekOfYear, .year], using: viewModel.calendar)
          == viewModel.currentDate.dateComponents([.weekOfYear, .year], using: viewModel.calendar) }
    case .month:
      return (taskGropedByDate[key] ?? [])
        .filter { ($0.date ?? Date()).monthString == viewModel.currentDate.monthString }
    case .all:
      return taskGropedByDate[key] ?? []
    }
  }
  
  func sectionHeader(_ key: String) -> String {
    key
  }
  
  // MARK: - Body
  
  var body: some View {
    NavigationStack(path: $path) {
      VStack(spacing: 20) {
        topBarView()
        dateBarView()
        
        VStack(spacing: 5) {
          if taskDateSorting == .month || selectedCalendarTab, calendarSorting == .month {
            CalendarView(viewModel: .constant(viewModel), settings: taskSettings, tasks: .constant(sortingManager.sortedTasks(with: filteredTaskByAccount, settings: taskSettings)))
          }
          taskList()
          
          Spacer()
        }
      }
      .overlay(alignment: .bottomTrailing) {
        plusButton()
      }
      .navigationDestination(for: TaskListNavigationView.self) { views in
        switch views {
        case .createTask:
          NewItemView(viewModel: NewTaskViewModel())
        case .completedTasks:
          CompletedTaskView(viewModel: CompletedTaskViewModel())
        case .sorting:
          SortingView(viewModel: SortingViewModel())
        case .newCheckBox:
            EmptyView()
        }
      }
      .onAppear {
        if selectedCalendarTab {
          calendarSorting = .month
        }
        
        taskDateSorting = taskSettings.taskDateSorting
      }
      .task {
        try? await notificationManager.requestAuthorization()
      }
      .modifier(TabViewChildModifier())
    }
  }
}

// MARK: - Private Views

private extension TaskListView {
  
  // MARK: - topbar
  
  func topBarView() -> some View {
    HStack(spacing: 15) {
      Button {
        viewModel.isSearchBarHidden.toggle()
        viewModel.searchText.removeAll()
      } label: {
        Image(systemName: "magnifyingglass")
          .resizable()
          .scaledToFit()
          .frame(width: 12, height: 12)
      }
      .foregroundColor(.white)
      
      Picker("", selection: selectedCalendarTab ? $calendarSorting : $taskDateSorting) {
        ForEach(TaskDateSorting.allCases, id: \.self) { interval in
          Text(interval.rawValue)
            .font(.helveticaBold(size: 30))
        }
      }
      .pickerStyle(.segmented)
      
      NavigationLink(value: TaskListNavigationView.createTask) {
        Image(systemName: "plus")
      }
    }
    .padding(.top, 15)
    .padding(.horizontal, 20)
  }
  
  // MARK: - taskList
  
  @ViewBuilder
  func taskList() -> some View {
    List {
      ForEach(sectionHeaders, id: \.self) { key  in
        Section {
              TaskList(
                taskArray: .constant(sortingManager.sortedTasks(
                  with: sectionContent(key),
                  settings: taskSettings
                ))
              )
        } header: {
          if taskDateSorting == .week {
            Text(sectionHeader(key))
          }
        }
      }
    }
    .listRowSpacing(MasterTaskConstants.shared.listRowSpacing)
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
  }
  
  // MARK: - dateBarView
  
  @ViewBuilder
  func dateBarView() -> some View {
    if !viewModel.isSearchBarHidden {
      SearchableView(searchText: $viewModel.searchText, isSearchBarHidden: $viewModel.isSearchBarHidden)
        .foregroundColor(theme.selectedTheme.textColor)
    } else {
      HStack {
        NavigationLink(value: TaskListNavigationView.sorting) {
          Image("Sorting")
            .resizable()
            .scaledToFit()
            .frame(width: 30)
        }
        
        Spacer()
        VStack {
          switch selectedCalendarTab ? calendarSorting : taskDateSorting {
          case .today:
            TimeControlView(
              title: viewModel.currentDate.format(
                taskSettings.taskDateFormat == .dayFirst ? "EE d/M/yy" : "EE M/d/yy"
              )
            ) {
              viewModel.minusFromCurrentDate(component: .day, value: 1)
            } rightButtonAction: {
              viewModel.addToCurrentDate(component: .day, value: 1)
            }
          case .week:
            TimeControlView(title: "Week " + viewModel.currentDate.weekString) {
              viewModel.minusFromCurrentDate(component: .weekOfYear, value: 1)
            } rightButtonAction: {
              viewModel.addToCurrentDate(component: .weekOfYear, value: 1)
            }
          case .month:
            TimeControlView(title: viewModel.currentDate.format("MMMM")) {
              viewModel.minusFromCurrentDate(component: .month, value: 1)
            } rightButtonAction: {
              viewModel.addToCurrentDate(component: .month, value: 1)
            }
          case .all:
            Text("All")
          }
        }
        .onTapGesture {
          viewModel.currentDate = MasterTaskConstants.shared.currentDate
        }
        
        Spacer()
        
        NavigationLink(value: TaskListNavigationView.completedTasks) {
          Image("CompletedTasks")
            .resizable()
            .scaledToFit()
            .frame(width: 30)
        }
      }
      .foregroundColor(.white)
      .padding(.horizontal, 17)
      .frame(maxWidth: .infinity)
    }
  }
  
  @ViewBuilder
  func plusButton() -> some View {
    if taskSettings.showPlusButton {
    NavigationLink(value: TaskListNavigationView.createTask) {
        ZStack {
          Color.black
            .frame(width: 30, height: 30)
            .cornerRadius(5)
          Image(systemName: "plus")
        }
        .padding()
      }
    }
  }
}

// MARK: - TaskListView_Previews

struct TaskListView_Previews: PreviewProvider {
  static var previews: some View {
    TaskListView(path: .constant([TaskListNavigationView.sorting]))
      .environmentObject(UserState())
      .environmentObject(LocalNotificationManager())
      .environmentObject(AppThemeManager())
  }
}
