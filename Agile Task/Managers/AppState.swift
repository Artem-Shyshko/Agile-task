//
//  AppState.swift
//  Agile Task
//
//  Created by Artur Korol on 14.03.2024.
//

import Foundation

final class AppState: ObservableObject {
    @Published var language: AppLanguage = .english
}
