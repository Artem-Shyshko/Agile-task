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
    @Namespace private var animation
    
    public init(options: [SelectionValue], selection: Binding<SelectionValue>) {
        self.options = options
        self._selection = selection
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                HStack(alignment: .center, spacing: 0) {
                    Text(LocalizedStringKey(option.description))
                        .font(selection == option ? .helveticaBold(size: 16) : .helveticaRegular(size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 3)
                        .frame(maxWidth: .infinity)
                        .background {
                            ZStack {
                                if selection.description == option.description {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.white.opacity(0.1))
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
            RoundedRectangle(cornerRadius: 4)
                .stroke(lineWidth: 1)
                .fill(.white.opacity(0.6))
        )
    }
}

#Preview {
    ZStack {
        Color.black
        CustomSegmentedControl(options: StatisticsOptions.allCases, selection: .constant(.graph))
    }
}

fileprivate enum StatisticsOptions: String, CustomStringConvertible, CaseIterable {
    case pie = "statistics_option_pie"
    case graph = "statistics_option_graph"
    case bars = "statistics_option_bars"
    
    var description: String {
        self.rawValue
    }
}
