//
//  BackupListView.swift
//  Agile Money
//
//  Created by Artur Korol on 28.05.2024.
//

import SwiftUI

struct BackupListView: View {
    
    // MARK: - Properties
    
    @StateObject var viewModel: BackupViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @Environment(\.colorScheme) private var colorScheme
    @State private var authorizationStatus = ""
    var backupStorage: BackupStorage
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Constants.shared.viewSectionSpacing) {
            navigationBar()
            list()
        }
        .modifier(TabViewChildModifier())
        .alert(viewModel.alertTitle, isPresented: $viewModel.isShowingAlert) {
            Button {} label: {
                Text("OK")
            }
        }
        .onAppear {
            if backupStorage != .dropbox {
                viewModel.getBackups(fromICloud: backupStorage == .locally ? false : true)
            } else {
                viewModel.listFilesInDirectory()
            }
        }
    }
}

// MARK: - Private methods

private extension BackupListView {
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: backButton(),
            header: NavigationTitle("backup_title"),
            rightItem: EmptyView()
        )
    }
    
    func backButton() -> some View {
        backButton {
            dismiss.callAsFunction()
        }
    }
    
    func list() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            List {
                ForEach(viewModel.savedBackups, id: \.self) { backup in
                    Button {
                        switch backupStorage {
                        case .locally:
                            viewModel.restoreBackup(named: backup, fromICloud: false)
                        case .iCloud:
                            viewModel.restoreBackup(named: backup, fromICloud: true)
                        case .dropbox:
                            viewModel.restoreDropboxBackup(name: backup)
                        }
                    } label: {
                        Text(backup)
                    }
                    .foregroundColor(themeManager.theme.sectionTextColor(colorScheme))
                    .padding(.horizontal, Constants.shared.listRowHorizontalPadding)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(themeManager.theme.sectionColor(colorScheme))
                    )
                }
            }
            .listRowSpacing(Constants.shared.listRowSpacing)
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .padding(.bottom, 5)
        }
    }
}

// MARK: - Preview

#Preview {
    BackupListView(viewModel: BackupViewModel(appState: AppState()), backupStorage: .dropbox)
}
