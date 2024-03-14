//
//  TextFieldWithEnterButton.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 27.12.2023.
//

import SwiftUI

public struct TextFieldWithEnterButton: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String
    @State private var isButtonPress: Bool = false
    let action: (()->Void)
    
    public init(placeholder: LocalizedStringKey, text: Binding<String>, action: @escaping (()->Void)) {
        self.placeholder = placeholder
        self._text = text
        self.action = action
    }
    
    public var body: some View {
        ZStack {
            TextField("", text: $text ,axis: .vertical)
                .lineLimit(1...10)
                .lineSpacing(3)
                .autocorrectionDisabled()
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
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 35))
                .overlay(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundStyle(.secondary)
                    }
                }
            
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
    TextFieldWithEnterButton(placeholder: "Placeholder", text: .constant("")) {}
}
