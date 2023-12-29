//
//  SortingView.swift
//  Master Task
//
//  Created by Artur Korol on 31.08.2023.
//

import SwiftUI
import RealmSwift

struct SortingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: SortingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.shared.listRowSpacing) {
            ForEach(TaskSorting.allCases, id: \.self) { option in
                Button {
                    viewModel.editValue(with: option)
                } label: {
                    HStack {
                        if viewModel.settings.taskSorting == option {
                            checkMark
                        }
                        
                        Text(option.rawValue)
                    }
                }
                .modifier(SectionStyle())
            }
            Spacer()
        }
        .padding(.top, 20)
        .navigationTitle("Sorting")
        .toolbar(.visible, for: .navigationBar)
        .modifier(TabViewChildModifier())
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton {
                    dismiss.callAsFunction()
                }
            }
        }
        .onChange(of: viewModel.settings) { _ in
          viewModel.settingsRepository.save(viewModel.settings)
        }
    }
}

// MARK: - Private Views

private extension SortingView {
    var checkMark: some View {
        Image(systemName: "checkmark")
            .foregroundColor(.black)
    }
}

// MARK: - SortingView_Previews

struct SortingView_Previews: PreviewProvider {
    static var previews: some View {
        SortingView(viewModel: SortingViewModel())
    }
}
