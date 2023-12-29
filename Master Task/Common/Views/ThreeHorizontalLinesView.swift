//
//  SwiftUIView.swift
//  Agile Task
//
//  Created by Artur Korol on 27.12.2023.
//

import SwiftUI

struct ThreeHorizontalLinesView: View {
    var body: some View {
        VStack(spacing: 5) {
          line()
          line()
          line()
        }
    }
}

private extension ThreeHorizontalLinesView {
    func line() -> some View {
      RoundedRectangle(cornerRadius: 1)
        .frame(width: 16.2, height: 1.2)
    }
}

#Preview {
    ThreeHorizontalLinesView()
}
