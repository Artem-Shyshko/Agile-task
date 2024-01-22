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
    var localNotificationManager: LocalNotificationManager?
    
    private let taskRepository: TaskRepository = TaskRepositoryImpl()
    private let checkboxRepository: CheckboxRepository = CheckboxRepositoryImpl()
    private let bulletRepository: BulletRepository = BulletRepositoryImpl()
    private var settingsRepository: SettingsRepository = SettingsRepositoryImpl()
    private var projectRepository: ProjectRepository = ProjectRepositoryImpl()
    private lazy var pastDate = Date()
    
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
        let currentDate = Constants.shared.currentDate
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
    
    func updateTaskCompletion(_ task: inout TaskDTO) {
        task.isCompleted.toggle()
        taskRepository.saveTask(task)
    }
    
    func updateTaskShowingCheckbox(_ task: inout TaskDTO) {
        task.showCheckboxes.toggle()
        taskRepository.saveTask(task)
    }
    
    func updateCheckbox(_ checkbox: CheckboxDTO) {
        var object = checkbox
        object.isCompleted.toggle()
        checkboxRepository.save(object)
    }
    
    func completeCheckbox(_ checkbox: inout CheckboxDTO) {
        checkbox.isCompleted.toggle()
        checkboxRepository.save(checkbox)
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
                return $0.isReminder
            case .recurring:
                return $0.isRecurring
            }
        })
    }
    
    func sortedCompletedTasks(_ tasks: [TaskDTO], settings: SettingsDTO) -> [TaskDTO] {
        let completedTask = tasks.filter { $0.isCompleted }
        let unCompletedTask = tasks.filter { !$0.isCompleted }
        
        switch settings.completedTask {
        case .hide:
            return unCompletedTask
        case .moveToBottom:
            let groupedTasks = unCompletedTask + completedTask
            return groupedTasks
        }
    }
}
