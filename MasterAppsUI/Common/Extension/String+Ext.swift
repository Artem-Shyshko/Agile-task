//
//  String+Ext.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 03.04.2024.
//

import Foundation

extension String {
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
