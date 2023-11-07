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
    @StateObject var viewModel: CompletedTaskViewModel
    @ObservedResults(Account.self, where: ( { $0.isSelected } )) var selectedSavedAccount
    
    private var filteredTaskByAccount: [TaskObject] {
        guard let tasksList = selectedSavedAccount.first?.tasksList else {
            return []
        }
        
        let completedTasks: [TaskObject] = tasksList.filter{$0.isCompleted}
        
        if !viewModel.searchText.isEmpty {
            return completedTasks
                .filter({$0.title.contains(viewModel.searchText)})
        } else {
            return completedTasks
        }
    }
    
    var body: some View {
        VStack {
            topView()
            underTopBar()
            List {
                TaskList(taskArray: .constant(filteredTaskByAccount))
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .padding(.top, 20)
            .listRowSpacing(MasterTaskConstants.shared.listRowSpacing)
            
            Spacer()
        }
        .modifier(TabViewChildModifier())
    }
}

private extension CompletedTaskView {
    func topView() -> some View {
        HStack {
            Button {
                viewModel.isSearchBarHidden.toggle()
            } label: {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
            }
            Spacer()
            Text("Completed tasks")
                .font(.helveticaBold(size: 16))
                .foregroundStyle(theme.selectedTheme.textColor)
            Spacer()
            
            NavigationLink(value: TaskListNavigationView.createTask) {
                Image(systemName: "plus")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
    }
    
    func underTopBar() -> some View {
        VStack {
            if viewModel.isSearchBarHidden {
                HStack {
                    Button {
                        filteredTaskByAccount.forEach { task in
                            viewModel.updateTask(task)
                        }
                    } label: {
                        Text("Restore all")
                    }
                    
                    Spacer()
                    
                    Button {
                        filteredTaskByAccount.forEach { task in
                            viewModel.deleteTask(task)
                        }
                    } label: {
                        Text("Delete all")
                    }
                }
                .padding(.horizontal, 15)
                .padding(.top, 20)
            } else {
                SearchableView(searchText: $viewModel.searchText, isSearchBarHidden: $viewModel.isSearchBarHidden)
                    .foregroundColor(theme.selectedTheme.textColor)
            }
        }
    }
}

#Preview {
    CompletedTaskView(viewModel: CompletedTaskViewModel())
        .environmentObject(AppThemeManager())
}
