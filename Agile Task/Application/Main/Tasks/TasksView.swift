//
//  TasksView.swift
//  Agile Task
//
//  Created by Artur Korol on 08.08.2023.
//

import SwiftUI
import StoreKit

struct TasksView: View {
  
  // MARK: - Properties
  
  @EnvironmentObject var notificationManager: LocalNotificationManager
  @EnvironmentObject var purchaseManager: PurchaseManager
  @EnvironmentObject var themeManager: ThemeManager
  @EnvironmentObject var appState: AppState
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.scenePhase) var scenePhase
  @StateObject var viewModel: TasksViewModel
  @Environment(\.requestReview) var requestReview
  
  @FocusState private var isFocused: Bool
  @FocusState private var isAddTaskFocused: Bool
  @State var isShowingAddTaskCalendar = false
  
  @Binding var path: [TasksNavigation]
  
  // MARK: - Body
  
  var body: some View {
    NavigationStack(path: $path) {
      VStack(spacing: Constants.shared.viewSectionSpacing) {
        navigationBar()
        Group {
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
                HStack(alignment: .top) {
                  TipView(title: "tip_double_tab", arrowEdge: .top)
                  TipView(title: "tip_swipe_left", arrowEdge: .top)
                }
                .padding(.top, 15)
              }
          }
          .padding(.bottom, 10)
        }
      }
      .navigationDestination(for: TasksNavigation.self) { views in
        switch views {
        case .createTask(let editedTask):
          NewTaskView(viewModel: NewTaskViewModel(appState: appState, taskList: viewModel.filteredTasks), editTask: editedTask)
        case .completedTasks:
          CompletedTaskView(viewModel: viewModel, path: $path)
        case .sorting:
          SortingView(viewModel: SortingViewModel(appState: appState, sortingState: .tasks))
        case .newCheckBox:
          EmptyView()
        case .subscription:
          SubscriptionView()
        case .settings:
          SettingsView(viewModel: SettingsViewModel(settingType: .tasksList))
        case .appSettings:
          AppSettingsView(viewModel: AppSettingsViewModel(appState: appState))
        case .security:
          SecurityView(viewModel: SecurityViewModel(appState: appState))
        case .more:
          MoreOurAppsView()
        case .contactUs:
          Text("Contact Us")
        case .backup:
          BackupView(viewModel: BackupViewModel(appState: appState))
        case .backupDetail(storage: let storage):
          BackupDetailView(viewModel: BackupViewModel(appState: appState), backupStorage: storage)
        case .backupList(storage: let storage):
          BackupListView(viewModel: BackupViewModel(appState: appState), backupStorage: storage)
        case .setPassword:
          SetPasswordView(viewModel: SetPasswordViewModel(appState: appState,
                                                          isFirstSetup: false,
                                                          setPasswordGoal: .tasks))
        case .taskSettings:
          TasksSettingsView(viewModel: TasksSettingsViewModel(appState: appState))
        }
      }
      .onAppear {
        viewModel.localNotificationManager = notificationManager
        viewModel.onAppear()
        checkDataForReview()
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
      .overlay(alignment: .top) {
        if viewModel.taskSortingOption != .all, viewModel.taskSortingOption != .month {
          TipView(title: "tip_advanced_navigation", arrowEdge: .top)
            .offset(y: 50)
        }
      }
      .overlay(alignment: .bottom) {
        if viewModel.taskSortingOption == .all {
          TipView(title: "tip_group_tasks", arrowEdge: .bottom)
            .offset(y:50)
        }
      }
      .toolbar(isShowingAddTaskCalendar ? .hidden : .visible, for: .tabBar)
    }
  }
}

// MARK: - Private Views

private extension TasksView {
  
  // MARK: - topbar
  
  func navigationBar() -> some View {
    NavigationBarView(
      leftItem: navigationBarLeftItem(),
      header: CustomSegmentedControl(
        options: TaskDateSorting.allCases,
        selection: $viewModel.taskSortingOption
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
    Menu {
      Button("button_search") {
        viewModel.isSearchBarHidden.toggle()
        viewModel.searchText.removeAll()
      }
      .foregroundColor(.white)
      
      NavigationLink(value: TasksNavigation.sorting) {
        Text("tasks_view_sorting")
      }
      
      NavigationLink(value: TasksNavigation.completedTasks) {
        Text("tasks_view_completed_tasks")
      }
      
      NavigationLink(value: TasksNavigation.settings) {
        Text("SettingsTab")
      }
    } label: {
      Image("Menu")
        .resizable()
        .scaledToFit()
        .frame(size: Constants.shared.imagesSize)
    }
  }
  
  func navigationBarRightItem() -> some View {
    Button {
      path.append(.createTask())
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
    switch viewModel.taskSortingOption {
    case .week:
      List {
        ForEach(viewModel.sectionHeaders, id: \.self) { key  in
          Section {
            ForEach(.constant(viewModel.sectionContent(key)), id: \.id) { task in
              TaskRow(viewModel: viewModel, task: task, path: $path)
            }
          } header: {
            weekSectionHeader(key: key)
              .padding(.horizontal, -40)
              .offset(y: -10)
          }
        }
        .listRowSeparator(.hidden)
      }
      .listRowSpacing(Constants.shared.listRowSpacing)
      .scrollContentBackground(.hidden)
      .listStyle(.grouped)
    default:
      List {
        ForEach($viewModel.filteredTasks, id: \.id) { task in
          TaskRow(viewModel: viewModel, task: task, path: $path)
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
    }
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
        Button {
          viewModel.showOrHideItems()
        } label: {
          Image(.expande)
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
        
        ShareLink(item: viewModel.sharedContent()) {
          Image(.share)
            .resizable()
            .scaledToFit()
            .frame(size: Constants.shared.imagesSize)
        }
      }
      .foregroundColor(.white)
      .padding(.horizontal, 15)
      .frame(maxWidth: .infinity)
      .overlay(alignment: .trailing) {
        if viewModel.taskSortingOption == .all || viewModel.taskSortingOption == .month {
          TipView(title: "tip_find_share_task", arrowEdge: .trailing)
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
      let title = viewModel.sectionHeader(key)
      let today = Date().format(viewModel.dateFormat())
      Spacer()
      if key == today {
        Text(LocalizedStringKey(title))
          .font(.helveticaBold(size: 16))
      } else {
        Text(LocalizedStringKey(title))
          .font(.helveticaRegular(size: 16))
      }
      Spacer()
    }
    .foregroundStyle(themeManager.theme.textColor(colorScheme))
    .overlay {
      if key == Date().format(viewModel.dateFormat()) {
        Color.white.opacity(0.1)
          .frame(height: 40)
          .clipShape(.rect(cornerRadius: 3))
      }
    }
  }
  
  @ViewBuilder
  func plusButton() -> some View {
    if viewModel.settings.showPlusButton {
      Button {
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
          isShowingAddTaskCalendar = false
          appState.isTabBarHidden = false
          isAddTaskFocused = false
          viewModel.isShowingAddTask = false
        } label: {
          Color.black.opacity(0.01)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
          
          addTaskDivider()
          
          HStack(spacing: 6) {
            Image(.calendarIcon)
              .renderingMode(.template)
              .resizable()
              .scaledToFit()
              .frame(width: 17, height: 17)
            
            if viewModel.isQuickTaskDateSelected {
              Button {
                viewModel.quickTaskDateType = .date
                viewModel.isQuickTaskDateSelected = false
                isShowingAddTaskCalendar = false
                appState.isTabBarHidden = false
                isAddTaskFocused = !isShowingAddTaskCalendar
              } label: {
                HStack(spacing: 5) {
                  Text(viewModel.quickTaskDate.format(viewModel.dateFormat()))
                  Image(systemName: "xmark").renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 9, height: 9)
                }
              }
            } else {
              Button {
                viewModel.quickTaskDateType = .date
                viewModel.isQuickTaskDateSelected = true
                isShowingAddTaskCalendar = true
                appState.isTabBarHidden = true
                isAddTaskFocused = !isShowingAddTaskCalendar
              } label: {
                Text("quick_task_set_date")
              }
            }
            
            Image(.reminders)
              .renderingMode(.template)
              .resizable()
              .scaledToFit()
              .frame(width: 17, height: 17)
              .padding(.leading, 5)
            if viewModel.isQuickTaskReminderDateSelected {
              Button {
                viewModel.quickTaskDateType = .reminder
                viewModel.isQuickTaskReminderDateSelected = false
                isShowingAddTaskCalendar = false
                appState.isTabBarHidden = false
                isAddTaskFocused = !isShowingAddTaskCalendar
              } label: {
                HStack(spacing: 5) {
                  Text(viewModel.quickTaskReminderDate.format(viewModel.dateFormat()))
                  Image(systemName: "xmark").renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 9, height: 9)
                }
              }
            } else {
              Button {
                viewModel.quickTaskDateType = .reminder
                viewModel.isQuickTaskReminderDateSelected = true
                isShowingAddTaskCalendar = true
                appState.isTabBarHidden = true
                isAddTaskFocused = !isShowingAddTaskCalendar
              } label: {
                Text("quick_task_set_reminder")
              }
            }
            
            Spacer()
          }
          .font(.helveticaRegular(size: 16))
          .foregroundColor(themeManager.theme.sectionTextColor(colorScheme))
          .padding(.horizontal, 10)
          .padding(.vertical, 7)
          
          if isShowingAddTaskCalendar {
            addTaskDivider()
            
            if viewModel.quickTaskDateType == .reminder {
              RecurringTimeView(
                reminderTime: $viewModel.quickTaskReminderTime,
                timePeriod: $viewModel.quickTaskReminderDatePeriod,
                isTypedTime: $viewModel.isTypedReminderTime,
                timeFormat: viewModel.settings.timeFormat,
                isFocus: false
              )
              
              addTaskDivider()
              
              CustomCalendarView(
                selectedCalendarDay: $viewModel.quickTaskReminderDate,
                isShowingCalendarPicker: $viewModel.isShowingCalendar,
                currentMonthDatesColor: themeManager.theme.sectionTextColor(colorScheme),
                backgroundColor: themeManager.theme.sectionColor(colorScheme),
                calendar: Constants.shared.calendar,
                onDateTap: { isAddTaskFocused = true }
              )
            } else {
              CustomCalendarView(
                selectedCalendarDay: $viewModel.quickTaskDate,
                isShowingCalendarPicker: $viewModel.isShowingCalendar,
                currentMonthDatesColor: themeManager.theme.sectionTextColor(colorScheme),
                backgroundColor: themeManager.theme.sectionColor(colorScheme),
                calendar: Constants.shared.calendar,
                onDateTap: { isAddTaskFocused = true }
              )
            }
          }
        }
        .padding(.bottom, 10)
        .background(themeManager.theme.sectionColor(colorScheme))
      }
      .offset(y: isShowingAddTaskCalendar ? 35 : 0)
      .onChange(of: isAddTaskFocused) { newValue in
        if newValue {
          withAnimation {
            isShowingAddTaskCalendar = false
          }
          appState.isTabBarHidden = false
        }
      }
    }
  }
  
  func addTaskDivider() -> some View {
    Rectangle()
      .frame(maxWidth: .infinity)
      .frame(height: 1)
      .padding(.horizontal, 10)
      .foregroundStyle(.black.opacity(0.5))
  }
  
  func checkDataForReview() {
    let defaults = UserDefaults.standard
    
    if defaults.integer(forKey: Constants.shared.simpleTaskReview) >= 3 {
      requestReview()
      defaults.setValue(0, forKey: Constants.shared.simpleTaskReview)
    }
    
    if defaults.integer(forKey: Constants.shared.advancedTaskReview) >= 3 {
      requestReview()
      defaults.setValue(0, forKey: Constants.shared.advancedTaskReview)
    }
  }
}

// MARK: - TaskListView_Previews

struct TaskListView_Previews: PreviewProvider {
  static var previews: some View {
    TasksView(viewModel: TasksViewModel(appState: AppState()), path: .constant([TasksNavigation.sorting]))
      .environmentObject(LocalNotificationManager())
      .environmentObject(ThemeManager())
      .environmentObject(PurchaseManager())
      .environmentObject(AppState())
  }
}

struct ListSectionSpacingModify: ViewModifier {
  func body(content: Content) -> some View {
    if #available(iOS 17.0, *) {
      content
        .listSectionSpacing(30)
    } else {
      content
    }
  }
}
