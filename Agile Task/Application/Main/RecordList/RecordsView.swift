//
//  RecordListView.swift
//  Agile Task
//
//  Created by USER on 03.04.2024.
//

import SwiftUI
import StoreKit

struct RecordsView: View {
    // MARK: - Properties
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Environment(\.requestReview) var requestReview
    
    @StateObject var viewModel: RecordListViewModel
    @Binding var path: [SecuredNavigation]
    @Binding var showPasswordView: Bool
    @Binding var reloadRecords: Bool
    @State var showProtect = true
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: Constants.shared.viewSectionSpacing) {
                navigationBar()
                searchView()
                
                VStack(spacing: 3) {
                    recordsList()
                    Spacer()
                }
            }
            .onAppear {
                viewModel.mainLoad()
                showProtect = true
            }
            .onChange(of: reloadRecords) { newValue in
                if newValue {
                    viewModel.mainLoad()
                }
            }
            .onReceive(authManager.$state) { newValue in
                if newValue == .loggedIn {
                    showPasswordView = false
                    viewModel.mainLoad()
                }
            }
            .padding(.bottom, 10)
            .modifier(TabViewChildModifier())
            .onChange(of: scenePhase) { newValue in
                if newValue == .active, authManager.state == .loggedIn {
                    viewModel.mainLoad()
                }
            }
            .navigationDestination(for: SecuredNavigation.self) { views in
                switch views {
                case .createRecord(let record):
                    NewRecordView(viewModel: NewRecordViewModel(appState: appState, editedRecord: record))
                case .purchase:
                    SubscriptionView()
                case .sorting:
                    SortingView(viewModel: SortingViewModel(appState: appState, sortingState: .records))
                case .recordInfo(record: let record):
                    RecordInfoView(viewModel: RecordInfoViewModel(appState: appState, record: record))
                case .settings:
                    SettingsView(viewModel: SettingsViewModel(settingType: .recordsList))
                case .appSettings:
                    AppSettingsView(viewModel: AppSettingsViewModel(appState: appState))
                case .taskSettings:
                    TasksSettingsView(viewModel: TasksSettingsViewModel(appState: appState))
                case .security:
                    SecurityView(viewModel: SecurityViewModel(appState: appState))
                case .more:
                    MoreOurAppsView()
                case .backup:
                    BackupView(viewModel: BackupViewModel(appState: appState))
                case .backupDetail(storage: let storage):
                    BackupDetailView(viewModel: BackupViewModel(appState: appState), backupStorage: storage)
                case .backupList(storage: let storage):
                    BackupListView(viewModel: BackupViewModel(appState: appState), backupStorage: storage)
                case .setPassword:
                    SetPasswordView(viewModel: SetPasswordViewModel(appState: appState,
                                                                    isFirstSetup: false,
                                                                    setPasswordGoal: .records))
                }
            }
            .alert(LocalizedStringKey("data_is_copied"), isPresented: $viewModel.showCopyAlert) {
                Button("alert_ok") {
                    viewModel.showCopyAlert = false
                }
            }
            .overlay {
                if showPasswordView {
                    if showProtect {
                        protectionView()
                    } else {
                        AuthenticationView(viewModel: AuthenticationViewModel(appState: appState), isShowing: $showPasswordView,
                                 recordProtect: viewModel.recordsSecurity)
                    }
                }
            }
        }
    }
}

// MARK: - Private Views
private extension RecordsView {
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: navigationBarLeftItem(),
            header: NavigationTitle(""),
            rightItem: navigationBarRightItem()
        )
    }
    
    func navigationBarLeftItem() -> some View {
        Menu {
            Group {
                ForEach(RecordListMenu.allCases, id: \.self) { option in
                    Button(LocalizedStringKey(option.rawValue)) {
                        switch option {
                        case .search:
                            viewModel.isSearchBarHidden.toggle()
                            viewModel.searchText.removeAll()
                        case .sorting:
                            path.append(.sorting)
                        case .settings:
                            path.append(.settings)
                        }
                    }
                }
            }
        } label: {
            Image(.menu)
                .resizable()
                .scaledToFit()
                .frame(size: Constants.shared.imagesSize)
        }
    }
    
    func navigationBarRightItem() -> some View {
        NavigationLink(value: SecuredNavigation.createRecord(record: nil))
        {
            Image(.add)
                .resizable()
                .scaledToFit()
                .frame(size: Constants.shared.imagesSize)
        }
    }
    
    @ViewBuilder
    func searchView() -> some View {
        if !viewModel.isSearchBarHidden {
            SearchableView(searchText: $viewModel.searchText,
                           isSearchBarHidden: $viewModel.isSearchBarHidden)
            .foregroundColor(themeManager.theme.textColor(colorScheme))
        }
    }
    
    func recordsList() -> some View {
        List {
            ForEach(viewModel.savedRecords, id: \.id) { record in
                RecordRow(vm: viewModel, path: $path, record: record)
                    .moveDisabled(viewModel.settings.sortingType != .manualy)
            }
            .onMove(perform: viewModel.move)
            .listRowSeparator(.hidden)
        }
        .listRowSpacing(Constants.shared.listRowSpacing)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
    }
    
    @ViewBuilder
    func infoButton() -> some View {
        HStack(alignment: .center, spacing: 0) {
            Button {
                viewModel.isShowingInfoView.toggle()
            } label: {
                Image(.info)
                    .resizable()
                    .scaledToFit()
                    .frame(size: Constants.shared.imagesSize)
            }
            .buttonStyle(.borderless)
            .padding(.leading, 5)
            
            if viewModel.isShowingInfoView {
                swipeView()
            }
        }
        .padding(.leading, 23)
        .frame(height: 60)
        .padding(.bottom, 5)
    }
    
    @ViewBuilder
    func swipeView() -> some View {
        let arrowScale: CGFloat = 20
        
        HStack {
            Button {
                if viewModel.tipIndex == 0 {
                    viewModel.tipIndex = viewModel.tipsArray.count - 1
                } else {
                    viewModel.tipIndex -= 1
                }
            } label: {
                Image(.arrowLeft)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: arrowScale)
            }
            
            Spacer()
            Text(viewModel.tipsArray[viewModel.tipIndex])
                .font(.helveticaRegular(size: 14))
                .multilineTextAlignment(.center)
            Spacer()
            Button {
                if viewModel.tipIndex == viewModel.tipsArray.count - 1 {
                    viewModel.tipIndex = 0
                } else {
                    viewModel.tipIndex += 1
                }
            } label: {
                Image(.arrowRight)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: arrowScale)
                    .foregroundColor(themeManager.theme.sectionTextColor(colorScheme))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 5)
        .foregroundStyle(themeManager.theme.sectionTextColor(colorScheme))
        .background(themeManager.theme.sectionColor(colorScheme))
        .cornerRadius(5)
        .padding(.horizontal, 5)
    }
    
    func protectionView() -> some View {
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
                showPasswordView = true
                showProtect = false
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
    }
}
