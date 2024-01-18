//
//  MagnifyingGlassButton.swift
//  Agile Task
//
//  Created by Artur Korol on 18.01.2024.
//

import SwiftUI

struct MagnifyingGlassButton: View {
    let action: (()->Void)
    
    var body: some View {
          Button {
              action()
          } label: {
            Image(systemName: "magnifyingglass")
              .resizable()
              .scaledToFit()
              .frame(width: 18, height: 18)
          }
          .foregroundColor(.white)
    }
}

#Preview {
    MagnifyingGlassButton {}
}
