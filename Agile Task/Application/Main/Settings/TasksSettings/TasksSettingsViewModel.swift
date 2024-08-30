//
//  TasksSettingsViewModel.swift
//  Agile Task
//
//  Created by USER on 30.08.2024.
//

import SwiftUI

@MainActor
final class TasksSettingsViewModel: ObservableObject {
    @Published var settings: SettingsDTO
    @Published var isShowingAlert = false
    @Published var isNotificationAccess = false
    @Published var isTypedTime = false
    var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
        settings = appState.settingsRepository!.get()
    }
    
    func сompletionСircleAction() {
            settings.сompletionСircle.toggle()
        }
    
    func pushNotificationButtonAction() {
        settings.isPushNotificationEnabled.toggle()
    }
    
    func addPlusButtonAction() {
        settings.showPlusButton.toggle()
    }
    
    func deleteAllTasks() {
        appState.taskRepository!.deleteAll()
    }
    
    func turnOnHapticFeedback() {
            settings.hapticFeedback.toggle()
        }
}

