//
//  LocalNotificationManager.swift
//  Master Task
//
//  Created by Artur Korol on 21.09.2023.
//

import NotificationCenter

@MainActor
final class LocalNotificationManager: NSObject, ObservableObject {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    func requestAuthorization() async throws {
        try await notificationCenter
            .requestAuthorization(options: [.alert, .badge, .sound])
    }
    
    func addNotification(to task: TaskObject) async  {
        deleteNotification(with: task.id.stringValue)
        
        var reminderTime: Date
        switch task.reminder {
        case .none: return
        case .inOneHour:
            guard let reminderDate = task.reminderDate else { return }
            reminderTime = Constants.shared.calendar.date(byAdding: .hour, value: 1, to: reminderDate)!
        case .tomorrow:
            guard let reminderDate = task.reminderDate else { return }
            reminderTime = reminderDate.byAdding(component: .day, value: 1)!
        case .nextWeek:
            guard let reminderDate = task.reminderDate else { return }
            reminderTime = reminderDate.byAdding(component: .weekOfYear, value: 1)!.startOfWeek()
        case .custom, .withRecurring:
            guard let reminderDate = task.reminderDate else { return }
            reminderTime = reminderDate
        }
        
        var dateComponents = Constants.shared.calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime)
        
        if task.reminder == .tomorrow || task.reminder == .nextWeek || task.reminder == .withRecurring {
            dateComponents.hour = 12
            dateComponents.minute = 0
        }
        
        let notification = LocalNotification(
            id: task.id.stringValue,
            title: "Master Task",
            body: task.title,
            dateComponents: dateComponents,
            repeats: true
        )
        await schedule(localNotification: notification)
    }
    
    func deleteNotification(with identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeAllDeliveredNotifications()
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
    }
}
