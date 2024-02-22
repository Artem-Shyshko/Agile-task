//
//  LocalNotificationManager.swift
//  Agile Task
//
//  Created by Artur Korol on 21.09.2023.
//

import NotificationCenter

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
        
        if task.reminder == .tomorrow
            || task.reminder == .nextWeek
            || task.reminder == .withRecurring
            || task.isRecurring && task.reminder != .custom
        {
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
    
    func deleteNotification(with identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        removeAllDeliveredNotifications()
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
