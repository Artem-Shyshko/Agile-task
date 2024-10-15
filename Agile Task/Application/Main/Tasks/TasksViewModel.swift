//
//  TasksViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 08.08.2023.
//

import SwiftUI
import RealmSwift

final class TasksViewModel: ObservableObject {
    
    enum QuickTaskDate {
        case reminder, date
    }
    @ObservedObject var watchConnector = WatchConnector()
    
    @Published var isSearchBarHidden: Bool = true
    @Published var showAddNewTaskView = false
    @Published var searchText: String = ""
    @Published var currentDate: Date = Date()
    @Published var settings: SettingsDTO
    @Published var selectedCalendarDate = Date()
    @Published var quickTaskConfig = TaskDTO(object: TaskObject())
    @Published var quickTaskDate = Date()
    @Published var isQuickTaskDateSelected = false
    @Published var quickTaskReminderDate = Date()
    @Published var quickTaskReminderTime = Date()
    @Published var quickTaskReminderDatePeriod: TimePeriod = .am
    @Published var isTypedReminderTime: Bool = false
    @Published var isQuickTaskReminderDateSelected = false
    @Published var isShowingAddTask: Bool = false
    @Published var quickTaskDateType: QuickTaskDate = .date
    @Published var taskSortingOption: TaskDateSorting = .all
    @Published var calendarDate = Date()
    @Published var isShowingCalendar = false
    @Published var isShowingCalendarPicker: Bool = false
    
    @Published var loadedTasks: [TaskDTO] = [] {
        didSet {
            let gropedRecurringTasks = groupedTasks(with: loadedTasks)
            let sortedCompletedTasks = sortedCompletedTasks(gropedRecurringTasks, settings: settings)
            groupedTasksBySelectedOption(taskSortingOption)
            watchConnector.sendTasks(sortedCompletedTasks)
        }
    }
    @Published var filteredTasks: [TaskDTO] = []
    @Published var calendarTasks: [CalendarItem] = []
    @Published var completedTasks: [TaskDTO] = []
    var localNotificationManager: LocalNotificationManager?
    var pastDate = Date()
    var appState: AppState
    
    init(appState: AppState, loadedTasks: [TaskDTO] = []) {
        self.appState = appState
        self.loadedTasks = loadedTasks
        let settings = appState.settingsRepository!.get()
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
        taskSortingOption = settings.taskDateSorting
        search(with: "")
        Task {
            await checkTaskForNotifications()
        }
    }
    
    func loadTasks() {
        let project = appState.projectRepository!.getSelectedProject()
        self.loadedTasks = project.tasks
        self.settings = appState.settingsRepository!.get()
    }
    
    func loadCompletedTasks() {
        let project = appState.projectRepository!.getSelectedProject()
        self.completedTasks = project.tasks.filter({ $0.isCompleted })
    }
    
    func addToCurrentDate(component: Calendar.Component) {
        currentDate = Constants.shared.calendar.date(byAdding: component, value: 1, to: currentDate)!
    }
    
    func minusFromCurrentDate(component: Calendar.Component) {
        guard currentDate > pastDate else { return }
        currentDate = Constants.shared.calendar.date(byAdding: component, value: -1, to: currentDate)!
    }
    
    func isValidWeek() -> Bool {
        guard let startOfCurrentWeek = Date().startOfWeek().byAdding(component: .day, value: 1),
              let endOfPreviousWeek = Constants.shared.calendar.date(byAdding: .day, value: -1, to: startOfCurrentWeek),
              endOfPreviousWeek < currentDate.startOfWeek() else {
            return false
        }
        
        return true
    }
    
    func calendarPickerOptions() -> [CalendarPickerOptions] {
        switch taskSortingOption {
        case .today, .month:
            return [.day, .month]
        case .week:
            return [.week, .year]
        case .all:
            return []
        }
    }
    
    func getWeekSymbols() -> [String] {
        let firstWeekday = Constants.shared.calendar.firstWeekday
        let symbols = Constants.shared.calendar.weekdaySymbols
        
        return Array(symbols[firstWeekday-1..<symbols.count]) + symbols[0..<firstWeekday-1]
    }
    
    func deleteAll() {
        let tasksToDelete = completedTasks
        completedTasks.removeAll()
        tasksToDelete.forEach { appState.taskRepository!.deleteTask(TaskObject($0)) }
    }
    
    func showOrHideItems() {
        let openedItems = loadedTasks.filter({$0.showCheckboxes})
        
        for (index, _) in loadedTasks.enumerated() {
            if openedItems.count == 0 {
                loadedTasks[index].showCheckboxes = true
            } else if loadedTasks.count == loadedTasks.count {
                loadedTasks[index].showCheckboxes = false
            }
        }
        
        var project = appState.projectRepository!.getSelectedProject()
        project.tasks = loadedTasks
        appState.projectRepository!.saveProject(project)
        loadTasks()
    }
    
    func sharedContent() -> String {
        var text = ""
        
        filteredTasks.forEach { task in
            text.append(shareTask(task))
        }
        return text
    }
    
    func shareTask(_ task: TaskDTO) -> String {
        var text = ""
        
         if task.status != .none {
             text.append("Status: \(task.status.rawValue)\n")
         }
        
        var title = NSLocalizedString(task.title, comment: "")
        if task.isCompleted {
            title.append("(Done)")
        }
        
        text.append("Title: \(title)\n")
        
         if !task.checkBoxArray.isEmpty {
             let checkBoxes = task.checkBoxArray.map { "- \($0.title) \($0.isCompleted ? "(Done)" : "")" }.joined(separator: "\n")
             text.append("Checklist:\n\(checkBoxes)\n")
         }
        
         if !task.bulletArray.isEmpty {
             let bullets = task.bulletArray.map { "• \($0.title)" }.joined(separator: "\n")
             text.append("Bulet list:\n\(bullets)\n")
         }
        
         if let time = task.date {
             text.append("Date: \(time.format("dd.MM.yy"))\n")
         }
         
         if let time = task.time {
             let timeFormatter = DateFormatter()
             timeFormatter.dateFormat = "HH:mm"
             
             let formattedTime = timeFormatter.string(from: time)
             text.append("Time: \(formattedTime)\n")
         }
        
        if task.isRecurring, let recurring = task.recurring {
            text.append("Recurring: \(NSLocalizedString(recurring.option.description, comment: ""))\n")
        }
        
        if task.isReminder {
            text.append("Reminder: \(NSLocalizedString(task.reminder.description, comment: ""))\n")
        }
        
         text.append("\n")
        
        return text
    }
}

// MARK: - Quick Task

extension TasksViewModel {
    func addNotification(for task: TaskDTO) {
        guard let localNotificationManager else { return }
        
        Task {
            await localNotificationManager.addNotification(to: .init(task))
        }
    }
    
    func createTask() {
        guard !quickTaskConfig.title.isEmpty else { return }
        quickTaskConfig.date = isQuickTaskDateSelected ? quickTaskDate : nil
        quickTaskConfig.dateOption = isQuickTaskDateSelected ? .custom : .none
        quickTaskConfig.reminderDate = isQuickTaskReminderDateSelected ? quickTaskReminderDate : nil
        quickTaskConfig.reminder = isQuickTaskReminderDateSelected ? .custom : .none
        quickTaskConfig.time = nil
        quickTaskConfig.timeOption = isQuickTaskReminderDateSelected ? .custom : .none
        quickTaskConfig.timePeriod = quickTaskReminderDatePeriod
        
        quickTaskConfig.reminderDate = Constants.shared.calendar.date(
            bySettingHour: quickTaskReminderTime.dateComponents([.hour]).hour ?? 12,
            minute: quickTaskReminderTime.dateComponents([.minute]).minute ?? 00,
            second: 0, of: quickTaskReminderDate
        )!
        
        if settings.addNewTaskIn == .bottom {
            quickTaskConfig.sortingOrder = filteredTasks.count + 1
            loadedTasks.append(quickTaskConfig)
        } else {
            if let taskWithMinSortingOrder = filteredTasks.min(by: { $0.sortingOrder < $1.sortingOrder }) {
                quickTaskConfig.sortingOrder = taskWithMinSortingOrder.sortingOrder - 1
                loadedTasks.insert(quickTaskConfig, at: 0)
                filteredTasks.insert(quickTaskConfig, at: 0)
            } else {
                loadedTasks.append(quickTaskConfig)
                filteredTasks.append(quickTaskConfig)
            }
        }
        addNotification(for: quickTaskConfig)
        
        for index in self.loadedTasks.indices {
            self.loadedTasks[index].sortingOrder = index
        }
        appState.taskRepository?.saveTasks(loadedTasks)
        
        var selectedProject = appState.projectRepository!.getSelectedProject()
        selectedProject.tasks.append(quickTaskConfig)
        appState.projectRepository!.saveProject(selectedProject)
        
        if taskSortingOption == .all {
            groupedTasksBySelectedOption(.all)
        }
        
        quickTaskConfig = TaskDTO(object: TaskObject())
        isQuickTaskDateSelected = false
        isQuickTaskReminderDateSelected = false
        quickTaskReminderTime = Date()
        quickTaskDate = Date()
        quickTaskReminderDate = Date()
    }
    
    @MainActor
    func checkTaskForNotifications() {
        let unCompletedTasks = groupedTasks(with: loadedTasks)
            .filter { !$0.isCompleted }
            .filter { $0.reminder != .none }
            .sorted(by: {
                if let lhsDate = $0.reminderDate, let rhsDate = $1.reminderDate {
                    return lhsDate < rhsDate
                }
                
                return false
            })
            .prefix(20)
        
        for task in unCompletedTasks {
            guard let localNotificationManager, !localNotificationManager.pendingNotifications
                .contains(where: { $0.identifier == task.id.stringValue })
            else { return }
            
            if let reminderDate = task.reminderDate, reminderDate.isSameDay(with: currentDate) {
                addNotification(for: task)
            }
        }
    }
}

// MARK: - TaskRow

extension TasksViewModel {
    
    func calculateDateColor(whit date: Date, themeTextColor: Color, isDate: Bool) -> Color {
        let currentDate = Date()
        return date < (isDate ? currentDate.startDay : currentDate) ? .red : themeTextColor
    }
    
    @MainActor
    func deleteTask(_ task: TaskDTO) {
        guard let localNotificationManager else { return }
        
        let project = appState.projectRepository!.getSelectedProject()
        let tasksToDelete = project.tasks.filter({ $0.parentId == task.parentId })
        filteredTasks.removeAll(where: { $0.parentId == task.parentId })
        loadedTasks.removeAll(where: { $0.parentId == task.parentId })
        appState.taskRepository!.deleteAll(where: task.parentId)
        tasksToDelete.forEach {
            localNotificationManager.deleteNotification(with: $0.id.stringValue)
        }
    }
    
    func updateTaskCompletion(_ taskId: String) {
        hapticFeedBack()
        if let index = filteredTasks.firstIndex(where: { $0.id.stringValue == taskId }) {
            filteredTasks[index].isCompleted.toggle()
            filteredTasks = sortedCompletedTasks(filteredTasks, settings: settings)
        }
        if let index = loadedTasks.firstIndex(where: { $0.id.stringValue == taskId }) {
            loadedTasks[index].isCompleted.toggle()
            appState.taskRepository!.saveTask(loadedTasks[index])
            
            if loadedTasks[index].isCompleted {
                var value = UserDefaults.standard.integer(forKey: "CompletedTask")
                value += 1
                UserDefaults.standard.setValue(value, forKey: "CompletedTask")
            }
        }
        if let index = completedTasks.firstIndex(where: { $0.id.stringValue == taskId }) {
            completedTasks[index].isCompleted.toggle()
            appState.taskRepository!.saveTask(completedTasks[index])
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
            appState.taskRepository!.saveTask(loadedTasks[index])
        }
        
        if let index = completedTasks.firstIndex(where: { $0.id == task.id }) {
            completedTasks[index].showCheckboxes.toggle()
            appState.taskRepository!.saveTask(completedTasks[index])
        }
    }
    
    func updateCheckbox(_ checkbox: CheckboxDTO) {
        var object = checkbox
        object.isCompleted.toggle()
        appState.checkboxRepository!.save(object)
    }
    
    func completeCheckbox(_ checkbox: CheckboxDTO, with taskId: String) {
        hapticFeedBack()
        if let taskIndex = filteredTasks.firstIndex(where: { $0.id.stringValue == taskId }) {
            if let checkboxIndex = filteredTasks[taskIndex].checkBoxArray.firstIndex(where: { $0.id == checkbox.id }) {
                filteredTasks[taskIndex].checkBoxArray[checkboxIndex].isCompleted.toggle()
            }
        }
        if let taskIndex = loadedTasks.firstIndex(where: { $0.id.stringValue == taskId }) {
            if let checkboxIndex = loadedTasks[taskIndex].checkBoxArray.firstIndex(where: { $0.id == checkbox.id }) {
                loadedTasks[taskIndex].checkBoxArray[checkboxIndex].isCompleted.toggle()
                appState.checkboxRepository!.save(loadedTasks[taskIndex].checkBoxArray[checkboxIndex])
            }
        }
    }
    
    func dateFormat() -> String {
        let settings = appState.settingsRepository!.get()
        
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

extension TasksViewModel {
    
    func saveSortingOrder() {
        var orderedTasks = [TaskDTO]()
        
        for parentIndex in filteredTasks.indices {
            /// Change order for all same tasks
            let tasks = loadedTasks
                .filter { $0.parentId == filteredTasks[parentIndex].parentId }
            
            for task in tasks {
                var task = task
                task.sortingOrder = parentIndex
                orderedTasks.append(task)
                
                if let currentTask = filteredTasks.firstIndex(where: { $0.id == task.id }) {
                    filteredTasks[currentTask].sortingOrder = parentIndex
                }
            }
        }
        
        appState.taskRepository!.saveTasks(orderedTasks)
    }
    
    func moveTask(fromOffsets indices: IndexSet, toOffset newOffset: Int) {
        filteredTasks.move(fromOffsets: indices, toOffset: newOffset)
        
        saveSortingOrder()
        
        if settings.taskSorting != .manual {
            settings.taskSorting = .manual
            appState.settingsRepository!.save(settings)
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
        
        saveSortingOrder()
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
                return $0.sortingOrder < $1.sortingOrder
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

// MARK: - Week List Sorting

extension TasksViewModel {
    private var taskGropedByDate: [String: [TaskDTO]] {
        Dictionary(grouping: filteredTasks) {
            if let taskDate = $0.date {
                return taskDate.format(self.dateFormat())
            } else {
                return $0.createdDate.format(self.dateFormat())
            }
        }
    }
    
    var sectionHeaders: [String] {
        currentDate.daysOfWeek().map { $0.format(self.dateFormat()) }
    }
    
    func sectionContent(_ key: String) -> [TaskDTO] {
        taskGropedByDate[key] ?? []
            .filter {
                if let taskDate = $0.date {
                    return taskDate.isSameWeek(with: currentDate)
                } else if $0.isRecurring {
                    return $0.createdDate.isSameWeek(with: currentDate)
                }
                
                return false
            }
    }
    
    func sectionHeader(_ key: String) -> String {
        key
    }
    
    func hapticFeedBack() {
        guard settings.hapticFeedback else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
