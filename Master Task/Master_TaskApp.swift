//
//  Master_TaskApp.swift
//  Master Task
//
//  Created by Artur Korol on 07.08.2023.
//

import SwiftUI

@main
struct Master_TaskApp: App {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var userState = UserState()
    @StateObject var localNotificationManager = LocalNotificationManager()
    @StateObject var purchaseManager = PurchaseManager()
    @StateObject var authManager = AuthManager()
    @StateObject var appThemeManager = ThemeManager()
    
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
            .environmentObject(userState)
            .environmentObject(localNotificationManager)
            .environmentObject(purchaseManager)
            .environmentObject(authManager)
            .environmentObject(appThemeManager)
            .onAppear {
                UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
                let settings = settingsRepository.get()
                let _ = projectRepository.getSelectedProject()
                if settings.securityOption != .none {
                    showAuthView = true
                }
            }
            .task {
                await purchaseManager.updatePurchasedProducts()
            }
            .onChange(of: scenePhase) { scene in
                let settings = settingsRepository.get()
                if settings.securityOption != .none {
                    if scene == .background {
                        authManager.state = .noneAuth
                    }
                }
            }
        }
    }
}
