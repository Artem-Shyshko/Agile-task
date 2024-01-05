//
//  TasksView.swift
//  Master Task
//
//  Created by Artur Korol on 08.08.2023.
//

import SwiftUI
import MasterAppsUI

struct TaskListView: View {
  
  // MARK: - Properties
  
  @StateObject private var viewModel = TaskListViewModel()
  @EnvironmentObject var notificationManager: LocalNotificationManager
  @EnvironmentObject var theme: AppThemeManager
  @FocusState private var isFocused: Bool
  @FocusState private var isAddTaskFocused: Bool
  @State private var isShowingAddTask: Bool = false
  
  
  var selectedCalendarTab = false
  @State var calendarSorting: TaskDateSorting = .month
  @State var taskDateSorting: TaskDateSorting = .today
  @Binding var path: [TaskListNavigationView]
  
  // MARK: - Computed Properties
  
  private var taskGropedByDate: [String: [TaskDTO]] {
    Dictionary(grouping: viewModel.filteredTasks) { $0.date?.fullDayShortDateFormat ?? $0.createdDate.fullDayShortDateFormat }
  }
  
  var sectionHeaders: [String] {
    switch selectedCalendarTab ? calendarSorting : taskDateSorting {
    case .today:
      return Array(Set(viewModel.filteredTasks
        .map { $0.date?.fullDayShortDateFormat ?? Date().fullDayShortDateFormat }
        .filter { $0 == viewModel.currentDate.fullDayShortDateFormat }))
    case .week :
      return Array(Set(viewModel.createWeekHeaders(tasks: viewModel.filteredTasks)))
    case .month:
      return Array(Set(viewModel.calendarTaskSorting(taskList: viewModel.filteredTasks)
        .map { $0.date?.fullDayShortDateFormat ?? Date().fullDayShortDateFormat }))
    case .all:
      return Array(Set(viewModel.filteredTasks
        .map { $0.date?.fullDayShortDateFormat ?? Date().fullDayShortDateFormat }))
    }
  }
  
  func sectionContent(_ key: String) -> [TaskDTO] {
    switch selectedCalendarTab ? calendarSorting : taskDateSorting {
    case .today:
      return (taskGropedByDate[key] ?? [])
        .filter { ($0.date ?? Date()).shortDateFormat == viewModel.currentDate.shortDateFormat }
    case .week:
      return (taskGropedByDate[key] ?? [])
        .filter { 
          ($0.date ?? Date()).dateComponents([.weekOfYear, .year])
          == viewModel.currentDate.dateComponents([.weekOfYear, .year]) }
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
            CalendarView(viewModel: .constant(viewModel), settings: viewModel.settings, tasks: viewModel.filteredTasks)
          }
          taskList()
          
          Spacer()
        }
      }
      .overlay(alignment: .bottomTrailing) {
        plusButton()
      }
      .overlay(alignment: .bottom, content: {
       newTaskView()
          .padding(.horizontal, -10)
      })
      .navigationDestination(for: TaskListNavigationView.self) { views in
        switch views {
        case .createTask:
          NewTaskView(viewModel: NewTaskViewModel(), taskList: viewModel.filteredTasks)
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
        viewModel.loadTasks()
        viewModel.search(with: "")
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
          .frame(width: 18, height: 18)
      }
      .foregroundColor(.white)
      
      DateSegmentedControl(selectedDateSorting: selectedCalendarTab ? $calendarSorting : $taskDateSorting)
      
      Button {
        isAddTaskFocused = true
        isShowingAddTask = true
      } label: {
        Image(systemName: "plus")
          .resizable()
          .scaledToFit()
          .frame(width: 18, height: 18)
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
          List {
            ForEach($viewModel.filteredTasks, id: \.id) { task in
              TaskRow(viewModel: viewModel, task: task)
                .listRowBackground(
                  RoundedRectangle(cornerRadius: 4)
                    .fill(Color(task.colorName.wrappedValue))
                )
                .onChange(of: task.wrappedValue) { _ in
                  viewModel.loadTasks()
                }
            }
            .onMove(perform: { from, to in
              viewModel.moveTask(fromOffsets: from, toOffset: to)
            })
            .listRowSeparator(.hidden)
          }
          .listRowSpacing(Constants.shared.listRowSpacing)
          .scrollContentBackground(.hidden)
          .listStyle(.plain)
        } header: {
          if taskDateSorting == .week {
            Text(sectionHeader(key))
          }
        }
      }
    }
    .listRowSpacing(Constants.shared.listRowSpacing)
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
  }
  
  // MARK: - dateBarView
  
  @ViewBuilder
  func dateBarView() -> some View {
    if !viewModel.isSearchBarHidden {
      SearchableView(searchText: $viewModel.searchText, isSearchBarHidden: $viewModel.isSearchBarHidden)
        .foregroundColor(theme.selectedTheme.textColor)
        .onChange(of: viewModel.searchText) { newValue in
          viewModel.search(with: newValue)
        }
        .focused($isFocused)
        .onAppear {
          isFocused = true
        }
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
              title: viewModel.currentDate.format(viewModel.dateFormat())
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
        .frame(height: 30)
        .onTapGesture {
          viewModel.currentDate = Constants.shared.currentDate
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
    if viewModel.settings.showPlusButton {
      NavigationLink(value: TaskListNavigationView.createTask) {
        ZStack {
          Color.black
            .frame(width: 30, height: 30)
            .cornerRadius(5)
          Image(systemName: "plus")
        }
        .padding()
        .padding(.bottom, 40)
      }
    }
  }
  
  @ViewBuilder
  func newTaskView() -> some View {
    VStack {
    if isShowingAddTask {
        TextFieldWithEnterButton(placeholder: "add a new task", text: $viewModel.quickTaskConfig.title) {
          viewModel.createTask()
          isAddTaskFocused = false
          isShowingAddTask = false
        }
        .focused($isAddTaskFocused)
        .padding(.vertical, 8)
        .tint(theme.selectedTheme.sectionTextColor)
        .modifier(SectionStyle())
      
        Rectangle()
          .frame(maxWidth: .infinity)
          .frame(height: 1)
          .padding(.horizontal, 10)
        
        HStack {
          Button("Tomorrow") {
            viewModel.quickTaskConfig.dateOption = .tomorrow
          }
          
          Button("Next week") {
            viewModel.quickTaskConfig.dateOption = .nextWeek
          }
          Spacer()
          Text("/")
          Spacer()
          Button("In 1 hour") {
            viewModel.quickTaskConfig.reminder = .inOneHour
          }
          Button("Tomorrow") {
            viewModel.quickTaskConfig.reminder = .tomorrow
          }
        }
        .foregroundColor(theme.selectedTheme.sectionTextColor)
        .padding(.horizontal, 10)
      }
    }
    .padding(.bottom, 10)
    .background(theme.selectedTheme.sectionColor)
  }
}

// MARK: - TaskListView_Previews

struct TaskListView_Previews: PreviewProvider {
  static var previews: some View {
    TaskListView(path: .constant([TaskListNavigationView.sorting]))
      .environmentObject(LocalNotificationManager())
      .environmentObject(AppThemeManager())
  }
}
