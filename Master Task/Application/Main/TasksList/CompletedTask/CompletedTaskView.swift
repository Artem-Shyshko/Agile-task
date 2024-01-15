//
//  CompletedTaskView.swift
//  Master Task
//
//  Created by Artur Korol on 18.10.2023.
//

import SwiftUI
import RealmSwift

struct CompletedTaskView: View {
    @EnvironmentObject var theme: AppThemeManager
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: CompletedTaskViewModel
    
    var body: some View {
        VStack {
            underTopBar()
            List {
                ForEach($viewModel.completedTasks, id: \.id) { task in
                TaskRow(viewModel: TaskListViewModel(), task: task)
                        .listRowBackground(
                          RoundedRectangle(cornerRadius: 4)
                            .fill(Color(task.colorName.wrappedValue))
                        )
                        .onChange(of: task.wrappedValue) { _ in
                            viewModel.completedTasks = viewModel.taskRepository.getTaskList().filter { $0.isCompleted }
                        }
              }
              .listRowSeparator(.hidden)
            }
            .listRowSpacing(Constants.shared.listRowSpacing)
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            
            Spacer()
        }
        .modifier(TabViewChildModifier())
        .navigationTitle("Completed tasks")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton {
                    dismiss.callAsFunction()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    NewTaskView(viewModel: NewTaskViewModel(), taskList: viewModel.completedTasks)
                } label: {
                    Image("plus")
                }
            }
        }
        .alert("Are you sure you want to delete all tasks?", isPresented: $viewModel.showDeleteAlert) {
            Button {
                viewModel.showDeleteAlert = false
            } label: {
                Text("Cancel")
            }
            
            Button {
                viewModel.deleteAll()
            } label: {
                Text("Delete")
            }
        }
        .alert("Are you sure you want to restore all tasks?", isPresented: $viewModel.showRestoreAlert) {
            Button {
                viewModel.showRestoreAlert = false
            } label: {
                Text("Cancel")
            }
            
            Button {
                viewModel.completedTasks.forEach { task in
                    viewModel.updateTask(task)
                }
            } label: {
                Text("Restore")
            }
        }
    }
}

// MARK: - Private Views

private extension CompletedTaskView {
    func underTopBar() -> some View {
        HStack {
            Button {
                viewModel.showRestoreAlert = true
            } label: {
                Text("Restore all")
            }
            
            Spacer()
            
            Button {
                viewModel.showDeleteAlert = true
            } label: {
                Text("Delete all")
            }
        }
        .padding(.horizontal, 15)
        .padding(.top, 20)
    }
}

// MARK: - Preview

#Preview {
    CompletedTaskView(viewModel: CompletedTaskViewModel())
        .environmentObject(AppThemeManager())
}
