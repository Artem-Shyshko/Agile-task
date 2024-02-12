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
            Image("Search")
              .resizable()
              .scaledToFit()
              .frame(width: 22, height: 22)
          }
          .foregroundColor(.white)
    }
}

#Preview {
    MagnifyingGlassButton {}
}
