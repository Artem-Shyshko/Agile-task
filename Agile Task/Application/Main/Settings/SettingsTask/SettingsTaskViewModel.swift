//
//  SettingsTaskViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 02.10.2023.
//

import SwiftUI
import MasterAppsUI

@MainActor
final class SettingsTaskViewModel: ObservableObject {
    @Published var settings: SettingsDTO
    @Published var isShowingAlert = false
    @Published var isNotificationAccess = false
    @Published var isTypedTime = false
    
    let settingsRepository: SettingsRepository = SettingsRepositoryImpl()
    private let tasksRepository: TaskRepository = TaskRepositoryImpl()
    
    init() {
        settings = settingsRepository.get()
    }
    
    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        } else {
            return "x.x"
        }
    }
    
    func pushNotificationButtonAction() {
        settings.isPushNotificationEnabled.toggle()
    }
    
    func addPlusButtonAction() {
        settings.showPlusButton.toggle()
    }
    
    func deleteAllTasks() {
        tasksRepository.deleteAll()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error = error {
                    print("Error requesting notifications authorization: \(error.localizedDescription)")
                    return
                }
                
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    self.redirectToSettings()
                }
            }
    }
    
    func getPermissionState() async throws  {
        let current = UNUserNotificationCenter.current()
        
        let result = await current.notificationSettings()
        switch result.authorizationStatus {
        case .authorized:
            isNotificationAccess = true
        default:
            isNotificationAccess = false
        }
    }
    
    func redirectToSettings() {
        DispatchQueue.main.async {
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
    }
}
