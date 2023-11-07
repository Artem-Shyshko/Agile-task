//
//  DateSegmentedControl.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 12.10.2023.
//

import SwiftUI

public enum TaskDateSorting: String, CaseIterable {
  case today = "Today"
  case week = "Week"
  case month = "Month"
  case all = "All"
}

public struct DateSegmentedControl: View {
    @Binding var selectedDateSorting: TaskDateSorting
    
    public init(selectedDateSorting: Binding<TaskDateSorting>) {
        self._selectedDateSorting = selectedDateSorting
    }
    
    public var body: some View {
            Picker("", selection: $selectedDateSorting) {
                ForEach(TaskDateSorting.allCases, id: \.self) {
                    Text($0.rawValue)
                        .font(.helveticaBold(size: 30))
                }
            }
            .pickerStyle(.segmented)
    }
}

struct DateSegmentedControl_Previews: PreviewProvider {
    static var previews: some View {
        DateSegmentedControl(selectedDateSorting: .constant(.all))
            .previewLayout(.sizeThatFits)
    }
}
