//
//  TabBarView.swift
//  Agile Task
//
//  Created by Artur Korol on 08.08.2023.
//

import SwiftUI
import RealmSwift
import MasterAppsUI

// MARK: - Enum

enum TaskListNavigationView: Hashable {
    case createTask, completedTasks, sorting, newCheckBox, subscription
}

enum SettingsNavigationView: Hashable {
    case subscription, taskSettings, security, more, contactUs
}

enum ProjectNavigationView: Hashable {
    case subscription, newProject(editHabit: ProjectDTO? = nil)
}

enum Tab: LocalizedStringResource, Identifiable, CaseIterable {
    case taskList = "Tasks"
    case projects = "Projects"
    case settings = "SettingsTab"
    
    var imageName: String {
        switch self {
        case .taskList: return "tasks"
        case .projects: return "project"
        case .settings: return "settings"
        }
    }
    
    var index: Int {
        return Tab.allCases.firstIndex(of: self) ?? 0
    }
    var id: Self {
        self
    }
}

struct TabBarView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    
    @State private var taskListNavigationStack: [TaskListNavigationView] = []
    @State private var projectsNavigationStack: [ProjectNavigationView] = []
    @State private var settingsNavigationStack: [SettingsNavigationView] = []
    private var isTabBarHidden: Bool {
        taskListNavigationStack.contains(.subscription)
        || settingsNavigationStack.contains(.subscription)
        || projectsNavigationStack.contains(.subscription)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            TabView(selection: $appState.selectedTab) {
                TaskListView(path: $taskListNavigationStack)
                    .tag(Tab.taskList)
                ProjectsView(vm: ProjectsViewModel(), path: $projectsNavigationStack)
                    .tag(Tab.projects)
                SettingsView(path: $settingsNavigationStack)
                    .tag(Tab.settings)
            }
            .overlay(alignment: .bottom) {
                if !isTabBarHidden {
                    customTabItem()
                }
            }
        }
        .onChange(of: appState.selectedTab) { newValue in
            taskListNavigationStack = []
            settingsNavigationStack = []
            projectsNavigationStack = []
        }
        .onOpenURL { incomingURL in
            AppHelper.shared.handleIncomingURL(incomingURL) {
                appState.selectedTab = .taskList
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if taskListNavigationStack.isEmpty {
                        taskListNavigationStack.append(.createTask)
                    }
                }
            }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
            .background(Color.red)
            .previewDevice("iPhone 15 pro")
            .environmentObject(AppState())
    }
}

private extension TabBarView {
    func customTabItem(_ tint: Color = .blue, inActiveTint: Color = .white) -> some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.id) {
                tabItem(tab: $0)
            }
        }
        .padding(.horizontal, 15)
        .frame(height: 100)
    }
    
    func tabItem(tab: Tab) -> some View {
        VStack(spacing: 5) {
            Image(tab.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
            
            Text(tab.rawValue)
                .font(.helveticaRegular(size: 16))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            appState.selectedTab = tab
            
            if appState.selectedTab == tab {
                switch appState.selectedTab {
                case .taskList:
                    taskListNavigationStack = []
                case .projects:
                    projectsNavigationStack = []
                case .settings:
                    settingsNavigationStack = []
                }
            }
        }
    }
}
