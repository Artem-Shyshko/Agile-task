//
//  TasksSettingsView.swift
//  Agile Task
//
//  Created by USER on 30.08.2024.
//

import SwiftUI

struct TasksSettingsView: View {
    @StateObject var viewModel: TasksSettingsViewModel
    @EnvironmentObject var lnManager: LocalNotificationManager
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        VStack(spacing: Constants.shared.viewSectionSpacing) {
            navigationBar()
            ScrollView {
                VStack(alignment: .leading, spacing: Constants.shared.listRowSpacing) {
                    newTaskFeaturesSection()
                    defaultSortingSection()
                    newTasksSection()
                    completedTaskSection()
                    сompletionСircleView()
                    hapticFeedbackButton()
                    deleteAllTasksButton()
                    Spacer()
                }
            }
            .padding(.bottom, 5)
        }
        .modifier(TabViewChildModifier())
        .onChange(of: viewModel.settings) { _ in
            viewModel.appState.settingsRepository!.save(viewModel.settings)
            appState.settings = viewModel.settings
        }
        .alert("Are you sure you want to delete all tasks?", isPresented: $viewModel.isShowingAlert) {
            Button("Cancel", role: .cancel) {}
            
            Button("Delete") {
                viewModel.deleteAllTasks()
            }
        }
    }
}

// MARK: - Private Views

private extension TasksSettingsView {
    
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: backButton(),
            header: NavigationTitle("Settings"),
            rightItem: EmptyView()
        )
    }
    
    func backButton() -> some View {
        backButton {
            dismiss.callAsFunction()
        }
    }
    
    func newTasksSection() -> some View {
        CustomPickerView(
            title: "New tasks",
            options: AddingNewTask.allCases,
            selection: $viewModel.settings.addNewTaskIn
        )
        .modifier(SectionStyle())
    }
    
    func defaultSortingSection() -> some View {
        CustomPickerView(
            title: "Default screen view",
            options: TaskDateSorting.allCases,
            selection: $viewModel.settings.taskDateSorting
        )
        .modifier(SectionStyle())
    }
    
    func completedTaskSection() -> some View {
        CustomPickerView(
            title: "Completed tasks",
            options: CompletedTask.allCases,
            selection: $viewModel.settings.completedTask
        )
        .modifier(SectionStyle())
    }
    
    func newTaskFeaturesSection() -> some View {
        CustomPickerView(
            title: "New task features",
            options: TaskType.allCases,
            selection: $viewModel.settings.newTaskFeature
        )
        .modifier(SectionStyle())
    }
    
    func сompletionСircleView() -> some View {
        Button {
            viewModel.сompletionСircleAction()
        } label: {
            HStack {
                if viewModel.settings.сompletionСircle {
                    checkMark
                }
                
                Text("settings_сompletion_сircle")
            }
        }
        .padding(.vertical, 10)
        .modifier(SectionStyle())
    }
    
    func hapticFeedbackButton() -> some View {
        Button {
            viewModel.turnOnHapticFeedback()
        } label: {
            HStack {
                if viewModel.settings.hapticFeedback {
                    checkMark
                }
                
                Text("settings_haptic_feedback")
            }
        }
        .padding(.vertical, 10)
        .modifier(SectionStyle())
    }
    
    func deleteAllTasksButton() -> some View {
        Button {
            viewModel.isShowingAlert = true
        } label: {
            Text("Delete all tasks")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 10)
        .modifier(SectionStyle())
    }
    
    var checkMark: some View {
        Image("Check")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 13, height: 13)
    }
}

// MARK: - SettingsTaskView_Previews

struct TasksSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TasksSettingsView(viewModel: TasksSettingsViewModel(appState: AppState()))
    }
}

