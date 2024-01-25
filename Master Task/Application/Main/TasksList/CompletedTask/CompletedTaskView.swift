//
//  CompletedTaskView.swift
//  Master Task
//
//  Created by Artur Korol on 18.10.2023.
//

import SwiftUI
import RealmSwift

struct CompletedTaskView: View {
    @StateObject var viewModel: TaskListViewModel
    @EnvironmentObject var theme: AppThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false
    @State private var showRestoreAlert = false
    
    var body: some View {
        VStack {
            navigationBar()
            underTopBar()
            completedTasksList()
            Spacer()
        }
        .modifier(TabViewChildModifier())
        .alert("Are you sure you want to delete all tasks?", isPresented: $showDeleteAlert) {
            Button {
                showDeleteAlert = false
            } label: {
                Text("Cancel")
            }
            
            Button {
                viewModel.deleteAll()
            } label: {
                Text("Delete")
            }
        }
        .alert("Are you sure you want to restore all tasks?", isPresented: $showRestoreAlert) {
            Button {
                showRestoreAlert = false
            } label: {
                Text("Cancel")
            }
            
            Button {
                viewModel.completedTasks.forEach { task in
                    viewModel.updateTaskCompletion(task)
                }
            } label: {
                Text("Restore")
            }
        }
        .onAppear {
            viewModel.completedTasks = viewModel.taskRepository.getTaskList().filter { $0.isCompleted }
        }
    }
}

// MARK: - Private Views

private extension CompletedTaskView {
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: backButton(),
            header: NavigationTitle("Completed tasks"),
            rightItem: EmptyView()
        )
    }
    
    func backButton() -> some View {
        backButton {
            dismiss.callAsFunction()
        }
    }
    
    func underTopBar() -> some View {
        HStack {
            Button {
                showRestoreAlert = true
            } label: {
                Text("Restore all")
            }
            
            Spacer()
            
            Button {
                showDeleteAlert = true
            } label: {
                Text("Delete all")
            }
        }
        .padding(.horizontal, 15)
    }
    
    func completedTasksList() -> some View {
        List {
            ForEach($viewModel.completedTasks, id: \.id) { task in
                TaskRow(viewModel: viewModel, task: task)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(task.colorName.wrappedValue))
                    )
            }
            .listRowSeparator(.hidden)
        }
        .listRowSpacing(Constants.shared.listRowSpacing)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .padding(.bottom, 40)
        
    }
}

// MARK: - Preview

#Preview {
    CompletedTaskView(viewModel: TaskListViewModel())
        .environmentObject(AppThemeManager())
}
