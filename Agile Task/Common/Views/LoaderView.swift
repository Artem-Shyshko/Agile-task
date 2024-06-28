//
//  LoaderView.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 04.04.2024.
//

import SwiftUI

public struct LoaderView: View {
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.2)
            ProgressView()
                .progressViewStyle(.circular)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LoaderView()
}
