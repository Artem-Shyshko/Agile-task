//
//  RecordListViewModel.swift
//  Agile Task
//
//  Created by USER on 03.04.2024.
//

import SwiftUI
import RealmSwift
import Combine

enum RecordListMenu: String, CaseIterable {
    case search = "search_title"
    case sorting = "tasks_view_sorting"
    case settings = "Settings"
}

final class RecordListViewModel: ObservableObject {
    // MARK: - Published
    @Published var isSearchBarHidden: Bool = true
    @Published var searchText: String = ""
    @Published var savedRecords: [RecordDTO] = []
    @Published var showNewRecordView = false
    @Published var selectedRecord: RecordDTO? = nil
    @Published var showCopyAlert = false
    @Published var isShowingInfoView = false
    @Published var tipIndex = 0
    @Published var isShowAutoFill: Bool = true
    @Published var recordsSecurity: SecurityOption
    
    let tipsArray: [LocalizedStringKey] = ["tap_to_view_details", 
                                           "swipe_left_task_list",
                                           "hold_on_task_task_list"]
    var appState: AppState
    
    // MARK: - Private
    private var searchCancellable: AnyCancellable?
    
    // MARK: - Internal
    var settings: SettingsDTO
    
    init(appState: AppState) {
        self.appState = appState
        let settings = appState.settingsRepository!.get()
        self.settings = settings
        self.recordsSecurity = settings.recordsSecurity.securityOption
        setupSearch()
    }
    
    func mainLoad() {
        showingInfoTipsSetup()
        loadRecords()
    }
    
    func deleteRecord(_ record: RecordDTO) {
        savedRecords.removeAll(where: { $0.id == record.id })
        appState.recordsRepository?.deleteRecord(record.id)
        deleteRecordFromKeychain(record)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        if settings.sortingType == .manualy {
            savedRecords.move(fromOffsets: source, toOffset: destination)
            reloadRecords()
        }
    }
    
    func copy(record: RecordDTO) {
        let copyText = CopyRecordHelper(record: record).copiedText
        UIPasteboard.general.string = copyText
        showCopyAlert = true
    }
    
    func showingInfoTipsSetup() {
        isShowingInfoView = settings.isShowingInfoTips
        if settings.isShowingInfoTips == true {
            settings.isShowingInfoTips = false
            appState.settingsRepository?.save(settings)
        }
    }
}

// MARK: - Private methods
private extension RecordListViewModel {
    func setupSearch() {
        searchCancellable = $searchText
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterAccounts()
            }
    }
    
    func reloadRecords() {
        appState.recordsRepository?.saveRecords(savedRecords)
    }
    
    func filterAccounts() {
        let records = appState.recordsRepository!.getRecordList()

        if searchText.isEmpty {
            savedRecords = records
        } else {
            savedRecords = records.filter {
                $0.openRecordInfo.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func deleteRecordFromKeychain(_ record: RecordDTO) {
        guard var array = KeychainService.getStringArray(forKey: Constants.shared.passwordsKeys)else {
            return
        }
        
        array.removeAll { pass in
            pass == record.protectedRecordInfo.password
        }
        
        KeychainService.saveOrUpdateStringArray(strings: array, forKey: Constants.shared.passwordsKeys)
    }
    
    func loadRecords() {
        let settings = appState.settingsRepository!.get()
        self.settings = settings
        let records = appState.recordsRepository!.getRecordList()
        switch settings.sortingType {
        case .manualy:
            self.savedRecords = records
        case .alphabetAZ:
            self.savedRecords = records.sorted { $0.openRecordInfo.title < $1.openRecordInfo.title }
        case .alphabetZA:
            self.savedRecords = records.sorted { $0.openRecordInfo.title > $1.openRecordInfo.title }
        }
    }
}
