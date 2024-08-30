//
//  BackupView.swift
//  Agile Money
//
//  Created by Artur Korol on 16.05.2024.
//

import SwiftUI

struct BackupView: View {
    @StateObject var viewModel: BackupViewModel
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview
    
    var body: some View {
        VStack(spacing: Constants.shared.viewSectionSpacing) {
            navigationBar()
            
            VStack(spacing: Constants.shared.listRowSpacing) {
                filesBackup()
//                iCloudBackup()
//                dropboxBackup()
                Spacer()
            }
        }
        .modifier(TabViewChildModifier())
        .alert(viewModel.alertTitle, isPresented: $viewModel.isShowingAlert) {
            Button {} label: {
                Text("OK")
            }
        }
    }
}

// MARK: - Private views

private extension BackupView {
    
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
    
    func filesBackup() -> some View {
        SectionLinkButton(title: "files_backup", value: TaskListNavigationView.backupDetail(storage: .locally))
    }
    
    @ViewBuilder
    func iCloudBackup() -> some View {
        SectionLinkButton(title: "iCloud_backup", value: TaskListNavigationView.backupDetail(storage: .iCloud))
    }
    
    func dropboxBackup() -> some View {
        SectionLinkButton(title: "dropbox_backup", value: TaskListNavigationView.backupDetail(storage: .dropbox))
    }
}

// MARK: - Preview

#Preview {
    BackupView(viewModel: BackupViewModel(appState: AppState()))
}

struct SectionButton: View {
    var title: LocalizedStringKey
    var action: ()->()
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
        }
        .modifier(SectionStyle())

    }
}

struct SectionLinkButton: View {
    var title: LocalizedStringKey
    var value: any Hashable
    
    var body: some View {
        NavigationLink(value: value, label: {
            Text(title)
        })
        .modifier(SectionStyle())
    }
}
