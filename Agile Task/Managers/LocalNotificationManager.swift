//
//  LocalNotificationManager.swift
//  Agile Task
//
//  Created by Artur Korol on 21.09.2023.
//

import NotificationCenter
import MasterAppsUI

@MainActor
final class LocalNotificationManager: NSObject, ObservableObject {
    
    let notificationCenter = UNUserNotificationCenter.current()
    var pendingNotifications = [UNNotificationRequest]()
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        
        Task(priority: .background) {
            await getPendingNotifications()
        }
        
        removeAllDeliveredNotifications()
    }
    
    func requestAuthorization() async throws {
        try await notificationCenter
            .requestAuthorization(options: [.alert, .badge, .sound])
    }
    
    func addNotification(to task: TaskObject) async  {
        guard let reminder = task.reminder, reminder != .none, let reminderDate = task.reminderDate else { return }
        
        guard !isActiveNotifications(for: task.id.stringValue) else { return }
        
        var reminderTime: Date
        if task.isRecurring == false {
            switch reminder {
            case .none: return
            case .inOneHour:
                reminderTime = Constants.shared.calendar.date(byAdding: .hour, value: 1, to: reminderDate)!
            case .tomorrow:
                reminderTime = reminderDate.byAdding(component: .day, value: 1)!
            case .nextWeek:
                reminderTime = reminderDate.byAdding(component: .weekOfYear, value: 1)!.startOfWeek()
            case .custom, .withRecurring:
                reminderTime = reminderDate
            }
        } else {
            reminderTime = reminderDate
        }
        
        var dateComponents = Constants.shared.calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime)
        
        if task.reminder == .withRecurring || task.isRecurring && task.reminder != .custom {
            dateComponents.hour = 12
            dateComponents.minute = 0
        }
        
        let notification = LocalNotification(
            id: task.id.stringValue,
            title: "Agile Task",
            body: task.title,
            dateComponents: dateComponents,
            repeats: false
        )
        await schedule(localNotification: notification)
    }
    
    func addDailyNotification(for reminderTime: Date, format: TimeFormat, period: TimePeriod, tasks: [TaskDTO]) async {
        deleteNotification(with: Constants.shared.dailyNotificationID)
        var dateComponents = Constants.shared.calendar.dateComponents([.hour, .minute], from: reminderTime)
        var tasks = tasks
        let currentDate = Date()
        
        if format == .twelve {
            if period == .pm, dateComponents.hour! < 12 {
                dateComponents.hour! += 12
            } else if period == .am, dateComponents.hour! >= 12 {
                dateComponents.hour! -= 12
            }
        }
        
        tasks = tasks
            .lazy
            .filter { $0.isCompleted == false }
            .filter {
                if let taskDate = $0.date {
                    return taskDate.isSameDay(with: currentDate)
                } else if $0.isRecurring {
                    return $0.createdDate.isSameDay(with: currentDate)
                }
                
                return false
            }
        
        var body = ""
        
        if tasks.count == 0 {
            body = "Today activity: no scheduled tasks."
        } else {
            body = "Today activity: \(tasks.count) scheduled tasks."
        }
        
        print("Send daily reminder")
        
        let notification = LocalNotification(
            id: Constants.shared.dailyNotificationID,
            title: "Agile Task",
            body: body,
            dateComponents: dateComponents,
            repeats: true
        )
        
        await schedule(localNotification: notification)
    }
    
    
    func deleteNotification(with identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        removeAllDeliveredNotifications()
    }
    
    func groupedTasks(with tasks: [TaskDTO], date: Date) -> [TaskDTO] {
        let gropedTasks = Dictionary(grouping: tasks, by: \.parentId)
        
        var tasks: [TaskDTO] = []
        gropedTasks.keys.forEach { id in
            
            guard let group = gropedTasks[id] else { return }
            
            if group.count > 1 {
                if let task = group.first(where: {
                    $0.createdDate.isSameDay(with: date)
                }) {
                    tasks.append(task)
                }
            } else if group.count == 1 {
                if let task = group.first {
                    tasks.append(task)
                }
            }
        }
        
        return tasks
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.list, .banner, .sound]
    }
}

// MARK: - Private Methods

private extension LocalNotificationManager {
    func removeAllDeliveredNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    func isActiveNotifications(for id: String) -> Bool {
        let activeNotifications = pendingNotifications.filter { $0.identifier == id }
        let isActiveNotifications = !activeNotifications.isEmpty
        return isActiveNotifications
    }
    
    func getPendingNotifications() async {
        pendingNotifications = await notificationCenter.pendingNotificationRequests()
    }
    
    func schedule(localNotification: LocalNotification) async {
        let content = UNMutableNotificationContent()
        content.title = localNotification.title
        content.body = localNotification.body
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: localNotification.dateComponents,
            repeats: localNotification.repeats
        )
        let request = UNNotificationRequest(identifier: localNotification.id, content: content, trigger: trigger)
        
        try? await notificationCenter.add(request)
        await getPendingNotifications()
    }
}
