//
//  Master_TaskApp.swift
//  Agile Task
//
//  Created by Artur Korol on 07.08.2023.
//

import SwiftUI
import BackgroundTasks
import SwiftyDropbox

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        DropboxClientsManager.setupWithAppKey(Constants.shared.dropboxKey)
        return true
    }
}

@main
struct Master_TaskApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var localNotificationManager = LocalNotificationManager()
    @StateObject var purchaseManager = PurchaseManager()
    @StateObject var authManager = AuthManager()
    @StateObject var appThemeManager = ThemeManager()
    @StateObject var appState = AppState()
    
    @State private var isDarkModeOn = false
    @State private var showAuthView = false
    @State private var showTabBar = false
    
    var isNoneAuthorised: Bool {
        let settings = appState.settingsRepository!.get()
        
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
                TabBarView()
                
                if isNoneAuthorised {
                    AuthenticationView(viewModel: AuthenticationViewModel(appState: appState), isShowing: $showAuthView)
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
                let settings = appState.settingsRepository!.get()
                let _ = appState.projectRepository!.getSelectedProject()
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
        }
    }
}
