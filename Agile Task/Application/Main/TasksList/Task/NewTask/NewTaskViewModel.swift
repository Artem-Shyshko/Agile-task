//
//  NewTaskViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 11.08.2023.
//

import SwiftUI
import MasterAppsUI
import RealmSwift

final class NewTaskViewModel: ObservableObject {
    private lazy var currentDate = Date()
    @Published var taskStatus: TaskStatus = .none
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var taskDate: Date = Date()
    @Published var selectedDateOption: DateType = .none
    @Published var taskTime: Date = Date()
    @Published var selectedTimeOption: TimeOption = .none
    @Published var selectedDateTimePeriod: TimePeriod = .am
    @Published var reminder: Reminder = .none
    @Published var reminderDate: Date = Date()
    @Published var reminderTime: Date = Date()
    @Published var isTypedReminderTime: Bool = false
    @Published var selectedReminderTimePeriod: TimePeriod = .am
    @Published var selectedColor: Color = .sectionColor
    @Published var isCompleted = false
    @Published var selectedProjectName: String
    @Published var projectsNames: [String] = []
    @Published var checkBoxes: [CheckboxDTO] = []
    @Published var bullets: [BulletDTO] = []
    @Published var recurringConfiguration = RecurringConfigurationDTO()
    
    @Published var showSubscriptionView = false
    @Published var isButtonPress = false
    @Published var showDeleteAlert = false
    @Published var showReminderAlert = false
    @Published var showTitleAlert = false
    @Published var showColorPanel = false
    @Published var alertTitle: String = ""
    @Published var calendarDate = Date()
    
    private let taskRepository: TaskRepository = TaskRepositoryImpl()
    private let settingsRepository: SettingsRepository = SettingsRepositoryImpl()
    private let projectRepository: ProjectRepository = ProjectRepositoryImpl()
    
    var localNotificationManager: LocalNotificationManager?
    var settings: SettingsDTO
    var colors: [Color] = [.sectionColor, .teaRose, .lemonСhiffon, .mindaro, .nyanza, .aquamarineColor, .periwinkle, .mauve]
    
    // MARK: - init
    
    init() {
        settings = settingsRepository.get()
        selectedProjectName = projectRepository.getSelectedProject().name
        projectsNames = projectRepository.getProjects().map {$0.name}
    }
    
    // MARK: - Methods
    
    func createTask() -> TaskDTO {
        compareDateAndTime()
        var task = TaskDTO(object: TaskObject())
        task.parentId = task.id
        task.status = taskStatus
        task.title = title
        task.description = description.isEmpty ? nil : description
        task.date = selectedDateOption != .none ? taskDate : nil
        task.dateOption = selectedDateOption
        task.recurring = recurringConfiguration
        task.time = selectedTimeOption == .none ? nil : taskTime
        task.timePeriod = selectedDateTimePeriod
        task.timeOption = selectedTimeOption
        task.reminder = reminder
        task.reminderDate = reminder != .none ? reminderDate : nil
        task.createdDate = Date()
        task.colorName = selectedColor.name
        task.checkBoxArray = checkBoxes
        task.bulletArray = bullets
        
        return task
    }
    
    func writeTask(_ task: TaskDTO) {
        if var project = projectRepository.getProjects().first(where: { $0.name == selectedProjectName }) {
            var tasks = project.tasks
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index] = task
                project.tasks = tasks
                projectRepository.saveProject(project)
            } else {
                project.tasks.append(task)
                projectRepository.saveProject(project)
            }
        }
    }
    
    func updateTask(task: TaskDTO) -> TaskDTO {
        compareDateAndTime()
        var task = task
        task.status = taskStatus
        task.title = title
        task.description = description.isEmpty ? nil : description
        task.date = selectedDateOption != .none ? taskDate : nil
        task.dateOption = selectedDateOption
        task.time = selectedTimeOption == .none ? nil : taskTime
        task.timePeriod = selectedDateTimePeriod
        task.timeOption = selectedTimeOption
        task.recurring = recurringConfiguration
        task.reminder = reminder
        task.reminderDate = reminderDate
        task.colorName = selectedColor.name
        task.modificationDate = currentDate
        task.isCompleted = isCompleted
        task.checkBoxArray = checkBoxes
        task.bulletArray = bullets
        
        return task
    }
    
    func createRecurringTask(
        with parent: TaskDTO,
        on date: Date,
        reminderDate: Date?
    ) -> TaskDTO {
        var task = TaskDTO(object: TaskObject())
        task.parentId = parent.id
        task.status = parent.status
        task.title = parent.title
        task.description = parent.description
        task.date = nil
        task.dateOption = .none
        task.recurring = parent.recurring
        task.time = parent.time
        task.timePeriod = parent.timePeriod
        task.timeOption = parent.timeOption
        task.reminder = parent.reminder
        task.reminderDate = reminderDate
        task.createdDate = date
        task.colorName = parent.colorName
        task.checkBoxArray = parent.checkBoxArray
        task.bulletArray = parent.bulletArray
        
        return task
    }
    
    func addRecurringRepeatingCount() {
        recurringConfiguration.repeatCount = String((Int(recurringConfiguration.repeatCount) ?? 0) + 1)
    }
    
    func minusRecurringRepeatingCount() {
        if (Int(recurringConfiguration.repeatCount) ?? 0) > 0 {
            recurringConfiguration.repeatCount = String((Int(recurringConfiguration.repeatCount) ?? 0) - 1)
        }
    }
    
    func addRecurringEndsAfterOccurrences() {
        recurringConfiguration.endsAfterOccurrences = String((Int(recurringConfiguration.endsAfterOccurrences) ?? 0) + 1)
    }
    
    func minusRecurringEndsAfterOccurrences() {
        if (Int(recurringConfiguration.endsAfterOccurrences) ?? 0) > 0 {
            recurringConfiguration.endsAfterOccurrences = String((Int(recurringConfiguration.endsAfterOccurrences) ?? 0) - 1)
        }
    }
    
    func controlSelectedDay(isSelectDay: Bool, dayName: String) {
        if isSelectDay {
            recurringConfiguration.repeatOnDays.append(dayName)
        } else {
            recurringConfiguration.repeatOnDays.removeAll(where: {$0 == dayName})
        }
    }
    
    func compareDateAndTime() {
        self.reminderDate = Constants.shared.calendar.date(
            bySettingHour: reminderTime.dateComponents([.hour]).hour ?? 12,
            minute: reminderTime.dateComponents([.minute]).minute ?? 00,
            second: 0, of: reminderDate
        )!
        
        setupTime()
    }
    
    func updateFromEditTask(_ editTask: TaskDTO?) {
        if let editTask {
            taskStatus = editTask.status
            title = editTask.title
            checkBoxes = editTask.checkBoxArray.sorted(by: { $0.sortingOrder < $1.sortingOrder })
            bullets = editTask.bulletArray.sorted(by: { $0.sortingOrder < $1.sortingOrder })
            selectedColor = Color(editTask.colorName)
            isCompleted = editTask.isCompleted
            
            if let recurring = editTask.recurring {
                recurringConfiguration = recurring
            }
            selectedDateTimePeriod = editTask.timePeriod
            
            if let date = editTask.date {
                taskDate = date
                selectedDateOption = editTask.dateOption
            }
            
            if let time = editTask.time {
                taskTime = time
                selectedTimeOption = editTask.timeOption
            }
            
            if let reminderDate = editTask.reminderDate {
                self.reminderDate = reminderDate
                reminder = editTask.reminder
                reminderTime = reminderDate
            }
            
            if let description = editTask.description {
                self.description = description
            }
        }
    }
    
    func setupTime() {
        let isTwelve = settings.timeFormat == .twelve
        
        let dateFormatter = Constants.shared.dateFormatter
        dateFormatter.dateFormat = isTwelve ? "h:mm" : "HH:mm"
        var timeString = dateFormatter.string(from: taskTime)
        timeString +=  isTwelve ? " \(selectedDateTimePeriod.rawValue)" : ""
        dateFormatter.dateFormat = isTwelve ? "h:mm a" : "HH:mm"
        
        if let timeDate = dateFormatter.date(from: timeString) {
            let time = timeDate
            
            var components = time.dateComponents([.day, .month, .year, .hour, .minute])
            components.day = taskDate.dateComponents([.day]).day
            components.month = taskDate.dateComponents([.month]).month
            components.year = taskDate.dateComponents([.year]).year
            
            guard let newTimeDate = Constants.shared.calendar.date(from: components) else { return }
            taskTime = newTimeDate
            taskDate = newTimeDate
        }
    }
    
    func writeRecurringTaskArray(for task: TaskDTO) {
        if var project = projectRepository.getProjects().first(where: { $0.name == selectedProjectName }) {
            if recurringConfiguration.option == .custom {
                let taskArray = createCustomTaskRecurringArray(for: task)
                taskArray.forEach { addNotification(for: $0) }
                project.tasks += taskArray
                projectRepository.saveProject(project)
            } else if recurringConfiguration.option != .none {
                let taskArray = createTaskRecurringArray(for: task)
                taskArray.forEach { addNotification(for: $0) }
                project.tasks += taskArray
                projectRepository.saveProject(project)
            } else {
                writeTask(task)
            }
        }
    }
    
    func deleteNotification(for id: String) {
        guard let localNotificationManager else { return }
        
        Task {
            await localNotificationManager.deleteNotification(with: id)
        }
    }
    
    func addNotification(for task: TaskDTO) {
        guard let localNotificationManager else { return }
        
        Task {
            await localNotificationManager.addNotification(to: task)
        }
    }
    
    func writeEditedTask(_ task: TaskDTO) {
        let edited = self.updateTask(task: task)
        
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
                taskRepository.saveCheckbox(checkbox)
            }
        }
        
        for (index, item) in self.bullets.enumerated() {
            if task.bulletArray.contains(where: { $0.id == item.id }) {
                guard var bullet = task.bulletArray.first(where: {$0.id == item.id}) else { return }
                bullet.sortingOrder = index
                bullet.title = item.title
                taskRepository.saveBullet(bullet)
            } else {
                var task = task
                var item = item
                item.sortingOrder = index
                task.bulletArray.append(item)
                taskRepository.saveBullet(item)
            }
        }
        
        let project = projectRepository.getSelectedProject()
        let tasksArray = project.tasks
            .filter { $0.parentId == task.parentId }
        taskRepository.deleteAll(where: task.parentId)
        tasksArray.forEach { deleteNotification(for: $0.id.stringValue) }
        
        addNotification(for: edited)
        writeRecurringTaskArray(for: edited)
    }
    
    func deleteTask(parentId: ObjectId) {
        let tasksToDelete = taskRepository.getTaskList().filter({ $0.parentId == parentId })
        tasksToDelete.forEach {
            deleteNotification(for: $0.id.stringValue)
        }
        taskRepository.deleteAll(where: parentId)
    }
    
    func toggleCompletionAction(_ editTask: TaskDTO) {
        isCompleted.toggle()
    }
    
    func saveButtonAction(
        hasUnlockedPro: Bool,
        editTask: TaskDTO?,
        taskList: [TaskDTO]) -> Bool {
            guard !title.isEmpty else {
                showTitleAlert = true
                return false
            }
            
            if reminder == .custom, !isTypedReminderTime {
                alertTitle = "You can't create task reminder without date/time"
                showReminderAlert = true
                return false
            }
            
            if let editTask {
                writeEditedTask(editTask)
                return true
            } else {
                var task = createTask()
                
                if settings.addNewTaskIn == .bottom {
                    if let taskWithMinSortingOrder = taskList.min(by: { $0.sortingOrder < $1.sortingOrder }) {
                        task.sortingOrder = taskWithMinSortingOrder.sortingOrder - 1
                    }
                } else {
                    task.sortingOrder = taskList.count + 1
                }
                
                addNotification(for: task)
                writeRecurringTaskArray(for: task)
                
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
        let inADayAddingValue = 2
        let maxYears = 1
        let endsDate: Date = Constants.shared.calendar.date(byAdding: .year, value: maxYears, to: taskDate) ?? taskDate
        var taskDate = task.createdDate
        var reminderDate = reminderDate
        var createdTaskArray: [TaskDTO] = []
        
        if recurringConfiguration.option != .weekdays {
            createdTaskArray.append(task)
        }
        
        while taskDate <= endsDate {
            switch recurringConfiguration.option {
            case .none, .custom:
                break
            case .daily:
                addTimePeriod(for: &taskDate, component: .day, addingValue: repeatEveryNextAddingValue)
                addTimePeriod(for: &reminderDate, component: .day, addingValue: repeatEveryNextAddingValue)
            case .inADay:
                addTimePeriod(for: &taskDate, component: .day, addingValue: inADayAddingValue)
                addTimePeriod(for: &reminderDate, component: .day, addingValue: inADayAddingValue)
            case .weekly:
                addTimePeriod(for: &taskDate, component: .weekOfYear, addingValue: repeatEveryNextAddingValue)
                addTimePeriod(for: &reminderDate, component: .weekOfYear, addingValue: repeatEveryNextAddingValue)
            case .monthly:
                addTimePeriod(for: &taskDate, component: .month, addingValue: repeatEveryNextAddingValue)
                addTimePeriod(for: &reminderDate, component: .month, addingValue: repeatEveryNextAddingValue)
            case .yearly:
                addTimePeriod(for: &taskDate, component: .year, addingValue: repeatEveryNextAddingValue)
                addTimePeriod(for: &reminderDate, component: .year, addingValue: repeatEveryNextAddingValue)
            case .weekdays:
                let weekDays = taskDate.daysOfWeek(using: Constants.shared.calendar)
                let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
                
                weekDays.forEach { day in
                    addTimePeriod(for: &taskDate, component: .day, addingValue: repeatEveryNextAddingValue)
                    addTimePeriod(for: &reminderDate, component: .day, addingValue: repeatEveryNextAddingValue)
                    
                    let dayName = day.format("EEEE")
                    
                    if days.contains(dayName) {
                        let task = createRecurringTask(with: task, on: day, reminderDate: reminderDate)
                        createdTaskArray.append(task)
                    }
                }
            }
            
            if recurringConfiguration.option != .weekdays {
                let task = createRecurringTask(with: task, on: taskDate, reminderDate: reminderDate)
                createdTaskArray.append(task)
            }
        }
        
        return createdTaskArray
    }
    
    func createCustomTaskRecurringArray(
        for task: TaskDTO
    ) -> [TaskDTO] {
        let repeatCount = Int(recurringConfiguration.repeatCount) ?? 1
        var endsDate: Date
        var taskDate = task.createdDate
        var reminderDate = reminderDate
        var recurringEndsAfterOccurrences = Int(recurringConfiguration.endsAfterOccurrences) ?? 0
        var createdTaskArray: [TaskDTO] = []
        
        switch recurringConfiguration.endsOption {
        case .on:
            endsDate = recurringConfiguration.endsDate
        case .after, .never:
            endsDate = Constants.shared.calendar.date(byAdding: .year, value: 1, to: taskDate) ?? taskDate
        }
        
        while taskDate <= endsDate {
            if recurringConfiguration.endsOption == .after {
                if recurringEndsAfterOccurrences >= 0 {
                    recurringEndsAfterOccurrences -= 1
                } else {
                    break
                }
            }
            
            switch recurringConfiguration.repeatEvery {
            case .days:
                addTimePeriod(for: &taskDate, component: .day, addingValue: repeatCount)
                addTimePeriod(for: &reminderDate, component: .day, addingValue: repeatCount)
            case .weeks:
                addTimePeriod(for: &taskDate, component: .weekOfMonth, addingValue: repeatCount)
                addTimePeriod(for: &reminderDate, component: .weekOfMonth, addingValue: repeatCount)
                
                let weekDays = taskDate.daysOfWeek(using: Constants.shared.calendar)
                
                weekDays.forEach { day in
                    let dayName = day.format("EEEE")
                    if recurringConfiguration.repeatOnDays.contains(dayName) {
                        let task = createRecurringTask(with: task, on: day, reminderDate: reminderDate)
                        createdTaskArray.append(task)
                    }
                }
            case .month:
                addTimePeriod(for: &taskDate, component: .month, addingValue: repeatCount)
                addTimePeriod(for: &reminderDate, component: .month, addingValue: repeatCount)
            case .years:
                addTimePeriod(for: &taskDate, component: .year, addingValue: repeatCount)
                addTimePeriod(for: &reminderDate, component: .year, addingValue: repeatCount)
            }
            
            if recurringConfiguration.repeatEvery != .weeks {
                let task = createRecurringTask(with: task, on: taskDate, reminderDate: reminderDate)
                createdTaskArray.append(task)
            }
            
            if repeatCount == 0 {
                break
            }
        }
        
        return createdTaskArray
    }
    
    func addTimePeriod(for date: inout Date, component: Calendar.Component, addingValue: Int) {
        date = Constants.shared.calendar.date(byAdding: component, value: addingValue, to: date) ?? date
    }
}