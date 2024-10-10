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

    @StateObject var viewModel: ProjectsViewModel
    @Binding var path: [ProjectNavigation]
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: Constants.shared.viewSectionSpacing) {
                navigationBar()
                searchView()
                accountsList()
                Spacer()
            }
            .modifier(TabViewChildModifier())
            .onAppear {
                viewModel.savedProjects = viewModel.appState.projectRepository!.getProjects()
            }
            .navigationDestination(for: ProjectNavigation.self) { view in
                switch view {
                    case .newProject(let project):
                    NewProjectView(vm: NewProjectViewModel(appState: viewModel.appState, editedProject: project))
                case .subscription:
                    SubscriptionView()
                }
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsView(viewModel: ProjectsViewModel(appState: AppState()), path: .constant([]))
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
        .overlay(alignment: .trailing) {
            TipView(title: "tip_add_new_project", arrowEdge: .trailing)
        }
    }
    
    @ViewBuilder
    func searchView() -> some View {
        if !viewModel.isSearchBarHidden {
            SearchableView(searchText: $viewModel.searchText, isSearchBarHidden: $viewModel.isSearchBarHidden)
                .foregroundColor(themeManager.theme.textColor(colorScheme))
        }
    }
    
    func accountsList() -> some View {
        List {
            ForEach(viewModel.savedProjects, id: \.id) { project in
                ProjectRow(vm: viewModel, project: project, path: $path)
            }
            .listRowSeparator(.hidden)
        }
        .listRowSpacing(Constants.shared.listRowSpacing)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .overlay(alignment: .top) {
            TipView(title: "tip_swipe_left_project", arrowEdge: .top)
        }
    }
    
    func magnifyingGlassButton() -> some View {
        MagnifyingGlassButton {
            viewModel.isSearchBarHidden.toggle()
        }
    }
    
    func rightNavigationButton() -> some View {
        Button {
            path.append(.newProject())
        } label: {
            Image(.add)
                .resizable()
                .scaledToFit()
                .frame(size: Constants.shared.imagesSize)
        }
    }
}
