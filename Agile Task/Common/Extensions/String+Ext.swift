//
//  String+Ext.swift
//  Agile Task
//
//  Created by Artur Korol on 29.08.2023.
//

import Foundation

enum RegEx: String {
    case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    case url = #"((https?|ftp)://)?(www\.)?[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})+(\/[a-zA-Z0-9#]+\/?)*"#
}

extension String {
    var firstLetter: String {
        String(self.prefix(1))
    }
    
    func applyDateMask() -> String {
        // Remove any existing dots to start with a clean slate
        var numericString = self.replacingOccurrences(of: ".", with: "")
        
        // Ensure we don't exceed the length for a full date (ddMMyyyy = 8 characters)
        numericString = String(numericString.prefix(8))
        
        // Apply the mask
        var maskedString = ""
        for (index, character) in numericString.enumerated() {
            if index == 2 || index == 4 {
                maskedString.append(".\(character)")
            } else {
                maskedString.append(character)
            }
        }
        return maskedString
    }
}

// MARK: - Validation
extension String {
    func isStringValid(regEx: RegEx) -> Bool {
        let predicate = NSPredicate(format:"SELF MATCHES %@",
                                    regEx.rawValue)
        return predicate.evaluate(with: self)
    }
}

// MARK: - Date format
extension String {
    func formatToFormattedString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        guard let date = dateFormatter.date(from: self) else {
            return ""
        }
        
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = format
        return newDateFormatter.string(from: date)
    }
}

