//
//  CustomSegmentedControl.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 12.10.2023.
//

import SwiftUI

public struct CustomSegmentedControl<SelectionValue: Hashable & CustomStringConvertible>: View {
    var options: [SelectionValue]
    @Binding var selection: SelectionValue
    var textColor: Color
    @Namespace private var animation
    
    public init(options: [SelectionValue], selection: Binding<SelectionValue>, textColor: Color) {
        self.options = options
        self._selection = selection
        self.textColor = textColor
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                HStack(alignment: .center, spacing: 0) {
                    Text(LocalizedStringKey(option.description))
                        .font(selection == option ? .helveticaBold(size: 16) : .helveticaRegular(size: 16))
                        .foregroundStyle(selection == option ? .black : .white)
                        .padding(.vertical, 3)
                        .frame(maxWidth: .infinity)
                        .background {
                            ZStack {
                                if selection.description == option.description {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.white)
                                        .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                                }
                            }
                            .animation(.snappy, value: selection)
                        }
                        .contentShape(.rect)
                        .onTapGesture {
                            selection = option
                        }
                    
                    if option.description != options.last?.description {
                        Rectangle()
                            .fill(.white)
                            .frame(width: 0.3, height: 15)
                            .padding(.horizontal, 5)
                    }
                }
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(.white.opacity(0.15))
        )
    }
    
}
