//
//  NewTaskViewModel.swift
//  Master Task
//
//  Created by Artur Korol on 11.08.2023.
//

import SwiftUI
import MasterAppsUI
import RealmSwift

enum RecurringEnds: String, CaseIterable {
    case never = "Never"
    case on = "On"
    case after = "After"
}

final class NewTaskViewModel: ObservableObject {
    private lazy var currentDate = Date()
    @Published var title: String = ""
    @Published var taskDate: Date = Date()
    @Published var selectedDateOption: DateType = .none
    @Published var taskTime: Date = Date()
    @Published var selectedTimeOption: TimeOption = .none
    @Published var selectedDateTimePeriod: TimePeriod = .am
    @Published var recurringDate: Date = Date()
    @Published var selectedRecurringOption: RecurringOptions = .none
    @Published var reminder: Reminder = .none
    @Published var reminderDate: Date = Date()
    @Published var reminderTime: Date = Date()
    @Published var isTypedReminderTime: Bool = false
    @Published var selectedReminderTimePeriod: TimePeriod = .am
    @Published var selectedColor: Color = .sectionColor
    @Published var showColorPanel = false
    @Published var isCompleted = false
    @Published var showDeleteAlert = false
    @Published var showReminderAlert = false
    
    // MARK: - Recurring view properties
    
    @Published var repeatCount: String = "0"
    @Published var repeatEvery: RepeatRecurring = .weeks
    @Published var recurringEnds: RecurringEnds = .never
    @Published var recurringEndsDate: Date = Date()
    @Published var recurringEndsAfterOccurrences = "2"
    @Published var selectedRepeatOnDays: [String] = []
    @Published var checkBoxes: [CheckboxDTO] = []
    @Published var showSubscriptionView = false
    @Published var isButtonPress = false
    @Published var alertTitle: String = ""
    
#warning("Change back to 8")
    private let tasksLimit = 80000000
    private let taskRepository: TaskRepository = TaskRepositoryImpl()
    private let settingsRepository: SettingsRepository = SettingsRepositoryImpl()
    
    var localNotificationManager: LocalNotificationManager?
    var settings: SettingsDTO
    var colors: [Color] = [.sectionColor, .teaRose, .lemonСhiffon, .mindaro, .nyanza, .aquamarineColor, .periwinkle, .mauve]
    
    // MARK: - init
    
    init() {
        settings = settingsRepository.get()
    }
    
    // MARK: - Methods
    
    func addNotification(for task: TaskDTO) {
        guard let localNotificationManager else { return }
        
        Task {
            await localNotificationManager.addNotification(to: .init(task))
        }
    }
    
    func createTask() -> TaskDTO {
        compareDateAndTime()
        var task = TaskDTO(object: TaskObject())
        task.parentId = task.id
        task.title = title
        task.date = selectedDateOption != .none ? taskDate : nil
        task.dateOption = selectedDateOption
        task.recurring = selectedRecurringOption
        task.time = selectedTimeOption == .none ? nil : taskTime
        task.timePeriod = selectedDateTimePeriod
        task.timeOption = selectedTimeOption
        task.reminder = reminder
        task.reminderDate = reminder != .none ? reminderDate : nil
        task.createdDate = Date()
        task.colorName = selectedColor.name
        task.checkBoxArray = checkBoxes
        
        return task
    }
    
    func writeTask(_ task: TaskDTO) {
        taskRepository.saveTask(task)
    }
    
    func updateTask(task: TaskDTO) -> TaskDTO {
        compareDateAndTime()
        var task = task
        task.title = title
        task.date = selectedDateOption != .none ? taskDate : nil
        task.dateOption = selectedDateOption
        task.time = selectedTimeOption == .none ? nil : taskTime
        task.timePeriod = selectedDateTimePeriod
        task.timeOption = selectedTimeOption
        task.recurring = selectedRecurringOption
        task.reminder = reminder
        task.reminderDate = reminderDate
        task.colorName = selectedColor.name
        task.modificationDate = currentDate
        task.isCompleted = isCompleted
        task.checkBoxArray = checkBoxes
        
        return task
    }
    
    func createRecurringTask(
        with parent: TaskDTO,
        on date: Date
    ) -> TaskDTO {
        var task = TaskDTO(object: TaskObject())
        task.parentId = parent.id
        task.title = parent.title
        task.date = parent.date
        task.dateOption = parent.dateOption
        task.recurring = parent.recurring
        task.time = parent.time
        task.timePeriod = parent.timePeriod
        task.timeOption = parent.timeOption
        task.reminder = parent.reminder
        task.reminderDate = parent.reminderDate
        task.createdDate = date
        task.colorName = parent.colorName
        task.checkBoxArray = parent.checkBoxArray
        
        return task
    }
    
    func addRecurringRepeatingCount() {
        repeatCount = String((Int(repeatCount) ?? 0) + 1)
    }
    
    func minusRecurringRepeatingCount() {
        if (Int(repeatCount) ?? 0) > 0 {
            repeatCount = String((Int(repeatCount) ?? 0) - 1)
        }
    }
    
    func addRecurringEndsAfterOccurrences() {
        recurringEndsAfterOccurrences = String((Int(recurringEndsAfterOccurrences) ?? 0) + 1)
    }
    
    func minusRecurringEndsAfterOccurrences() {
        if (Int(recurringEndsAfterOccurrences) ?? 0) > 0 {
            recurringEndsAfterOccurrences = String((Int(recurringEndsAfterOccurrences) ?? 0) - 1)
        }
    }
    
    func controlSelectedDay(isSelectDay: Bool, dayName: String) {
        if isSelectDay {
            selectedRepeatOnDays.append(dayName)
        } else {
            selectedRepeatOnDays.removeAll(where: {$0 == dayName})
        }
    }
    
    func compareDateAndTime() {
        if reminder == .custom {
            self.reminderDate = Constants.shared.calendar.date(
                bySettingHour: reminderTime.dateComponents([.hour]).hour ?? 12,
                minute: reminderTime.dateComponents([.minute]).minute ?? 00,
                second: 0, of: reminderDate
            )!
        }
        
        if selectedDateOption == .custom {
            self.taskDate = Constants.shared.calendar.date(
                bySettingHour: taskTime.dateComponents([.hour]).hour ?? 12,
                minute: taskTime.dateComponents([.minute]).minute ?? 00,
                second: 0, of: taskDate
            )!
        }
        
        if selectedTimeOption == .custom, selectedDateOption == .custom {
            var components = taskTime.dateComponents([.day, .month, .year, .hour, .minute])
            components.day = taskDate.dateComponents([.day]).day
            components.month = taskDate.dateComponents([.month]).month
            components.year = taskDate.dateComponents([.year]).year
            
            guard let newTimeDate = Constants.shared.calendar.date(from: components) else { return }
            taskTime = newTimeDate
        }
    }
    
    func writeRecurringTaskArray(
        for task: TaskDTO
    ) {
        if selectedRecurringOption == .custom {
            let taskArray = createCustomTaskRecurringArray(for: task)
            taskArray.forEach { addNotification(for: $0) }
            taskRepository.saveTasks(taskArray)
        } else if selectedRecurringOption != .none {
            let taskArray = createTaskRecurringArray(for: task)
            taskArray.forEach { addNotification(for: $0) }
            taskRepository.saveTasks(taskArray)
        }
    }
    
    @MainActor func writeEditedTask(_ task: TaskDTO) {
        
        let tasksArray = taskRepository.getTaskList()
            .filter { $0.parentId == task.parentId }
        
        let edited = self.updateTask(task: task)
        taskRepository.saveTask(edited)
        
        for (index, checkbox) in self.checkBoxes.enumerated() {
            if task.checkBoxArray.contains(where: { $0.id == checkbox.id }) {
                guard var check = task.checkBoxArray.first(where: {$0.id == checkbox.id}) else { return }
                check.sortingOrder = index
                check.title = checkbox.title
                taskRepository.saveCheckbox(check)
            } else {
                var task = task
                var checkbox = checkbox
                checkbox.sortingOrder = index
                task.checkBoxArray.append(checkbox)
                taskRepository.saveTask(task)
            }
        }
        let recurringTasks = tasksArray.filter { $0.id != edited.id }
        
        recurringTasks.forEach {
            guard let localNotificationManager else { return }
            
            localNotificationManager.deleteNotification(with: $0.id.stringValue)
            taskRepository.deleteTask(.init($0))
        }
        
        writeRecurringTaskArray(
            for: edited
        )
    }
    
    func canCreateTask(hasSubscription: Bool) -> Bool {
        guard hasSubscription else { return  true }
        
        let allTasks = taskRepository.getTaskList()
        
        if tasksLimit <= allTasks.count {
            return false
        } else {
            return true
        }
    }
    
    @MainActor func deleteTask(parentId: ObjectId) {
        let tasksToDelete = taskRepository.getTaskList().filter({ $0.parentId == parentId })
        tasksToDelete.forEach {
            guard let localNotificationManager else { return }
            
            localNotificationManager.deleteNotification(with: $0.id.stringValue)
            taskRepository.deleteTask(TaskObject($0))
        }
    }
    
    func toggleCompletionAction(_ editTask: TaskDTO) {
        isCompleted.toggle()
    }
    
    @MainActor func saveButtonAction(
        hasUnlockedPro: Bool,
        editTask: TaskDTO?,
        taskList: [TaskDTO]) -> Bool {
            guard !title.isEmpty else { return false}
            
            if reminder == .custom, !isTypedReminderTime {
                alertTitle = "You can't create task reminder without date/time"
                showReminderAlert = true
                return false
            }
            
            if let editTask {
                writeEditedTask(editTask)
                return true
            } else {
                guard canCreateTask(
                    hasSubscription: hasUnlockedPro
                ) else {
                    showSubscriptionView = true
                    return false
                }
                
                var task = createTask()
                
                if settings.addNewTaskIn == .bottom {
                    if let taskWithMinSortingOrder = taskList.min(by: { $0.sortingOrder < $1.sortingOrder }) {
                        task.sortingOrder = taskWithMinSortingOrder.sortingOrder - 1
                    }
                } else {
                    task.sortingOrder = taskList.count + 1
                }
                
                writeTask(task)
                addNotification(for: task)
                writeRecurringTaskArray(
                    for: task
                )
                
                return true
            }
        }
    
    func setupTaskDate(with type: DateType) {
        switch type {
        case .none, .custom:
            return
        case .today:
            taskDate = currentDate
        case .tomorrow:
            guard let tomorrowDate = Constants.shared.calendar.date(byAdding: .day, value: 1, to: currentDate) else { return }
            taskDate = tomorrowDate
        case .nextWeek:
            guard let nextWeekDate = Constants.shared.calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) else { return }
            taskDate = nextWeekDate.startOfWeek(using: Constants.shared.calendar)
        }
    }
    
    func setupTaskTime(with type: TimeOption) {
        switch type {
        case .none, .custom:
            return
        case .inOneHour:
            if let timeInOneHour = Constants.shared.calendar.date(byAdding: .hour, value: 1, to: currentDate) {
                taskTime = timeInOneHour
            }
        }
    }
}

// MARK: - Private Methods

private extension NewTaskViewModel {
    
    func createTaskRecurringArray(
        for task: TaskDTO
    ) -> [TaskDTO] {
        let repeatEveryNextAddingValue = 1
        let endsDate: Date = Constants.shared.calendar.date(byAdding: .year, value: 1, to: taskDate) ?? taskDate
        var taskDate = task.createdDate
        var createdTaskArray: [TaskDTO] = []
        
        while taskDate <= endsDate {
            switch selectedRecurringOption {
            case .daily:
                taskDate = Constants.shared.calendar.date(byAdding: .day, value: repeatEveryNextAddingValue, to: taskDate) ?? taskDate
            case .weekly:
                taskDate = Constants.shared.calendar.date(byAdding: .weekOfYear, value: repeatEveryNextAddingValue, to: taskDate) ?? taskDate
            case .monthly:
                taskDate = Constants.shared.calendar.date(byAdding: .month, value: repeatEveryNextAddingValue, to: taskDate) ?? taskDate
            case .yearly:
                taskDate = Constants.shared.calendar.date(byAdding: .year, value: repeatEveryNextAddingValue, to: taskDate) ?? taskDate
            case .none, .custom:
                break
            case .weekdays:
                let weekDays = taskDate.daysOfWeek(using: Constants.shared.calendar)
                let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
                
                weekDays.forEach { day in
                    taskDate = Constants.shared.calendar.date(byAdding: .day, value: repeatEveryNextAddingValue, to: taskDate) ?? taskDate
                    let dayName = day.format("EEEE")
                    if days.contains(dayName) {
                        let task = createRecurringTask(with: task, on: day)
                        createdTaskArray.append(task)
                    }
                }
            }
            
            if selectedRecurringOption != .weekdays {
                let task = createRecurringTask(with: task, on: taskDate)
                createdTaskArray.append(task)
            }
        }
        
        return createdTaskArray
    }
    
    func createCustomTaskRecurringArray(
        for task: TaskDTO
    ) -> [TaskDTO] {
        let repeatCount = Int(repeatCount) ?? 1
        var endsDate: Date
        var taskDate = task.createdDate
        var recurringEndsAfterOccurrences = Int(recurringEndsAfterOccurrences) ?? 0
        var createdTaskArray: [TaskDTO] = []
        
        switch recurringEnds {
        case .on:
            endsDate = recurringEndsDate
        case .after, .never:
            endsDate = Constants.shared.calendar.date(byAdding: .year, value: 1, to: taskDate) ?? taskDate
        }
        
        while taskDate <= endsDate {
            if recurringEnds == .after {
                if recurringEndsAfterOccurrences >= 0 {
                    recurringEndsAfterOccurrences -= 1
                } else {
                    break
                }
            }
            
            switch repeatEvery {
            case .days:
                taskDate = Constants.shared.calendar.date(byAdding: .day, value: repeatCount, to: taskDate) ?? taskDate
            case .weeks:
                taskDate = Constants.shared.calendar.date(byAdding: .weekOfMonth, value: repeatCount, to: taskDate) ?? taskDate
                let weekDays = taskDate.daysOfWeek(using: Constants.shared.calendar)
                
                weekDays.forEach { day in
                    let dayName = day.format("EEEE")
                    if selectedRepeatOnDays.contains(dayName) {
                        let task = createRecurringTask(with: task, on: day)
                        createdTaskArray.append(task)
                    }
                }
            case .month:
                taskDate = Constants.shared.calendar.date(byAdding: .month, value: repeatCount, to: taskDate) ?? taskDate
            case .years:
                taskDate = Constants.shared.calendar.date(byAdding: .year, value: repeatCount, to: taskDate) ?? taskDate
            }
            
            if repeatEvery != .weeks {
                let task = createRecurringTask(with: task, on: taskDate)
                createdTaskArray.append(task)
            }
            
            if repeatCount == 0 {
                break
            }
        }
        
        return createdTaskArray
    }
}
