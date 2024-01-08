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
  @Environment(\.scenePhase) var scenePhase
  
  var selectedCalendarTab = false
  @State var calendarSorting: TaskDateSorting = .month
  @State var taskDateSorting: TaskDateSorting = .today
  @Binding var path: [TaskListNavigationView]
  
  // MARK: - Body
  
  var body: some View {
    NavigationStack(path: $path) {
      VStack(spacing: 10) {
        VStack(spacing: 20) {
          topBarView()
          dateBarView()
        }
        
        VStack(spacing: 5) {
          if taskDateSorting == .month || selectedCalendarTab, calendarSorting == .month {
            CalendarView(viewModel: .constant(viewModel), settings: viewModel.settings, tasks: viewModel.loadedTasks)
          }
          taskList()
          
          Spacer()
        }
      }
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
      .onChange(of: scenePhase) { newValue in
        if newValue == .active {
          viewModel.loadTasks()
          viewModel.groupedTasksBySelectedOption(selectedCalendarTab ? calendarSorting : taskDateSorting)
        }
      }
      .overlay(alignment: .bottomTrailing) {
        plusButton()
      }
      .overlay(alignment: .bottom, content: {
        newTaskView()
      })
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

      NavigationLink(value: TaskListNavigationView.createTask) {
        Image(systemName: "plus")
          .resizable()
          .scaledToFit()
          .frame(width: 18, height: 18)
      }
    }
    .padding(.top, 15)
    .padding(.horizontal, 20)
    .onChange(of: selectedCalendarTab ? calendarSorting : taskDateSorting) { _ in
      viewModel.groupedTasksBySelectedOption(selectedCalendarTab ? calendarSorting : taskDateSorting)
    }
    .onChange(of: viewModel.currentDate) { _ in
        viewModel.groupedTasksBySelectedOption(selectedCalendarTab ? calendarSorting : taskDateSorting)
    }
    .onAppear {
      viewModel.groupedTasksBySelectedOption(selectedCalendarTab ? calendarSorting : taskDateSorting)
    }
    .onChange(of: viewModel.selectedCalendarDate) { _ in
        viewModel.groupedTasksBySelectedOption(selectedCalendarTab ? calendarSorting : taskDateSorting)
    }
  }
  
  // MARK: - taskList
  
  @ViewBuilder
  func taskList() -> some View {
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
      Button {
          isAddTaskFocused = true
          isShowingAddTask = true
      } label: {
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
      if isShowingAddTask {
        VStack {
        TextFieldWithEnterButton(placeholder: "add a new task", text: $viewModel.quickTaskConfig.title) {
          viewModel.createTask()
          viewModel.groupedTasksBySelectedOption(selectedCalendarTab ? calendarSorting : taskDateSorting)
          isAddTaskFocused = false
          isShowingAddTask = false
        }
        .focused($isAddTaskFocused)
        .padding(.top, 8)
        .tint(theme.selectedTheme.sectionTextColor)
        .modifier(SectionStyle())
        
        Rectangle()
          .frame(maxWidth: .infinity)
          .frame(height: 1)
          .padding(.horizontal, 10)
        
        HStack {
          Image(.calendarIcon)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 12, height: 14)
          Button("Tomorrow") {
            viewModel.quickTaskConfig.dateOption = .tomorrow
          }
          .font(.helveticaRegular(size: 16))
          
          Button("Next week") {
            viewModel.quickTaskConfig.dateOption = .nextWeek
          }
          .font(.helveticaRegular(size: 16))
          Spacer()
          Text("/")
          Spacer()
          Image(.reminders)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 12, height: 14)
          Button("In 1 hour") {
            viewModel.quickTaskConfig.reminder = .inOneHour
          }
          .font(.helveticaRegular(size: 16))
          Button("Tomorrow") {
            viewModel.quickTaskConfig.reminder = .tomorrow
          }
          .font(.helveticaRegular(size: 16))
        }
        .foregroundColor(theme.selectedTheme.sectionTextColor)
        .padding(.horizontal, 10)
      }
        .padding(.bottom, 10)
        .background(theme.selectedTheme.sectionColor)
    }
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
