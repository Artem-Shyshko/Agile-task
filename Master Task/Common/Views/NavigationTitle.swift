//
//  NavigationTitleView.swift
//  Agile Task
//
//  Created by Artur Korol on 18.01.2024.
//

import SwiftUI

struct NavigationTitle: View {
    var title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.helveticaBold(size: 16))
            .foregroundStyle(.white)
    }
}

#Preview {
    NavigationTitle("")
}