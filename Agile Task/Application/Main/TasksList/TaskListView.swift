//
//  TasksView.swift
//  Agile Task
//
//  Created by Artur Korol on 08.08.2023.
//

import SwiftUI
import MasterAppsUI
import StoreKit

struct TaskListView: View {
  
  // MARK: - Properties
  
  @EnvironmentObject var notificationManager: LocalNotificationManager
  @EnvironmentObject var purchaseManager: PurchaseManager
  @EnvironmentObject var themeManager: ThemeManager
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.scenePhase) var scenePhase
  @StateObject var viewModel: TaskListViewModel
  @EnvironmentObject var appState: AppState
  @Environment(\.requestReview) var requestReview
  
  @FocusState private var isFocused: Bool
  @FocusState private var isAddTaskFocused: Bool
  
  @Binding var path: [TaskListNavigationView]
  
  // MARK: - Body
  
  var body: some View {
    NavigationStack(path: $path) {
      VStack(spacing: Constants.shared.viewSectionSpacing) {
        navigationBar()
        dateBarView()
        
        VStack(spacing: 5) {
          if viewModel.taskSortingOption == .month {
            CustomCalendarView(
              selectedCalendarDay: $viewModel.selectedCalendarDate,
              isShowingCalendarPicker: $viewModel.isShowingCalendar,
              currentMonthDatesColor: themeManager.theme.sectionTextColor(colorScheme),
              backgroundColor: themeManager.theme.sectionColor(colorScheme),
              items: viewModel.calendarTasks,
              calendar: Constants.shared.calendar
            )
          }
          taskList()
            .overlay(alignment: .top) {
              HStack {
                TipView(title: "tip_double_tab", arrowEdge: .top)
                TipView(title: "tip_swipe_left", arrowEdge: .top)
              }
            }
          
          Spacer()
        }
      }
      .navigationDestination(for: TaskListNavigationView.self) { views in
        switch views {
        case .createTask:
          NewTaskView(viewModel: NewTaskViewModel(appState: appState), taskList: viewModel.filteredTasks)
        case .completedTasks:
          CompletedTaskView(viewModel: viewModel)
        case .sorting:
          SortingView(viewModel: SortingViewModel(appState: appState))
        case .newCheckBox:
          EmptyView()
        case .subscription:
          SubscriptionView()
        }
      }
      .onAppear {
        viewModel.localNotificationManager = notificationManager
        viewModel.onAppear()
        
        if UserDefaults.standard.integer(forKey: "CompletedTask") >= 20 {
          requestReview()
          UserDefaults.standard.setValue(0, forKey: "CompletedTask")
        }
      }
      .task {
        try? await notificationManager.requestAuthorization()
        guard viewModel.settings.dailyReminderOption == .custom else {
          notificationManager.deleteNotification(with: Constants.shared.dailyNotificationID)
          return
        }
        await notificationManager.addDailyNotification(
          for: viewModel.settings.reminderTime,
          format: viewModel.settings.timeFormat,
          period: viewModel.settings.reminderTimePeriod, 
          tasks: viewModel.appState.projectRepository!.getSelectedProject().tasks
        )
      }
      .modifier(TabViewChildModifier())
      .onChange(of: scenePhase) { newValue in
        if newValue == .active {
          viewModel.onAppear()
          viewModel.groupedTasksBySelectedOption(viewModel.taskSortingOption)
        }
        
        isAddTaskFocused = false
        viewModel.isShowingAddTask = false
      }
      .onDisappear {
        isAddTaskFocused = false
        viewModel.isShowingAddTask = false
      }
      .overlay(alignment: .bottomTrailing) {
          plusButton()
      }
      .overlay(alignment: .bottomTrailing) {
            TipView(title: "tip_quick_add", arrowEdge: .trailing)
            .padding(.bottom, 25)
    }
      .overlay(alignment: .bottom, content: {
        newTaskView()
      })
      .overlay(alignment: .top, content: {
        if viewModel.isShowingCalendarPicker {
          ZStack(alignment: .top) {
            Color.black
              .opacity(0.2)
              .ignoresSafeArea(.all)
            calendarPicker()
          }
        }
      })
      .onChange(of: viewModel.calendarDate) { _ in
        viewModel.udateCalendarInfo()
      }
      .onChange(of: viewModel.searchText) { newValue in
        viewModel.search(with: newValue)
      }
      .environment(\.locale, Locale(identifier: viewModel.settings.appLanguage.identifier))
    }
  }
}

// MARK: - Private Views

private extension TaskListView {
  
  // MARK: - topbar
  
  func navigationBar() -> some View {
    NavigationBarView(
      leftItem: navigationBarLeftItem(),
      header: CustomSegmentedControl(
        options: TaskDateSorting.allCases,
        selection: $viewModel.taskSortingOption,
        textColor: themeManager.theme.sectionTextColor(colorScheme)
      ),
      rightItem: navigationBarRightItem()
    )
    .overlay(alignment: .trailing, content: {
      TipView(title: "tip_add_new_task", arrowEdge: .trailing)
    })
    .onChange(of: viewModel.taskSortingOption) { _ in
      viewModel.groupedTasksBySelectedOption(viewModel.taskSortingOption)
    }
    .onChange(of: viewModel.currentDate) { _ in
      viewModel.groupedTasksBySelectedOption(viewModel.taskSortingOption)
    }
    .onAppear {
      viewModel.groupedTasksBySelectedOption(viewModel.taskSortingOption)
    }
    .onChange(of: viewModel.selectedCalendarDate) { _ in
      viewModel.groupedTasksBySelectedOption(viewModel.taskSortingOption)
    }
  }
  
  func navigationBarLeftItem() -> some View {
    MagnifyingGlassButton(action: {
      viewModel.isSearchBarHidden.toggle()
      viewModel.searchText.removeAll()
    })
  }
  
  func navigationBarRightItem() -> some View {
    Button {
      guard purchaseManager.canCreateTask(taskCount: viewModel.appState.taskRepository!.getTaskList().count) else {
        path.append(.subscription)
        return
      }
      path.append(.createTask)
    } label: {
      Image(.add)
        .resizable()
        .scaledToFit()
        .frame(size: Constants.shared.imagesSize)
    }
  }
  
  // MARK: - taskList
  
  @ViewBuilder
  func taskList() -> some View {
    List {
      switch viewModel.taskSortingOption {
      case .week:
        ForEach(viewModel.sectionHeaders, id: \.self) { key  in
          Section {
            ForEach(.constant(viewModel.sectionContent(key)), id: \.id) { task in
              TaskRow(viewModel: viewModel, task: task)
                .listRowBackground(
                  RoundedRectangle(cornerRadius: 4)
                    .fill(Color(task.colorName.wrappedValue))
                )
            }
          } header: {
            weekSectionHeader(key: key)
          }
        }
      default:
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
        .foregroundColor(themeManager.theme.textColor(colorScheme))
        .focused($isFocused)
        .onAppear {
          isFocused = true
        }
    } else {
      HStack {
        NavigationLink(value: TaskListNavigationView.sorting) {
          Image(.sorting)
            .resizable()
            .scaledToFit()
            .frame(size: Constants.shared.imagesSize)
        }
        
        Spacer()
        VStack {
          switch viewModel.taskSortingOption {
          case .today:
            timeControl(title: viewModel.currentDate.format(viewModel.dateFormat())) {
              viewModel.minusFromCurrentDate(component: .day)
            } rightButtonAction: {
              viewModel.addToCurrentDate(component: .day)
            }
          case .week:
            timeControl(title: "Week ") {
              if viewModel.isValidWeek() {
                viewModel.minusFromCurrentDate(component: .weekOfYear)
              }
            } rightButtonAction: {
              viewModel.addToCurrentDate(component: .weekOfYear)
            }
          case .month, .all:
            EmptyView()
          }
        }
        .frame(height: 30)
        .onTapGesture {
          viewModel.isShowingCalendarPicker.toggle()
        }
        
        Spacer()
        
        NavigationLink(value: TaskListNavigationView.completedTasks) {
          Image(.completedTasks)
            .resizable()
            .scaledToFit()
            .frame(size: Constants.shared.imagesSize)
        }
      }
      .foregroundColor(.white)
      .padding(.horizontal, 15)
      .frame(maxWidth: .infinity)
      .overlay(alignment: .trailing) {
          TipView(title: "tip_find_completed_task", arrowEdge: .trailing)
      }
      .overlay(alignment: .top) {
        if viewModel.taskSortingOption != .all {
          TipView(title: "tip_advanced_navigation", arrowEdge: .top)
        }
      }
    }
  }
  
  func calendarPicker() -> some View {
    CalendarPickerView(
      selectedCalendarDay: $viewModel.currentDate,
      isShowing: $viewModel.isShowingCalendarPicker,
      currentMonthDatesColor: themeManager.theme.sectionTextColor(colorScheme),
      backgroundColor: themeManager.theme.sectionColor(colorScheme),
      calendar: Constants.shared.calendar,
      availableOptions: viewModel.calendarPickerOptions()
    )
    .padding(.top, 70)
  }
  
  func timeControl(title: String, leftButtonAction: @escaping ()->Void, rightButtonAction: @escaping ()->Void) -> some View {
    HStack {
      Button {
        leftButtonAction()
      } label: {
        Image(.arrowLeft)
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(size: Constants.shared.imagesSize)
      }
      
      HStack {
        Text(LocalizedStringKey(title))
        if viewModel.taskSortingOption == .week {
          Text(viewModel.currentDate.weekString)
        }
      }
      .font(.helveticaRegular(size: 16))
      .frame(width: 110)
      
      Button {
        rightButtonAction()
      } label: {
        Image(.arrowRight)
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(size: Constants.shared.imagesSize)
      }
    }
  }
  
  func weekSectionHeader(key: String) -> some View {
    HStack {
      let title = viewModel.sectionHeader(key).components(separatedBy: " ").first ?? ""
      Spacer()
      if key == Date().fullDayShortDateFormat {
        HStack(spacing: 2) {
          Text("+++")
          Text(LocalizedStringKey(title))
          Text("+++")
        }
      } else {
        HStack(spacing: 2) {
          Text("---")
          Text(LocalizedStringKey(title))
          Text("---")
        }
      }
      Spacer()
    }
    .font(.helveticaRegular(size: 14))
    .foregroundStyle(themeManager.theme.textColor(colorScheme))
  }
  
  @ViewBuilder
  func plusButton() -> some View {
    if viewModel.settings.showPlusButton {
      Button {
        guard purchaseManager.canCreateTask(taskCount: viewModel.appState.taskRepository!.getTaskList().count) else {
          path.append(.subscription)
          return
        }
        
        isAddTaskFocused = true
        viewModel.isShowingAddTask = true
      } label: {
        Image(.quickTask)
      }
      .padding(.trailing, 23)
      .padding(.bottom, 30)
    }
  }
  
  @ViewBuilder
  func newTaskView() -> some View {
    if viewModel.isShowingAddTask {
      VStack(spacing: 0) {
        Button {
          isAddTaskFocused = false
          viewModel.isShowingAddTask = false
        } label: {
          Color.black.opacity(0.1)
            .ignoresSafeArea()
        }
        
        VStack {
          TextFieldWithEnterButton(placeholder: "add a new task", text: $viewModel.quickTaskConfig.title) {
            viewModel.createTask()
            isAddTaskFocused = false
            viewModel.isShowingAddTask = false
          }
          .focused($isAddTaskFocused)
          .padding(.top, 8)
          .tint(themeManager.theme.sectionTextColor(colorScheme))
          .modifier(SectionStyle())
          
          Rectangle()
            .frame(maxWidth: .infinity)
            .frame(height: 1)
            .padding(.horizontal, 10)
          
          HStack(spacing: 6) {
            Image(.calendarIcon)
              .renderingMode(.template)
              .resizable()
              .scaledToFit()
              .frame(width: 12, height: 14)
            Button("Tomorrow") {
              if viewModel.quickTaskConfig.dateOption == .tomorrow {
                viewModel.quickTaskConfig.dateOption = .none
              } else {
                viewModel.quickTaskConfig.dateOption = .tomorrow
              }
            }
            .font(
              viewModel.quickTaskConfig.dateOption == .tomorrow
              ? .helveticaBold(size: 14)
              : .helveticaRegular(size: 15)
            )
            
            Button("Next week") {
              if viewModel.quickTaskConfig.dateOption == .nextWeek {
                viewModel.quickTaskConfig.dateOption = .none
              } else {
                viewModel.quickTaskConfig.dateOption = .nextWeek
              }
            }
            .font(
              viewModel.quickTaskConfig.dateOption == .nextWeek
              ? .helveticaBold(size: 14)
              : .helveticaRegular(size: 15)
            )
            
            Spacer()
            Text("/")
            Spacer()
            
            Image(.reminders)
              .renderingMode(.template)
              .resizable()
              .scaledToFit()
              .frame(width: 12, height: 14)
            Button("In 1 hour") {
              if viewModel.quickTaskConfig.reminder == .inOneHour {
                viewModel.quickTaskConfig.reminder = .none
              } else {
                viewModel.quickTaskConfig.reminder = .inOneHour
              }
            }
            .font(
              viewModel.quickTaskConfig.reminder == .inOneHour
              ? .helveticaBold(size: 14)
              : .helveticaRegular(size: 15)
            )
            
            Button("Tomorrow") {
              if viewModel.quickTaskConfig.reminder == .tomorrow {
                viewModel.quickTaskConfig.reminder = .none
              } else {
                viewModel.quickTaskConfig.reminder = .tomorrow
              }
            }
            .font(
              viewModel.quickTaskConfig.reminder == .tomorrow
              ? .helveticaBold(size: 14)
              : .helveticaRegular(size: 15)
            )
          }
          .foregroundColor(themeManager.theme.sectionTextColor(colorScheme))
          .padding(.horizontal, 10)
        }
        .padding(.bottom, 10)
        .background(themeManager.theme.sectionColor(colorScheme))
      }
    }
  }
}

// MARK: - TaskListView_Previews

struct TaskListView_Previews: PreviewProvider {
  static var previews: some View {
    TaskListView(viewModel: TaskListViewModel(appState: AppState()), path: .constant([TaskListNavigationView.sorting]))
      .environmentObject(LocalNotificationManager())
      .environmentObject(ThemeManager())
  }
}
