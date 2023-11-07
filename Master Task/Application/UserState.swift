//
//  UserState.swift
//  Master Task
//
//  Created by Artur Korol on 17.08.2023.
//

import SwiftUI

class UserState: ObservableObject {
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Settings
    
    @Published var selectedAccount: String = "Personal"
}
