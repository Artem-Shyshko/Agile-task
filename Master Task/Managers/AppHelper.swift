//
//  AppHelper.swift
//  Master Task
//
//  Created by Artur Korol on 13.09.2023.
//

import Foundation

final class AppHelper {
    static let shared = AppHelper()
    
    private init() {}
    
    var isOnboarding: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.shared.showOnboarding)
        }
        get {
            UserDefaults.standard.bool(forKey: Constants.shared.showOnboarding)
        }
    }
    
    func handleIncomingURL(_ url: URL, completion: @escaping (()->Void)) {
        guard url.scheme == "agiletask" else { return }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return
        }
        
        guard let action = components.host, action == "addnewtask" else {
            print("Unknown URL, we can't handle this one!")
            return
        }
        
        completion()
        return
    }
}
