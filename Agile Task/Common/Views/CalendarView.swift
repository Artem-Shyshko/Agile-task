//
//  CustomCalendarView.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 13.10.2023.
//

import SwiftUI

struct CustomCalendarView: View {
    @ObservedObject var viewModel = CalendarViewModel()
    @Binding var selectedCalendarDay: Date
    @Binding var isShowingCalendarPicker: Bool
    var currentMonthDatesColor: Color
    var backgroundColor: Color
    var items: [CalendarItem]?
    var months: [String]
    
    init(
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
    
    var body: some View {
        ZStack {
            backgroundColor
                .cornerRadius(4)
            
            CalendarDayView(
                viewModel: viewModel,
                calendarDate: $selectedCalendarDay,
                currentMonthDatesColor: currentMonthDatesColor,
                items: items
            )
            .vAlign(alignment: .top)
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 10)
            
            ZStack {
                monthButton()
                    .hAlign(alignment: .center)
                HStack(spacing: 26) {
                    minusMonthButton()
                    Spacer()
                    backToCurrentDateButton()
                    addMonthButton()
                }
            }
            .padding(.top, 15)
            .padding(.horizontal, 15)
            .vAlign(alignment: .top)
        }
        .frame(height: 360)
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
                .font(.helveticaBold(size: 17))
                .foregroundStyle(currentMonthDatesColor)
        }
    }
    
    func addMonthButton() -> some View {
        Button {
            viewModel.addToCurrentDate(currentDate: &selectedCalendarDay, component: .month, value: 1)
        } label: {
            Image(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .frame(size: 20)
        }
        .foregroundStyle(currentMonthDatesColor)
    }
    
    func backToCurrentDateButton() -> some View {
        Button(action: {
            viewModel.backToCurrentDateButtonAction(&selectedCalendarDay)
        }, label: {
            Image(systemName: "arrow.circlepath")
                .frame(size: 26)
        })
        .foregroundStyle(currentMonthDatesColor)
    }
    
    func minusMonthButton() -> some View {
        Button {
            viewModel.minusFromCurrentDate(currentDate: &selectedCalendarDay, component: .month, value: 1)
        } label: {
            Image(systemName: "chevron.left")
                .resizable()
                .scaledToFit()
                .frame(size: 20)
        }
        .foregroundStyle(currentMonthDatesColor)
    }
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
