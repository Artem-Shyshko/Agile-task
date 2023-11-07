//
//  View+Ext.swift
//  Master Task
//
//  Created by Artur Korol on 08.08.2023.
//

import SwiftUI

extension View {
    func hAlign(alignment: Alignment) -> some View {
      self
        .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAlign(alignment: Alignment) -> some View {
      self
        .frame(maxHeight: .infinity, alignment: alignment)
    }
}
