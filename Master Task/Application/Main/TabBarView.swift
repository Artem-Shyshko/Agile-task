//
//  TabBarView.swift
//  Master Task
//
//  Created by Artur Korol on 08.08.2023.
//

import SwiftUI
import RealmSwift


// MARK: - Enum

enum TaskListNavigationView: Hashable {
    case createTask, completedTasks, sorting, newCheckBox
}

enum SettingsNavigationView: Hashable {
    case account, theme, taskSettings, security, more, contactUs
}

enum TabItem {
    case taskList, calendar, projects, settings
}

struct TabBarView: View {
    
    // MARK: - Properties
    
    @ObservedResults(Account.self) var savedAccountsList
    @ObservedResults(TaskSettings.self) var savedTaskSettings
    @State private var selectedTab: TabItem = .taskList
    @State private var taskListNavigationStack: [TaskListNavigationView] = []
    @State private var settingsNavigationStack: [SettingsNavigationView] = []
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: tabSelection()) {
            TaskListView(path: $taskListNavigationStack)
                .tabItem {
                    Label("Tasks", image: "tasks")
                }
                .tag(TabItem.taskList)
                .toolbar(.visible, for: .tabBar)
            TaskListView(selectedCalendarTab: true, path: $taskListNavigationStack)
                .tabItem {
                    Label("Calendar", image: "calendar")
                }
                .tag(TabItem.calendar)
            ProjectsView()
                .tabItem {
                    Label("Projects", image: "project")
                }
                .tag(TabItem.projects)
            SettingsView(path: $settingsNavigationStack)
                .tabItem { tabLabel(icon: "settings", title: "Settings") }
                .tag(TabItem.settings)
        }
        .tint(.white)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor(Color.clear)
            let standardAppearance = UITabBarAppearance()
            standardAppearance.configureWithTransparentBackground()
            standardAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            standardAppearance.backgroundColor = UIColor(Color.clear)
            UITabBar.appearance().standardAppearance = standardAppearance
            UITabBar.appearance().unselectedItemTintColor = .white
            addPersonalAccount()
            initSettings()
        }
    }
    
    func tabLabel(icon: String, title: String) -> some View {
        VStack(spacing: 10) {
            Image(icon)
                .padding(.bottom, 5)
            Text(title)
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}

private extension TabBarView {
    func addPersonalAccount() {
        if savedAccountsList.isEmpty {
            let account = Account()
            account.name = "Personal"
            account.isSelected = true
            $savedAccountsList.append(account)
        }
    }
    
    func initSettings() {
        if savedTaskSettings.isEmpty {
            $savedTaskSettings.append(TaskSettings())
        }
    }
}

extension TabBarView {
    private func tabSelection() -> Binding<TabItem> {
        Binding {
            self.selectedTab
        } set: { tappedTab in
            self.selectedTab = tappedTab
            taskListNavigationStack = []
            settingsNavigationStack = []
        }
    }
}
