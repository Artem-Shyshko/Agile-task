//
//  AccountView.swift
//  Master Task
//
//  Created by Artur Korol on 07.09.2023.
//

import SwiftUI
import RealmSwift

struct ProjectsView: View {
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var theme: AppThemeManager
    @StateObject var vm: ProjectsViewModel
    @State var isAlert = false
    @State var isSearchBarHidden: Bool = true
    @State var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                topView()
                if !isSearchBarHidden {
                    SearchableView(searchText: $searchText, isSearchBarHidden: $isSearchBarHidden)
                        .foregroundColor(theme.selectedTheme.textColor)
                }
                accountsList()
                Spacer()
            }
            .modifier(TabViewChildModifier())
            .onAppear {
                vm.savedProjects = vm.projectsRepo.getProjects()
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsView(vm: ProjectsViewModel())
            .environmentObject(UserState())
            .environmentObject(AppThemeManager())
    }
}

private extension ProjectsView {
    func accountsList() -> some View {
        List {
            ForEach(vm.savedProjects, id: \.id) { project in
                ProjectRow(vm: vm, project: project)
                    .foregroundColor(theme.selectedTheme.sectionTextColor)
                    .swipeActions {
                        NavigationLink {
                            NewProjectView(vm: NewProjectViewModel(editedProject: project))
                        } label: {
                            Image("done-checkbox")
                        }
                        .tint(Color.editButtonColor)
                        
                        if !project.isSelected {
                            Button {
                                isAlert = true
                            } label: {
                                Image("trash")
                            }
                            .tint(Color.red)
                        }
                    }
                    .alert("Are you sure you want to delete", isPresented: $isAlert) {
                        Button("Cancel", role: .cancel) {
                            isAlert = false
                        }
                        
                        Button("Delete") {
                            vm.deleteProject(project)
                        }
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme.selectedTheme.sectionColor)
                            .padding(.top, 1)
                    )
            }
            .listRowSeparator(.hidden)
            .scrollContentBackground(.hidden)
        }
        .listRowSpacing(Constants.shared.listRowSpacing)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .padding(.top, 25)
    }
    
    func topView() -> some View {
        HStack {
            Button {
                isSearchBarHidden.toggle()
            } label: {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
            
            Spacer()
            Text("Projects")
                .font(.helveticaBold(size: 16))
                .foregroundStyle(theme.selectedTheme.textColor)
            Spacer()
            
            NavigationLink {
                NewProjectView(vm: NewProjectViewModel())
            } label: {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
    }
}
