//
//  ColorPanel.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 12.10.2023.
//

import SwiftUI

public struct ColorPanel: View {
    @Binding var selectedColor: Color
    var colors: [Color]
    
    public init(selectedColor: Binding<Color>, colors: [Color]) {
        self._selectedColor = selectedColor
        self.colors = colors
    }
    
    public var body: some View {
        HStack {
            ForEach(colors, id: \.self) { color in
                Button {
                    selectedColor = color
                } label: {
                    if selectedColor != color {
                        color
                            .overlay {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(lineWidth: 1)
                                    .foregroundColor(.white)
                            }
                    } else {
                        color
                            .overlay {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(lineWidth: 4)
                                    .tint(.green)
                            }
                    }
                }
                .frame(width: 35, height: 35)
                .cornerRadius(6)
            }
        }
    }
}

struct ColorPanel_Previews: PreviewProvider {
    static var previews: some View {
        ColorPanel(
            selectedColor: .constant(.red),
            colors: [.red, .green, .blue]
        )
    }
}
