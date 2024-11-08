//
//  AppHelper.swift
//  Agile Task
//
//  Created by Artur Korol on 13.09.2023.
//

import SwiftUI
import SwiftyDropbox

final class AppHelper {
    static let shared = AppHelper()
    
    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private init() {}
    
    var isOnboarding: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.shared.showOnboarding)
        }
        get {
            UserDefaults.standard.bool(forKey: Constants.shared.showOnboarding)
        }
    }
    
    func handleIncomingURL(_ url: URL) -> IncomeUrlState? {
        guard url.scheme == "agiletask"  || url.scheme == "db-\(Constants.shared.dropboxKey)"  else {
            print("Unknown url: \(url)")
            return nil
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return nil
        }
        
        if let action = components.host, action == "addnewtask" {
            return .widgetNewTask
        } else if components.path.contains("token") {
            return handleDropboxURL(with: url)
        } else {
            print("Unknown URL, we can't handle this one!")
            return nil
        }
    }
    
    private func handleDropboxURL(with url: URL) -> IncomeUrlState? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return nil
        }
        
        let oauthCompletion: DropboxOAuthCompletion = {
            if let authResult = $0 {
                switch authResult {
                case .success:
                    if let accessToken = DropboxClientsManager.authorizedClient?.accessTokenProvider.accessToken {
                        let status = KeychainManager.shared.save(
                            key: Constants.shared.dropboxAccessToken,
                            data: accessToken.data(using: .utf8)!
                        )
                        print("Saved token status - \(status)")
                    }
                    print("Success! User is logged into DropboxClientsManager.")
                    NotificationCenter.default.post(name: .dropboxAuthSuccess, object: nil)
                case .cancel:
                    print("Authorization flow was manually canceled by user!")
                    NotificationCenter.default.post(
                        name: .dropboxAuthFailed,
                        object: "Authorization flow was manually canceled by user!"
                    )
                case .error(_, let description):
                    print("Error: \(String(describing: description))")
                    NotificationCenter.default.post(name: .dropboxAuthFailed, object: description)
                }
            }
        }
        
        let canHandleUrl = DropboxClientsManager.handleRedirectURL(url, includeBackgroundClient: false, completion: oauthCompletion)
        
        return canHandleUrl ? .dropbox : nil
    }
}

enum IncomeUrlState: Hashable {
    case widgetNewTask
    case dropbox
}
