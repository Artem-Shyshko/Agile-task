//
//  Binding+Ext.swift
//  Master Task
//
//  Created by Artur Korol on 02.11.2023.
//

import SwiftUI

extension Binding where Value == String {
    /// Max characters  in the textfield
    func max(_ limit: Int) -> Self {
        if self.wrappedValue.count > limit {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.dropLast())
            }
        }
        return self
    }
}
