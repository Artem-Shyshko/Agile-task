//
//  TasksViewModel.swift
//  Master Task
//
//  Created by Artur Korol on 08.08.2023.
//

import SwiftUI
import RealmSwift

final class TaskListViewModel: ObservableObject {
    @Published var isSearchBarHidden: Bool = true
    @Published var showAddNewTaskView = false
    @Published var searchText: String = ""
    @Published var currentDate: Date = Date()
    @Published var settings: SettingsDTO
    @Published var selectedCalendarDate = Date()
    @Published var quickTaskConfig = TaskDTO(object: TaskObject())
    
    @Published var loadedTasks: [TaskDTO] = []
    @Published var filteredTasks: [TaskDTO] = []
    
    private let taskRepository: TaskRepository = TaskRepositoryImpl()
    private let checkboxRepository: CheckboxRepository = CheckboxRepositoryImpl()
    private var settingsRepository: SettingsRepository = SettingsRepositoryImpl()
    private var projectRepository: ProjectRepository = ProjectRepositoryImpl()
    private lazy var dateYearAgo: Date = {
        let date = Constants.shared.currentDate
        return Constants.shared.calendar.date(byAdding: .year, value: -1, to: date) ?? date
    }()
    
    init(loadedTasks: [TaskDTO] = []) {
        self.loadedTasks = loadedTasks
        let settings = settingsRepository.get()
        self.settings = settings
        loadTasks()
    }
    
    // MARK: - Methods
    
    func loadTasks() {
        self.loadedTasks = taskRepository.getTaskList()
        self.settings = settingsRepository.get()
//        sortTask()
    }
    
    func createTask() {
        let selectedProject = projectRepository.getSelectedProject()
        quickTaskConfig.project = selectedProject
        taskRepository.saveTask(quickTaskConfig)
        loadTasks()
        quickTaskConfig = TaskDTO(object: TaskObject())
    }
    
    func recurringAndAllTasks() -> [TaskDTO] {
        let recurringTasks = groupedTasks(with: loadedTasks)
        return sortedCompletedTasks(recurringTasks, settings: settings)
    }
    
    func sortedTasks() -> [TaskDTO] {
        return sortedCompletedTasks(loadedTasks, settings: settings)
    }
    
    func moveTask(fromOffsets indices: IndexSet, toOffset newOffset: Int) {
        filteredTasks.move(fromOffsets: indices, toOffset: newOffset)
        
        for (index, var task) in filteredTasks.reversed().enumerated() {
            task.sortingOrder = index
            taskRepository.saveTask(task)
        }
    }
    
    func calendarTaskSorting(taskList: [TaskDTO]) -> [TaskDTO] {
        if selectedCalendarDate.dateComponents([.year, .month]) == currentDate.dateComponents([.year, .month]) {
            return filteredTasks.filter { $0.date?.dateComponents([.year, .month]) == selectedCalendarDate.dateComponents([.year, .month]) }
        }
        
        return []
    }
    
    func search(with query: String) {
        if query.isEmpty {
            filteredTasks = loadedTasks
        } else {
            filteredTasks = loadedTasks.filter { $0.title.contains(query) }
        }
    }
    
    func addToCurrentDate(component: Calendar.Component, value: Int) {
        currentDate = Constants.shared.calendar.date(byAdding: component, value: value, to: currentDate)!
    }
    
    func minusFromCurrentDate(component: Calendar.Component, value: Int) {
        guard currentDate > dateYearAgo else { return }
        currentDate = Constants.shared.calendar.date(byAdding: component, value: -value, to: currentDate)!
    }
    
    func deleteTask(_ task: TaskDTO) {
        let tasksToDelete = taskRepository.getTaskList().filter({ $0.parentId == task.parentId })
        filteredTasks.removeAll(where: { $0.parentId == task.parentId })
        tasksToDelete.forEach { taskRepository.deleteTask(TaskObject($0)) }
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
    
    func calculateDateColor(whit date: Date, themeTextColor: Color, isDate: Bool) -> Color {
        let currentDate = Constants.shared.currentDate
        return date < (isDate ? currentDate.startDay : currentDate) ? .red : themeTextColor
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

// MARK: - Private Methods

extension TaskListViewModel {
    
    func groupedTasks(with tasks: [TaskDTO]) -> [TaskDTO] {
        
        let gropedTasks = Dictionary(grouping: tasks, by: \.parentId)
        
        var tasks: [TaskDTO] = []
        gropedTasks.keys.forEach { id in
            
            guard let group = gropedTasks[id] else { return }
            
            if group.count > 1 {
                if let task = group.first(where: {
                    $0.createdDate.dateComponents([.day, .month, .year]) == Date().dateComponents([.day, .month, .year])
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
        
        return taskArray
            .sorted(by: {
                switch settings.taskSorting {
                case .manual:
                    return $0.sortingOrder > $1.sortingOrder
                case .schedule:
                    if let lhsDueDate = $0.date, let rhsDueDate = $1.date {
                        return lhsDueDate < rhsDueDate
                    } else if $0.date == nil && $1.date != nil {
                        return false
                    } else {
                        return true
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
