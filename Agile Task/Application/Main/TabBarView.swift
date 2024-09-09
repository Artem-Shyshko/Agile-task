//
//  TabBarView.swift
//  Agile Task
//
//  Created by Artur Korol on 08.08.2023.
//

import SwiftUI
import RealmSwift

// MARK: - Enum
enum SettingType {
    case tasksList
    case recordsList
}

enum TaskListNavigationView: Hashable {
    case createTask(editedTask: TaskDTO? = nil),
         completedTasks,
         sorting,
         newCheckBox,
         subscription,
         settings,
         appSettings,
         taskSettings,
         security,
         setPassword,
         more,
         contactUs,
         backup,
         backupDetail(storage: BackupStorage),
         backupList(storage: BackupStorage)
}

enum SecuredNavigationView: Hashable {
    case createRecord(record: RecordDTO? = nil),
         recordInfo(record: RecordDTO),
         purchase,
         sorting,
         settings,
         appSettings,
         taskSettings,
         security,
         more,
         backup,
         backupDetail(storage: BackupStorage),
         backupList(storage: BackupStorage),
         setPassword
}

enum ProjectNavigationView: Hashable {
    case subscription, newProject(editHabit: ProjectDTO? = nil)
}

enum Tab: LocalizedStringResource, Identifiable, CaseIterable {
    case taskList = "Tasks"
    case projects = "Projects"
    case secured = "SecuredTab"
    
    var imageName: String {
        switch self {
        case .taskList: return "tasks"
        case .projects: return "project"
        case .secured: return "Secured"
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
    @State var showAuthViewForRecords: Bool = false
    @State var showPasswordViewForRecords: Bool = false
    @State var reloadRecords: Bool = false
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            TabView(selection: $appState.selectedTab) {
                TaskListView(viewModel: TaskListViewModel(appState: appState), path: $appState.taskListNavigationStack)
                    .tag(Tab.taskList)
                ProjectsView(vm: ProjectsViewModel(appState: appState), path: $appState.projectsNavigationStack)
                    .tag(Tab.projects)
                RecordListView(viewModel: RecordListViewModel(appState: appState), 
                               path: $appState.securedNavigationStack,
                               showPasswordView: $showPasswordViewForRecords,
                               reloadRecords: $reloadRecords)
                    .tag(Tab.secured)
            }
            .overlay(alignment: .bottom) {
                if !appState.isTabBarHidden {
                    customTabItem()
                }
            }
        }
        .fullScreenCover(isPresented: $showAuthViewForRecords, content: {
            SetPasswordView(viewModel: SetPasswordViewModel(appState: appState,
                                                            isFirstSetup: true,
                                                            setPasswordGoal: .records))
        })
        .onChange(of: appState.selectedTab) { newValue in
            appState.taskListNavigationStack = []
            appState.securedNavigationStack = []
            appState.projectsNavigationStack = []
        }
        .onChange(of: showAuthViewForRecords) { newValue in
            if !newValue {
                reloadRecords = true
                
                if defaults.value(forKey: Constants.shared.userPassword) != nil {
                    showPasswordViewForRecords = true
                }
            }
        }
        .onOpenURL { incomingURL in
            guard let incomeState = AppHelper.shared.handleIncomingURL(incomingURL) else { return }
            
            switch incomeState {
            case .widgetNewTask:
                appState.selectedTab = .taskList
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if appState.taskListNavigationStack.isEmpty {
                        appState.taskListNavigationStack.append(.createTask())
                    }
                }
            case .dropbox:
                break
            }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(showAuthViewForRecords: false)
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
                    appState.taskListNavigationStack = []
                case .projects:
                    appState.projectsNavigationStack = []
                case .secured:
                    if defaults.value(forKey: Constants.shared.userPassword) == nil {
                        showAuthViewForRecords = true
                    } else {
                        showPasswordViewForRecords = true
                    }
                    appState.securedNavigationStack = []
                }
            }
        }
    }
}
