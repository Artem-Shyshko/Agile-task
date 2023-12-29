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
}
