//
//  NewTaskTextFieldStyle.swift
//  Master Task
//
//  Created by Artur Korol on 11.08.2023.
//

import SwiftUI

struct NewTextFieldStyle: TextFieldStyle {
  func _body(configuration: TextField<Self._Label>) -> some View {
    configuration
      .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
      .frame(height: 45)
      .background(Color.sectionColor)
      .cornerRadius(4)
  }
}
