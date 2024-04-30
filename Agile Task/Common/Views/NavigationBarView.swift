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
                .hAlign(alignment: .center)
                .padding(.horizontal, 50)
                .layoutPriority(1)
            
            HStack(spacing: 15) {
                leftItem
                    .hAlign(alignment: .leading)
                Spacer()
                rightItem
                    .hAlign(alignment: .trailing)
            }
            .padding(.horizontal, 15)
        }
        .frame(height: 30)
        .padding(.vertical, 10)
    }
}
