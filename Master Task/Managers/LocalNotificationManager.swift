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
        
        if let taskDate = task.date, let reminderDate = task.reminderDate {
            var reminderTime: Date
            switch task.reminder {
//            case .typical:
//                reminderTime = Calendar.current.date(byAdding: .hour, value: -1, to: reminderDate) ?? reminderDate
//            case .dontHave:
//                return
//            case .whenStart:
//                reminderTime = taskDate
//            case .fiveMinBefore:
//                reminderTime = Calendar.current.date(byAdding: .minute, value: -5, to: reminderDate) ?? reminderDate
            case .none: return
            case .custom: reminderTime = reminderDate
            }
            
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime)
            let notification = LocalNotification(
                id: UUID().uuidString,
                title: task.title,
                body: "Today at \(taskDate.format("hh:mm"))",
                dateComponents: dateComponents,
                repeats: false
            )
            
            await schedule(localNotification: notification)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.sound, .banner]
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
