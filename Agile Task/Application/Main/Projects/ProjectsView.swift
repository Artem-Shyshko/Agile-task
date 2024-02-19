//
//  AccountView.swift
//  Agile Task
//
//  Created by Artur Korol on 07.09.2023.
//

import SwiftUI
import RealmSwift

struct ProjectsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Environment(\.colorScheme) var colorScheme

    @StateObject var vm: ProjectsViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                navigationBar()
                searchView()
                accountsList()
                Spacer()
            }
            .modifier(TabViewChildModifier())
            .onAppear {
                vm.savedProjects = vm.projectsRepo.getProjects()
            }
            .navigationDestination(isPresented: $vm.showNewProjectView) {
                NewProjectView(vm: NewProjectViewModel())
            }
            .navigationDestination(isPresented: $vm.showSubscriptionView) {
                SettingsSubscriptionView()
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsView(vm: ProjectsViewModel())
            .environmentObject(ThemeManager())
    }
}

private extension ProjectsView {
    
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: magnifyingGlassButton(),
            header: NavigationTitle("Projects"),
            rightItem: rightNavigationButton()
        )
    }
    
    @ViewBuilder
    func searchView() -> some View {
        if !vm.isSearchBarHidden {
            SearchableView(searchText: $vm.searchText, isSearchBarHidden: $vm.isSearchBarHidden)
                .foregroundColor(themeManager.theme.textColor(colorScheme))
        }
    }
    
    func accountsList() -> some View {
        List {
            ForEach(vm.savedProjects, id: \.id) { project in
                ProjectRow(vm: vm, project: project)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(themeManager.theme.sectionColor(colorScheme))
                    )
            }
            .listRowSeparator(.hidden)
        }
        .listRowSpacing(Constants.shared.listRowSpacing)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
    }
    
    func magnifyingGlassButton() -> some View {
        MagnifyingGlassButton {
            vm.isSearchBarHidden.toggle()
        }
    }
    
    func rightNavigationButton() -> some View {
        Button {
            guard purchaseManager.canCreateProject() else {
                vm.showSubscriptionView = true
                return
            }
            vm.showNewProjectView = true
        } label: {
            Image("Add")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
        }
    }
}
