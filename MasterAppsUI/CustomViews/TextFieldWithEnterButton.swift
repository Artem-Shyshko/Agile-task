//
//  TextFieldWithEnterButton.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 27.12.2023.
//

import SwiftUI

public struct TextFieldWithEnterButton: View {
    let placeholder: String
    @Binding var text: String
    @State private var isButtonPress: Bool = false
    let action: (()->Void)
    
    public init(placeholder: String, text: Binding<String>, action: @escaping (()->Void)) {
        self.placeholder = placeholder
        self._text = text
        self.action = action
    }
    
    public var body: some View {
        ZStack {
            TextField(placeholder, text: $text ,axis: .vertical)
                .lineLimit(1...10)
                .lineSpacing(3)
                .frame(minHeight: 25)
                .fixedSize(horizontal: false, vertical: true)
                .submitLabel(.done)
                .onChange(of: text) { _ in
                    if text.last?.isNewline == .some(true), !isButtonPress {
                        text = String(text.prefix(text.count - 1))
                        action()
                    }
                    isButtonPress = false
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
            
            Button {
                isButtonPress = true
                text.append("\n")
            } label: {
                Image("enter")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(width: 10,height: 10)
                    .padding(.trailing, 16)
            }
            .hAlign(alignment: .bottomTrailing)
        }
    }
}

#Preview {
    TextFieldWithEnterButton(placeholder: "Empty", text: .constant("2321")) {}
}
