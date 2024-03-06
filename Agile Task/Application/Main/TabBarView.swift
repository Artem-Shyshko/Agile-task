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
    case createTask, completedTasks, sorting, newCheckBox, subscribtion
}

enum SettingsNavigationView: Hashable {
    case account, taskSettings, security, more, contactUs
}

enum Tab: String, CaseIterable {
    case taskList = "Tasks"
    case projects = "Projects"
    case settings = "Settings"
    
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
}

struct TabBarView: View {
    
    // MARK: - Properties
    @State private var selectedTab: Tab = .taskList
    @State private var taskListNavigationStack: [TaskListNavigationView] = []
    @State private var settingsNavigationStack: [SettingsNavigationView] = []
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TaskListView(path: $taskListNavigationStack)
                    .tag(Tab.taskList)
                ProjectsView(vm: ProjectsViewModel())
                    .tag(Tab.projects)
                SettingsView(path: $settingsNavigationStack)
                    .tag(Tab.settings)
            }
            .overlay(alignment: .bottom) {
                    customTabItem()
            }
        }
        .onChange(of: selectedTab) { newValue in
            taskListNavigationStack = []
            settingsNavigationStack = []
        }
        .onOpenURL { incomingURL in
            AppHelper.shared.handleIncomingURL(incomingURL) {
                selectedTab = .taskList
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
                    activeTab: $selectedTab
                )
            }
        }
        .padding(.horizontal, 15)
        .frame(height: 100)
    }
}

fileprivate struct TabItem: View {
    var tint: Color
    var inActiveTint: Color
    var tab: Tab
    @Binding var activeTab: Tab
    
    var body: some View {
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
            activeTab = tab
        }
    }
}
