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
    @StateObject var realmManager = RealmManager()
    @StateObject var appThemeManager = AppThemeManager()
    
    @State private var isDarkModeOn = false
    @State private var showAuthView = false
    var settings: TaskSettings? {
        RealmManager.shared.settings
    }
    
    var isNoneAuthorised: Bool {
        if let settings,
           settings.securityOption != .none,
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
                    AuthView(isShowing: $showAuthView)
                }
            }
            .ignoresSafeArea()
            .environmentObject(userState)
            .environmentObject(localNotificationManager)
            .environmentObject(purchaseManager)
            .environmentObject(authManager)
            .environmentObject(realmManager)
            .environmentObject(appThemeManager)
            .onAppear {
                appThemeManager.setAppTheme()
                print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)
                UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
                if let option = settings?.securityOption, option != .none {
                    showAuthView = true
                }
            }
            .task {
                await purchaseManager.updatePurchasedProducts()
            }
            .onChange(of: scenePhase) { scene in
                if let settings, settings.securityOption != .none {
                    if scene == .background {
                        authManager.state = .noneAuth
                    }
                }
            }
        }
    }
}
