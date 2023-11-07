//
//  NavigationView.swift
//  Master Task
//
//  Created by Artur Korol on 16.08.2023.
//

import SwiftUI

struct NavigationView: View {
    var title: String
    
    var body: some View {
            Text(title)
                .font(.helveticaBold(size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
    }
}
