//
//  SortingView.swift
//  Agile Task
//
//  Created by Artur Korol on 31.08.2023.
//

import SwiftUI
import RealmSwift

struct SortingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: SortingViewModel
    
    var body: some View {
        VStack(spacing: Constants.shared.viewSectionSpacing) {
            navigationBar()
            sortingOptions()
        }
        .modifier(TabViewChildModifier())
        .onChange(of: viewModel.settings) { _ in
            viewModel.appState.settingsRepository!.save(viewModel.settings)
        }
    }
}

// MARK: - Private Views

private extension SortingView {
    
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: backButton(),
            header: NavigationTitle("tasks_view_sorting"),
            rightItem: EmptyView()
        )
    }
    
    func sortingOptions() -> some View {
        VStack(alignment: .leading, spacing: Constants.shared.listRowSpacing) {
            ForEach(TaskSorting.allCases, id: \.self) { option in
                Button {
                    viewModel.editValue(with: option)
                } label: {
                    HStack {
                        if viewModel.settings.taskSorting == option {
                            checkMark
                        }
                        
                        Text(LocalizedStringKey(option.description))
                    }
                }
                .modifier(SectionStyle())
            }
            Spacer()
        }
    }
    
    func backButton() -> some View {
        backButton {
            dismiss.callAsFunction()
        }
    }
    
    var checkMark: some View {
        Image(systemName: "checkmark")
            .foregroundColor(.black)
    }
}

// MARK: - SortingView_Previews

struct SortingView_Previews: PreviewProvider {
    static var previews: some View {
        SortingView(viewModel: SortingViewModel(appState: AppState()))
    }
}
