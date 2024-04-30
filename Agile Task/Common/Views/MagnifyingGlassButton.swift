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
              Image(.search)
              .resizable()
              .scaledToFit()
              .frame(size: Constants.shared.imagesSize)
          }
          .foregroundColor(.white)
    }
}

#Preview {
    MagnifyingGlassButton {}
}
