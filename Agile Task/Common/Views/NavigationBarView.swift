//
//  NavigationView.swift
//  Agile Task
//
//  Created by Artur Korol on 16.08.2023.
//

import SwiftUI

struct NavigationBarView<LeftItem: View, Header: View, RightItem: View>: View {
    
    let leftItem: LeftItem
    let header: Header
    let rightItem: RightItem
    
    var body: some View {
        ZStack {
            header
                .padding(.horizontal, 30)
            HStack(spacing: 5) {
                leftItem
                Spacer()
                rightItem
            }
        }
        .frame(height: 30)
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
    }
}
