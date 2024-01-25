//
//  TasksViewModel.swift
//  Master Task
//
//  Created by Artur Korol on 08.08.2023.
//

import SwiftUI
import RealmSwift
import MasterAppsUI

final class TaskListViewModel: ObservableObject {
    @Published var isSearchBarHidden: Bool = true
    @Published var showAddNewTaskView = false
    @Published var searchText: String = ""
    @Published var currentDate: Date = Date()
    @Published var settings: SettingsDTO
    @Published var selectedCalendarDate = Date()
    @Published var quickTaskConfig = TaskDTO(object: TaskObject())
    @Published var isShowingAddTask: Bool = false
    @Published var taskSortingOption: TaskDateSorting = .all
    @Published var calendarDate = Date()
    
    @Published var loadedTasks: [TaskDTO] = []
    @Published var filteredTasks: [TaskDTO] = []
    @Published var calendarTasks: [CalendarItem] = []
    @Published var completedTasks: [TaskDTO] = []
    var localNotificationManager: LocalNotificationManager?
    
    let taskRepository: TaskRepository = TaskRepositoryImpl()
    private let checkboxRepository: CheckboxRepository = CheckboxRepositoryImpl()
    private let bulletRepository: BulletRepository = BulletRepositoryImpl()
    private var settingsRepository: SettingsRepository = SettingsRepositoryImpl()
    private var projectRepository: ProjectRepository = ProjectRepositoryImpl()
    private lazy var pastDate = Date()
    
    var taskGropedByDate: [String: [TaskDTO]] {
      Dictionary(grouping: filteredTasks) { ($0.date ?? $0.createdDate).fullDayNameFormat }
    }
    
    var sectionHeaders: [String] {
      switch taskSortingOption {
      case .week :
        return getWeekSymbols()
      default:
          return [""]
      }
    }
    
    func sectionContent(_ key: String) -> [TaskDTO] {
      switch taskSortingOption {
      case .week:
        return (taskGropedByDate[key] ?? [])
          .filter { ($0.date ?? Date()).isSameWeek(with: currentDate) }
      default:
          return []
      }
    }
    
    func sectionHeader(_ key: String) -> String {
      key
    }
    
    init(loadedTasks: [TaskDTO] = []) {
        self.loadedTasks = loadedTasks
        let settings = settingsRepository.get()
        self.settings = settings
        loadTasks()
    }
    
    // MARK: - Methods
    
    func onAppear() {
        let newDate = Date()
        currentDate = newDate
        pastDate = newDate
        selectedCalendarDate = newDate
        loadTasks()
        search(with: "")
    }
    
    func loadTasks() {
        let project = projectRepository.getSelectedProject()
        self.loadedTasks = project.tasks
        self.settings = settingsRepository.get()
    }
    
    func addToCurrentDate(component: Calendar.Component, value: Int) {
        currentDate = Constants.shared.calendar.date(byAdding: component, value: value, to: currentDate)!
    }
    
    func minusFromCurrentDate(component: Calendar.Component, value: Int) {
        guard currentDate > pastDate else { return }
        currentDate = Constants.shared.calendar.date(byAdding: component, value: -value, to: currentDate)!
    }
    
    func handleIncomingURL(_ url: URL) {
        guard url.scheme == "mastertask" else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return
        }
        
        guard let action = components.host, action == "addnewtask" else {
            print("Unknown URL, we can't handle this one!")
            return
        }
        
        showAddNewTaskView = true
    }
    
    func getWeekSymbols() -> [String] {
        let firstWeekday = Constants.shared.calendar.firstWeekday
        let symbols = Constants.shared.calendar.weekdaySymbols
        
        return Array(symbols[firstWeekday-1..<symbols.count]) + symbols[0..<firstWeekday-1]
    }
    
    func deleteAll() {
        let tasksToDelete = completedTasks
        completedTasks.removeAll()
        tasksToDelete.forEach { taskRepository.deleteTask(TaskObject($0)) }
    }
}

// MARK: - Quick Task

extension TaskListViewModel {
    func addNotification() {
        guard let localNotificationManager else { return }
        
        Task {
            await localNotificationManager.addNotification(to: TaskObject(quickTaskConfig))
        }
    }
    
    func createTask() {
        guard !quickTaskConfig.title.isEmpty else { return }
        setupTaskDate(with: quickTaskConfig.dateOption)
        
        if settings.addNewTaskIn == .bottom {
            if let taskWithMinSortingOrder = filteredTasks.min(by: { $0.sortingOrder < $1.sortingOrder }) {
                quickTaskConfig.sortingOrder = taskWithMinSortingOrder.sortingOrder - 1
                loadedTasks.append(quickTaskConfig)
            }
        } else {
            quickTaskConfig.sortingOrder = filteredTasks.count + 1
            loadedTasks.insert(quickTaskConfig, at: 0)
        }
        
        addNotification()
        var selectedProject = projectRepository.getSelectedProject()
        selectedProject.tasks.append(quickTaskConfig)
        projectRepository.saveProject(selectedProject)
        
        if taskSortingOption == .all {
            groupedTasksBySelectedOption(.all)
        }
        
        quickTaskConfig = TaskDTO(object: TaskObject())
    }
    
    func setupTaskDate(with type: DateType) {
        switch type {
        case .none, .custom:
            quickTaskConfig.date = nil
        case .today:
            quickTaskConfig.date = Date()
        case .tomorrow:
            guard let tomorrowDate = Constants.shared.calendar.date(byAdding: .day, value: 1, to: currentDate)
            else { return }
            
            quickTaskConfig.date = tomorrowDate
        case .nextWeek:
            guard let nextWeekDate = Constants.shared.calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)
            else { return }
            
            quickTaskConfig.date = nextWeekDate.startOfWeek(using: Constants.shared.calendar)
        }
    }
}

// MARK: - TaskRow

extension TaskListViewModel {
    
    func calculateDateColor(whit date: Date, themeTextColor: Color, isDate: Bool) -> Color {
        let currentDate = Date()
        return date < (isDate ? currentDate.startDay : currentDate) ? .red : themeTextColor
    }
    
    @MainActor
    func deleteTask(_ task: TaskDTO) {
        guard let localNotificationManager else { return }
        
        let project = projectRepository.getSelectedProject()
        let tasksToDelete = project.tasks.filter({ $0.parentId == task.parentId })
        filteredTasks.removeAll(where: { $0.parentId == task.parentId })
        loadedTasks.removeAll(where: { $0.parentId == task.parentId })
        taskRepository.deleteAll(where: task.parentId)
        tasksToDelete.forEach {
            localNotificationManager.deleteNotification(with: $0.id.stringValue)
        }
    }
    
    func updateTaskCompletion(_ task: TaskDTO) {
        if let index = filteredTasks.firstIndex(where: { $0.id == task.id }) {
            filteredTasks[index].isCompleted.toggle()
            filteredTasks = sortedCompletedTasks(filteredTasks, settings: settings)
        }
        if let index = loadedTasks.firstIndex(where: { $0.id == task.id }) {
            loadedTasks[index].isCompleted.toggle()
            taskRepository.saveTask(loadedTasks[index])
        }
        if let index = completedTasks.firstIndex(where: { $0.id == task.id }) {
            completedTasks[index].isCompleted.toggle()
            taskRepository.saveTask(completedTasks[index])
            completedTasks.remove(at: index)
        }
    }
    
    func updateTaskShowingCheckbox(_ task: TaskDTO) {
        if let index = filteredTasks.firstIndex(where: { $0.id == task.id }) {
            filteredTasks[index].showCheckboxes.toggle()
            filteredTasks = sortedCompletedTasks(filteredTasks, settings: settings)
        }
        if let index = loadedTasks.firstIndex(where: { $0.id == task.id }) {
            loadedTasks[index].showCheckboxes.toggle()
            taskRepository.saveTask(loadedTasks[index])
        }
    }
    
    func updateCheckbox(_ checkbox: CheckboxDTO) {
        var object = checkbox
        object.isCompleted.toggle()
        checkboxRepository.save(object)
    }
    
    func completeCheckbox(_ checkbox: CheckboxDTO, with taskId: String) {
        if let taskIndex = filteredTasks.firstIndex(where: { $0.id.stringValue == taskId }) {
            if let checkboxIndex = filteredTasks[taskIndex].checkBoxArray.firstIndex(where: { $0.id == checkbox.id }) {
                filteredTasks[taskIndex].checkBoxArray[checkboxIndex].isCompleted.toggle()
            }
        }
        if let taskIndex = loadedTasks.firstIndex(where: { $0.id.stringValue == taskId }) {
            if let checkboxIndex = loadedTasks[taskIndex].checkBoxArray.firstIndex(where: { $0.id == checkbox.id }) {
                loadedTasks[taskIndex].checkBoxArray[checkboxIndex].isCompleted.toggle()
                checkboxRepository.save(loadedTasks[taskIndex].checkBoxArray[checkboxIndex])
            }
        }
    }
    
    func dateFormat() -> String {
        let settings = settingsRepository.get()
        
        switch settings.taskDateFormat {
        case .dayMonthYear:
            return "dd/MM/yy"
        case .weekDayDayMonthYear:
            return "EE, dd/MM/yy"
        case .monthDayYear:
            return "MM/dd/yy"
        case .weekDayMonthDayYear:
            return "EE, MM/dd/yy"
        case .weekDayDayNumberShortMoth:
            return "EE, dd MMM"
        case .dayNumberShortMonthFullYear:
            return "dd MMM yyyy"
        case .dayNumberShortMonth:
            return "dd MMM"
        }
    }
}

// MARK: - Grouping and Sorting

extension TaskListViewModel {
    func moveTask(fromOffsets indices: IndexSet, toOffset newOffset: Int) {
        filteredTasks.move(fromOffsets: indices, toOffset: newOffset)
        
        for (index, task) in filteredTasks.reversed().enumerated() {
            var task = task
            task.sortingOrder = index
            taskRepository.saveTask(task)
        }
        
        if settings.taskSorting != .manual {
            settings.taskSorting = .manual
            settingsRepository.save(settings)
        }
    }
    
    func groupedTasksBySelectedOption(_ option: TaskDateSorting) {
        switch option {
        case .all:
            let gropedRecurringTasks = groupedTasks(with: loadedTasks)
            let sortedCompletedTasks = sortedCompletedTasks(gropedRecurringTasks, settings: settings)
            filteredTasks = sortedCompletedTasks
        case .today:
            let sortedCompletedTasks = sortedCompletedTasks(loadedTasks, settings: settings)
            
            filteredTasks = sortedCompletedTasks
                .lazy
                .filter {
                    if let taskDate = $0.date {
                        return taskDate.isSameDay(with: currentDate)
                    } else if $0.isRecurring {
                        return $0.createdDate.isSameDay(with: currentDate)
                    }
                    
                    return false
                }
        case .week:
            let sortedCompletedTasks = sortedCompletedTasks(loadedTasks, settings: settings)
            
            filteredTasks = sortedCompletedTasks
                .lazy
                .filter {
                    if let taskDate = $0.date {
                        return taskDate.isSameWeek(with: currentDate)
                    } else if $0.isRecurring {
                        return $0.createdDate.isSameWeek(with: currentDate)
                    }
                    
                    return false
                }
        case .month:
            let sortedCompletedTasks = sortedCompletedTasks(loadedTasks, settings: settings)
            
            udateCalendarInfo()
            
            filteredTasks = sortedCompletedTasks
                .lazy
                .filter {
                    if let taskDate = $0.date {
                        return taskDate.isSameDay(with: selectedCalendarDate)
                    } else if $0.isRecurring {
                        return $0.createdDate.isSameDay(with: selectedCalendarDate)
                    }
                    
                    return false
                }
        }
    }
    
    func udateCalendarInfo() {
        calendarTasks = loadedTasks
            .lazy
            .filter({
                if let taskDate = $0.date {
                    return taskDate.isSameMonth(with: calendarDate)
                } else if $0.isRecurring {
                    return $0.createdDate.isSameMonth(with: calendarDate)
                }
                
                return false
            })
    }
    
    func search(with query: String) {
        if query.isEmpty {
            groupedTasksBySelectedOption(taskSortingOption)
        } else {
            filteredTasks = filteredTasks.filter { $0.title.contains(query) }
        }
    }
    
    func groupedTasks(with tasks: [TaskDTO]) -> [TaskDTO] {
        let gropedTasks = Dictionary(grouping: tasks, by: \.parentId)
        
        var tasks: [TaskDTO] = []
        gropedTasks.keys.forEach { id in
            
            guard let group = gropedTasks[id] else { return }
            
            if group.count > 1 {
                if let task = group.first(where: {
                    $0.createdDate.isSameDay(with: Date())
                }) {
                    tasks.append(task)
                }
            } else if group.count == 1 {
                if let task = group.first {
                    tasks.append(task)
                }
            }
        }
        
        return sortedTasks(in: tasks)
    }
    
    func sortedTasks(in taskArray: [TaskDTO]) -> [TaskDTO] {
        return taskArray.sorted(by: {
            switch settings.taskSorting {
            case .manual:
                return $0.sortingOrder > $1.sortingOrder
            case .schedule:
                if let lhsDueDate = $0.date, let rhsDueDate = $1.date {
                    return lhsDueDate < rhsDueDate
                } else if $0.date == nil && $1.date != nil {
                    return false
                } else if $0.date != nil && $1.date == nil {
                    return true
                } else {
                    // Secondary sorting for tasks without dates
                    return $0.createdDate < $1.createdDate
                }
            case .reminders:
                if $0.isReminder, $1.isReminder {
                    return $0.createdDate > $1.createdDate
                } else if $0.isReminder && !$1.isReminder {
                    return true
                } else if !$0.isReminder && $1.isReminder {
                    return false
                } else {
                    return $0.createdDate < $1.createdDate
                }
            case .recurring:
                if $0.isRecurring, $1.isRecurring {
                    return $0.createdDate > $1.createdDate
                } else if $0.isRecurring && !$1.isRecurring {
                    return true
                } else if !$0.isRecurring && $1.isRecurring {
                    return false
                } else {
                    return $0.createdDate < $1.createdDate
                }
            }
        })
    }
    
    func sortedCompletedTasks(_ tasks: [TaskDTO], settings: SettingsDTO) -> [TaskDTO] {
        let completedTask = tasks.filter { $0.isCompleted }
        let unCompletedTask = tasks.filter { !$0.isCompleted }
        
        switch settings.completedTask {
        case .hide:
            return sortedTasks(in: unCompletedTask)
        case .moveToBottom:
            let groupedTasks = sortedTasks(in: unCompletedTask) + completedTask
            return groupedTasks
        }
    }
}
