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
            UserDefaults.standard.setValue(newValue, forKey: MasterTaskConstants.showOnboarding)
        }
        get {
            UserDefaults.standard.bool(forKey: MasterTaskConstants.showOnboarding)
        }
    }
}
