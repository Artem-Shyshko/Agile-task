//
//  Master_TaskApp.swift
//  Agile Task
//
//  Created by Artur Korol on 07.08.2023.
//

import SwiftUI
import BackgroundTasks

@main
struct Master_TaskApp: App {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var localNotificationManager = LocalNotificationManager()
    @StateObject var purchaseManager = PurchaseManager()
    @StateObject var authManager = AuthManager()
    @StateObject var appThemeManager = ThemeManager()
    @StateObject var appState = AppState()
    
    @State private var isDarkModeOn = false
    @State private var showAuthView = false
    
    let settingsRepository: SettingsRepository = SettingsRepositoryImpl()
    let projectRepository: ProjectRepository = ProjectRepositoryImpl()
    
    var isNoneAuthorised: Bool {
        let settings = settingsRepository.get()
        
        if settings.securityOption != .none,
           authManager.state == .noneAuth {
            return true
        }
        return false
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.greenGradient
                if AppHelper.shared.isOnboarding {
                        TabBarView()
                } else {
                    NavigationStack {
                        WelcomeView()
                    }
                }
                
                if isNoneAuthorised {
                    AuthView(vm: AuthViewModel(), isShowing: $showAuthView)
                }
            }
            .ignoresSafeArea()
            .environmentObject(localNotificationManager)
            .environmentObject(purchaseManager)
            .environmentObject(authManager)
            .environmentObject(appThemeManager)
            .environmentObject(appState)
            .preferredColorScheme(appThemeManager.theme.colorScheme)
            .onAppear {
                UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
                let settings = settingsRepository.get()
                let _ = projectRepository.getSelectedProject()
                if settings.securityOption != .none {
                    showAuthView = true
                }
                appState.settings = settings
            }
            .task(id: scenePhase) {
                if scenePhase == .active {
                    await purchaseManager.fetchActiveTransactions()
                }
            }
            .environment(\.locale, Locale(identifier: appState.settings.appLanguage.identifier))
        }
        .onChange(of: scenePhase) { scene in
            if appState.settings.securityOption != .none {
                if scene == .background {
                    authManager.state = .noneAuth
                }
            }
            
            if scene == .background {
                scheduleAppRefresh()
            }
        }
        .backgroundTask(.appRefresh("com.masterapps.agile-task.refresh")) {
//                let settings = await settingsRepository.getAsync()
//                if let settings {
//                    await localNotificationManager.addDailyNotification(
//                        for: settings.reminderTime,
//                        format: settings.timeFormat,
//                        period: settings.reminderTimePeriod
//                    )
//                }
        }
    }
}

private extension Master_TaskApp {
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.masterapps.agile-task.refresh")
        
        let preferredHour: TimeInterval = 3 * 60 * 60 // 3 hours from midnight in seconds
        
        // Schedule from now assuming the next possible 3 AM window
        if let nextPreferredTime = Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 3), matchingPolicy: .nextTime) {
            request.earliestBeginDate = nextPreferredTime
        } else {
            request.earliestBeginDate = Date(timeIntervalSinceNow: preferredHour)
        }
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Ready")
        } catch {
            print(error.localizedDescription)
        }
    }
}
