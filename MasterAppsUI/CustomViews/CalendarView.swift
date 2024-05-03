//
//  CustomCalendarView.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 13.10.2023.
//

import SwiftUI

public struct CustomCalendarView: View {
    @ObservedObject var viewModel = CalendarViewModel()
    @Binding var selectedCalendarDay: Date
    @Binding var isShowingCalendarPicker: Bool
    var currentMonthDatesColor: Color
    var backgroundColor: Color
    var items: [CalendarItem]?
    var months: [String]
    
    public init(
        selectedCalendarDay: Binding<Date>,
        isShowingCalendarPicker: Binding<Bool>,
        currentMonthDatesColor: Color,
        backgroundColor: Color,
        items: [CalendarItem]? = nil,
        calendar: Calendar
    ) {
        self._selectedCalendarDay = selectedCalendarDay
        self._isShowingCalendarPicker = isShowingCalendarPicker
        self.currentMonthDatesColor = currentMonthDatesColor
        self.backgroundColor = backgroundColor
        self.items = items
        months = calendar.standaloneMonthSymbols
        viewModel.calendar = calendar
    }
    
    public var body: some View {
        ZStack {
            backgroundColor
                .cornerRadius(4)
            
            CalendarDayView(
                viewModel: viewModel,
                calendarDate: $selectedCalendarDay,
                currentMonthDatesColor: currentMonthDatesColor,
                items: items
            )
            .padding(.horizontal, 20)
            .padding(.top, 50)
            .padding(.bottom, 10)
            
            HStack {
                monthButton()
                Spacer()
                backToCurrentDateButton()
                minusMonthButton()
                addMonthButton()
            }
            .padding(.top, 15)
            .padding(.horizontal, 15)
            .vAlign(alignment: .top)
        }
        .overlay(alignment: .top) {
            if isShowingCalendarPicker {
                CalendarPickerView(
                    selectedCalendarDay: $selectedCalendarDay,
                    isShowing: $isShowingCalendarPicker,
                    currentMonthDatesColor: currentMonthDatesColor,
                    backgroundColor: backgroundColor,
                    calendar: viewModel.calendar,
                    availableOptions: [.month]
                )
            }
        }
    }
}

private extension CustomCalendarView {
    
    func monthButton() -> some View {
        Button {
            isShowingCalendarPicker.toggle()
        } label: {
            Text(selectedCalendarDay.monthString)
                .foregroundStyle(currentMonthDatesColor)
        }
    }
    
    func addMonthButton() -> some View {
        Button {
            viewModel.addToCurrentDate(currentDate: &selectedCalendarDay, component: .month, value: 1)
        } label: {
            Image(systemName: "chevron.right")
        }
        .foregroundStyle(currentMonthDatesColor)
    }
    
    func backToCurrentDateButton() -> some View {
        Button(action: {
            viewModel.backToCurrentDateButtonAction(&selectedCalendarDay)
        }, label: {
            Image(systemName: "arrow.circlepath")
        })
        .foregroundStyle(currentMonthDatesColor)
    }
    
    func minusMonthButton() -> some View {
        Button {
            viewModel.minusFromCurrentDate(currentDate: &selectedCalendarDay, component: .month, value: 1)
        } label: {
            Image(systemName: "chevron.left")
        }
        .foregroundStyle(currentMonthDatesColor)
    }
}

// MARK: - CalendarItem

public protocol CalendarItem {
    var title: String { get set }
    var date: Date? { get set }
    var createdDate: Date { get set }
}

// MARK: - CalendarView_Previews

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CustomCalendarView(
            selectedCalendarDay: .constant(Date()),
            isShowingCalendarPicker: .constant(true),
            currentMonthDatesColor: .white,
            backgroundColor: .secondary,
            items: [],
            calendar: Calendar.current
        )
    }
    
    struct MyItem: CalendarItem {
        var title: String = ""
        var date: Date? = nil
        var createdDate: Date = Date()
    }
}
