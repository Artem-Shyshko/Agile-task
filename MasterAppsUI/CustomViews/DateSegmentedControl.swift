//
//  DateSegmentedControl.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 12.10.2023.
//

import SwiftUI

public enum TaskDateSorting: String, CaseIterable {
  case all = "All"
  case today = "Today"
  case week = "Week"
  case month = "Month"
}

public struct DateSegmentedControl: View {
    @Binding var selectedDateSorting: TaskDateSorting
    @Namespace private var animation
    
    public init(selectedDateSorting: Binding<TaskDateSorting>) {
        self._selectedDateSorting = selectedDateSorting
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(TaskDateSorting.allCases, id: \.rawValue) { dateSorting in
                HStack(alignment: .center, spacing: 0) {
                    Text(dateSorting.rawValue)
                        .font(.helveticaRegular(size: 16))
                        .foregroundStyle(selectedDateSorting == dateSorting ? .black : .white)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity)
                        .background {
                            ZStack {
                                if selectedDateSorting == dateSorting {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.white)
                                        .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                                }
                            }
                            .animation(.snappy, value: selectedDateSorting)
                        }
                        .contentShape(.rect)
                        .onTapGesture {
                            selectedDateSorting = dateSorting
                    }
                    
                    if dateSorting.rawValue != TaskDateSorting.allCases.last?.rawValue {
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

struct DateSegmentedControl_Previews: PreviewProvider {
    static var previews: some View {
        DateSegmentedControl(selectedDateSorting: .constant(.all))
            .previewLayout(.sizeThatFits)
            .padding(20)
    }
}
