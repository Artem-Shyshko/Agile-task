//
//  AccountView.swift
//  Master Task
//
//  Created by Artur Korol on 07.09.2023.
//

import SwiftUI
import RealmSwift

struct ProjectsView: View {
    @EnvironmentObject var theme: AppThemeManager
    @StateObject var vm: ProjectsViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                if !vm.isSearchBarHidden {
                    SearchableView(searchText: $vm.searchText, isSearchBarHidden: $vm.isSearchBarHidden)
                        .foregroundColor(theme.selectedTheme.textColor)
                }
                accountsList()
                Spacer()
            }
            .padding(.top, 25)
            .modifier(TabViewChildModifier())
            .onAppear {
                vm.savedProjects = vm.projectsRepo.getProjects()
            }
            .toolbar {
                toolBarView()
            }
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $vm.showNewProjectView) {
                NewProjectView(vm: NewProjectViewModel())
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsView(vm: ProjectsViewModel())
            .environmentObject(AppThemeManager())
    }
}

private extension ProjectsView {
    func accountsList() -> some View {
        List {
            ForEach(vm.savedProjects, id: \.id) { project in
                ProjectRow(vm: vm, project: project)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme.selectedTheme.sectionColor)
                    )
            }
        }
        .listRowSpacing(Constants.shared.listRowSpacing)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
    }
    
    @ToolbarContentBuilder
    func toolBarView() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                vm.isSearchBarHidden.toggle()
            } label: {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                vm.showNewProjectView = true
            } label: {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
        }
    }
}
