//
//  MasterTaskConstants.swift
//  Master Task
//
//  Created by Artur Korol on 25.08.2023.
//

import SwiftUI

final class MasterTaskConstants {
    static let shared = MasterTaskConstants()
    
    private init() {}
    
    let shortDateFormat = "EE d/M/yy"
    static let appMode = ""
    static let darkMode = "DARK_MODE"
    static let lightMode = "LIGHT_MODE"
    static let showOnboarding = "ShowOnboarding"
    let userPassword = "User_Password"
    let listRowSpacing: CGFloat = 3
    
    lazy var local = Locale(identifier: "us")
    
    static let mockTask = TaskObject(parentId: nil, title: "SS", date: Date(), account: "Personal", recurring: .daily, reminder: .none, reminderDate: Date(), createdDate: Date(), colorName: Color.battleshipGray.name)
    lazy var currentDate = Date()
    
    lazy var dateFormatter = DateFormatter()
}
