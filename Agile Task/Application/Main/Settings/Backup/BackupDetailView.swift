//
//  BackupDetailView.swift
//  Agile Money
//
//  Created by Artur Korol on 20.05.2024.
//

import SwiftUI

enum BackupStorage {
    case locally, iCloud, dropbox
}

struct BackupDetailView: View {
    @StateObject var viewModel: BackupViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @State private var authorizationStatus = ""
    var backupStorage: BackupStorage
    
    var body: some View {
        VStack(spacing: Constants.shared.viewSectionSpacing) {
            navigationBar()
            if backupStorage == .locally {
                Text("backup_delete_app")
                    .font(.helveticaRegular(size: 16))
                    .foregroundStyle(themeManager.theme.textColor(colorScheme))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack(spacing: Constants.shared.listRowSpacing) {
                if backupStorage == .dropbox {
                    dropboxAuthorization()
                }
                
                if backupStorage == .dropbox && viewModel.isAuthorized || backupStorage != .dropbox {
                    createBackup()
                    downloadBackup()
                }
                Spacer()
            }
        }
        .modifier(TabViewChildModifier())
        .alert(viewModel.alertTitle, isPresented: $viewModel.isShowingAlert) {
            Button {} label: {
                Text("OK")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dropboxAuthSuccess), perform: { notification in
            viewModel.getUserAuth()
        })
        .onReceive(NotificationCenter.default.publisher(for: .dropboxAuthFailed), perform: { notification in
            if let message = notification.object as? String {
                viewModel.alertTitle = message
            } else {
                viewModel.alertTitle  = "Authorization failed."
            }
            viewModel.isShowingAlert = true
            viewModel.getUserAuth()
        })
        .onAppear {
            viewModel.getUserAuth()
        }
    }
}

private extension BackupDetailView {
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
    
    func dropboxAuthorization() -> some View {
        SectionButton(title: viewModel.isAuthorized ? "Disconnect Dropbox" : "Connect to Dropbox") {
            viewModel.isAuthorized ? viewModel.logout() : viewModel.authorizeToDropbox()
        }
    }
    
    func createBackup() -> some View {
        SectionButton(title: "create_backup") {
            switch backupStorage {
            case .locally:
                viewModel.saveBackup(toICloud: false)
            case .iCloud:
                viewModel.saveBackup(toICloud: true)
            case .dropbox:
                viewModel.saveToDropbox()
            }
        }
    }
    
    func downloadBackup() -> some View {
        SectionLinkButton(
            title: "restore_backup",
            value: TasksNavigation.backupList(
                storage: backupStorage
            ),
            isArrow: true
        )
    }
}

#Preview {
    BackupDetailView(viewModel: BackupViewModel(appState: AppState()), backupStorage: .dropbox)
        .environmentObject(ThemeManager())
}
