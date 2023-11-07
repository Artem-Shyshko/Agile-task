//
//  SecurityViewModel.swift
//  Master Task
//
//  Created by Artur Korol on 04.10.2023.
//

import Foundation

final class SecurityViewModel: ObservableObject {
    @Published var selectedSecurityOption: SecurityOption = .none
}
