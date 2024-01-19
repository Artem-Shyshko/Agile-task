//
//  TabBarView.swift
//  Master Task
//
//  Created by Artur Korol on 08.08.2023.
//

import SwiftUI
import RealmSwift
import MasterAppsUI

// MARK: - Enum

enum TaskListNavigationView: Hashable {
    case createTask, completedTasks, sorting, newCheckBox
}

enum SettingsNavigationView: Hashable {
    case account, taskSettings, security, more, contactUs
}

enum Tab: String, CaseIterable {
    case taskList = "Tasks"
    case calendar = "Calendar"
    case projects = "Project"
    case settings = "Settings"
    
    var imageName: String {
        switch self {
        case .taskList: return "tasks"
        case .calendar: return "calendar"
        case .projects: return "project"
        case .settings: return "settings"
        }
    }
    
    var index: Int {
        return Tab.allCases.firstIndex(of: self) ?? 0
    }
}

struct TabBarView: View {
    
    // MARK: - Properties
    @State private var selectedTab: Tab = .taskList
    @State private var taskListNavigationStack: [TaskListNavigationView] = []
    @State private var settingsNavigationStack: [SettingsNavigationView] = []
    @State private var tasksSortingOption: TaskDateSorting = .all
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TaskListView(path: $taskListNavigationStack, taskSortingOption: $tasksSortingOption)
                    .tag(Tab.taskList)
                    .toolbar(.hidden, for: .tabBar)
                TaskListView(path: $taskListNavigationStack, taskSortingOption: $tasksSortingOption)
                    .tag(Tab.calendar)
                    .toolbar(.hidden, for: .tabBar)
                ProjectsView(vm: ProjectsViewModel())
                    .tag(Tab.projects)
                    .toolbar(.hidden, for: .tabBar)
                SettingsView(path: $settingsNavigationStack)
                    .tag(Tab.settings)
                    .toolbar(.hidden, for: .tabBar)
            }
            
            VStack {
                Spacer()
                customTabItem()
            }
        }
        .onChange(of: selectedTab) { newValue in
            taskListNavigationStack = []
            settingsNavigationStack = []
        }
        .padding(.bottom, 30)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}

private extension TabBarView {
    func customTabItem(_ tint: Color = .blue, inActiveTint: Color = .white) -> some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) {
                TabItem(
                    tint: tint,
                    inActiveTint: inActiveTint,
                    tab: $0,
                    activeTab: $selectedTab, 
                    tasksSortingOption: $tasksSortingOption
                )
            }
        }
        .padding(.horizontal, 15)
    }
}

struct TabItem: View {
    var tint: Color
    var inActiveTint: Color
    var tab: Tab
    @Binding var activeTab: Tab
    @Binding var tasksSortingOption: TaskDateSorting
    
    var body: some View {
        VStack(spacing: 10) {
            Image(tab.imageName)
                .frame(width: 26, height: 26)
            
            Text(tab.rawValue)
                .font(.helveticaRegular(size: 14))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            activeTab = tab
            
            if tab == .taskList {
                tasksSortingOption = .all
            } else if tab == .calendar {
                tasksSortingOption = .month
            }
        }
    }
}
