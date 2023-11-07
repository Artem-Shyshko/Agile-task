//
//  SortingView.swift
//  Master Task
//
//  Created by Artur Korol on 31.08.2023.
//

import SwiftUI
import RealmSwift

struct SortingView: View {
    @EnvironmentObject var userState: UserState
    @ObservedResults(TaskSettings.self) var savedSettings
    @StateObject var viewModel: SortingViewModel
    
    var settings: TaskSettings {
        savedSettings.first!
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(TaskSorting.allCases, id: \.self) { option in
                Button {
                    viewModel.taskSorting = option
                    viewModel.editValue(for: savedSettings, with: option)
                } label: {
                    HStack {
                        if viewModel.taskSorting == option {
                            checkMark
                        }
                        
                        Text(option.rawValue)
                    }
                }
                .buttonStyle(SettingsButtonStyle())
            }
            Spacer()
        }
        .padding(.top, 20)
        .navigationTitle("Sorting")
        .toolbar(.visible, for: .navigationBar)
        .modifier(TabViewChildModifier())
        .onAppear {
            viewModel.taskSorting = settings.taskSorting
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
            .environmentObject(UserState())
    }
}
