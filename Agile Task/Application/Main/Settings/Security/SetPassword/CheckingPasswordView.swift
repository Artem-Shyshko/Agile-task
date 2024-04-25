//
//  CheckingPasswordView.swift
//  Agile Task
//
//  Created by Artur Korol on 12.04.2024.
//

import SwiftUI

// MARK: - PasswordRequirement
enum PasswordRequirement: String, CaseIterable, Localizable {
    case minMax = "min_max_password_char"
    case lowercase = "lower_case"
    case uppercase = "upper_case"
    case number = "password_numbers"
    case specialCharacter = "password_special_char"
    
    func meetsRequirement(password: String) -> Bool {
        switch self {
        case .minMax:
            return (4...20).contains(password.count)
        case .lowercase:
            return password.rangeOfCharacter(from: .lowercaseLetters) != nil
        case .uppercase:
            return password.rangeOfCharacter(from: .uppercaseLetters) != nil
        case .number:
            return password.rangeOfCharacter(from: .decimalDigits) != nil
        case .specialCharacter:
            let specialCharacters = CharacterSet(charactersIn: "@#$^&*+=")
            return password.rangeOfCharacter(from: specialCharacters) != nil
        }
    }
}

struct CheckingPasswordView: View {
    // MARK: - Properties
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: SetPasswordViewModel
    let password: String
    
    private var allRequirementsMet: Bool {
        for requirement in PasswordRequirement.allCases {
            if !requirement.meetsRequirement(password: password) {
                return false
            }
        }
        return true
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("password_requirements")
                .font(.helveticaRegular(size: 16))
            
            ForEach(PasswordRequirement.allCases, id: \.self) { requirement in
                HStack {
                    Image(systemName: requirement.meetsRequirement(password: password) ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .foregroundColor(.white)
                        .font(.helveticaRegular(size: 23))
                        .frame(width: 23, height: 23)
                    
                    Text(requirement.localized)
                        .font(.helveticaRegular(size: 16))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(7)
        .foregroundColor(themeManager.theme.textColor(colorScheme))
        .onChange(of: allRequirementsMet) { newValue in
            viewModel.allRequirementsMet = newValue
        }
    }
}
