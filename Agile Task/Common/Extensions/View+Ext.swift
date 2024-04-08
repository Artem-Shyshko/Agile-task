//
//  View+Ext.swift
//  Agile Task
//
//  Created by Artur Korol on 08.08.2023.
//

import SwiftUI
import MasterAppsUI

extension View {
    func hAlign(alignment: Alignment) -> some View {
      self
        .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAlign(alignment: Alignment) -> some View {
      self
        .frame(maxHeight: .infinity, alignment: alignment)
    }
    
    func backButton(action: @escaping (()->Void)) -> some View {
        Button {
            action()
        } label: {
            Image("Arrow Left")
        }
    }
    
    @ViewBuilder
    func loaderView(show: Bool) -> some View {
        if show {
            LoaderView()
        }
    }
}
