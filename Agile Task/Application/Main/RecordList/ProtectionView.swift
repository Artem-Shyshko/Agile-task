//
//  ProtectionView.swift
//  Agile Task
//
//  Created by Artur Korol on 04.10.2024.
//

import SwiftUI

struct ProtectionView: View {
    // MARK: - Properties
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @Binding var path: [SecuredNavigation]
    @Binding var showPasswordViewForRecords: Bool
    @Binding var reloadRecords: Bool
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 30) {
                Text("record_list_protection")
                    .font(.helveticaBold(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(themeManager.theme.textColor(colorScheme))
                
                Image(.lock)
                    .resizable()
                    .scaledToFit()
                    .frame(size: 50)
                
                Button {
                    path.append(.recordsList)
                } label: {
                    Text("record_list_view_section")
                        .font(.helveticaRegular(size: 16))
                        .foregroundStyle(themeManager.theme.sectionTextColor(colorScheme))
                }
                .padding(.horizontal, 60)
                .padding(.vertical, 13)
                .background(themeManager.theme.sectionColor(colorScheme))
                .clipShape(.rect(cornerRadius: 4))
            }
            .modifier(TabViewChildModifier())
            .navigationDestination(for: SecuredNavigation.self) { views in
                navigate(for: views, appState: appState)
            }
        }
    }
}

private extension ProtectionView {
    @MainActor
    func navigate(for view: SecuredNavigation, appState: AppState) -> some View {
        switch view {
        case .createRecord(let record):
            return AnyView(NewRecordView(viewModel: NewRecordViewModel(appState: appState, editedRecord: record)))
        case .purchase:
            return AnyView(SubscriptionView())
        case .sorting:
            return AnyView(SortingView(viewModel: SortingViewModel(appState: appState, sortingState: .records)))
        case .recordInfo(record: let record):
            return AnyView(RecordInfoView(viewModel: RecordInfoViewModel(appState: appState, record: record)))
        case .settings:
            return AnyView(SettingsView(viewModel: SettingsViewModel(settingType: .recordsList)))
        case .appSettings:
            return AnyView(AppSettingsView(viewModel: AppSettingsViewModel(appState: appState)))
        case .taskSettings:
            return AnyView(TasksSettingsView(viewModel: TasksSettingsViewModel(appState: appState)))
        case .security:
            return AnyView(SecurityView(viewModel: SecurityViewModel(appState: appState)))
        case .more:
            return AnyView(MoreOurAppsView())
        case .backup:
            return AnyView(BackupView(viewModel: BackupViewModel(appState: appState)))
        case .backupDetail(storage: let storage):
            return AnyView(BackupDetailView(viewModel: BackupViewModel(appState: appState), backupStorage: storage))
        case .backupList(storage: let storage):
            return AnyView(BackupListView(viewModel: BackupViewModel(appState: appState), backupStorage: storage))
        case .setPassword:
            return AnyView(SetPasswordView(viewModel: SetPasswordViewModel(appState: appState,
                                                                           isFirstSetup: false,
                                                                           setPasswordGoal: .records)))
        case .recordsList:
            return AnyView(RecordsView(viewModel: RecordListViewModel(appState: appState),
                                       path: $appState.securedNavigationStack,
                                       showPasswordView: $showPasswordViewForRecords,
                                       reloadRecords: $reloadRecords
                                      ))
        }
    }
}

#Preview {
    ProtectionView(path: .constant([]), showPasswordViewForRecords: .constant(false), reloadRecords: .constant(false))
}
