//
//  String+Ext.swift
//  Agile Task
//
//  Created by Artur Korol on 29.08.2023.
//

import Foundation

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
