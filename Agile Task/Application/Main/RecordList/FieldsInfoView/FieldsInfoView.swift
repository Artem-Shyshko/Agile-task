//
//  FieldsInfoView.swift
//  Agile Task
//
//  Created by USER on 09.04.2024.
//

import SwiftUI
import RealmSwift

struct FieldsInfoView: View {
    // MARK: - Properties
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: FieldsInfoViewModel
    @State var showDeleteAlert = false
    @FocusState private var focusedInput: Int?
    @State private var isFirstSelection = true
    var isEditing: Bool
    
    // MARK: - Body
    var body: some View {
        listOfTextEditor()
        addFieldButton()
    }
}
// MARK: - Private Views
private extension FieldsInfoView {
    func addFieldButton() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            Menu {
                ForEach(FieldsType.allCases, id: \.rawValue) { theme in
                    Button {
                        viewModel.fieldType = theme
                    } label: {
                        HStack {
                            Text(LocalizedStringKey(theme.rawValue))
                        }
                    }
                }
            } label: {
                HStack {
                    Text("add_field")
                        .hAlign(alignment: .leading)
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "plus")
                        .imageScale(.medium)
                        .font(.helveticaRegular(size: 17))
                        .foregroundColor(.secondary)
                }
            }
        }
        .onReceive(viewModel.$fieldType) { newValue in
            guard !isFirstSelection else {
                isFirstSelection = false
                return
            }
            
            if newValue == .date {
                viewModel.fieldArray.append(FieldInfoModel(type: .date, title: String(Date().description)))
            } else if newValue == .bulletList {
                viewModel.fieldArray.append(FieldInfoModel(type: .bulletList))
            } else {
                viewModel.fieldArray.append(FieldInfoModel(type: newValue))
            }
            
            if focusedInput == nil {
                focusedInput = 0
            } else {
                focusedInput! += 1
            }
        }
        
        .alert("are_you_sure_you_want_to_delete_the_point", isPresented: $showDeleteAlert) {
            Button {
                showDeleteAlert = false
            } label: {
                Text("cancel_button")
            }
            
            Button {
                viewModel.trashButtonAction()
                focusedInput = viewModel.fieldArray.count - 1
            } label: {
                Text("delete")
            }
        }
    }
    
    func listOfTextEditor() -> some View {
        ForEach($viewModel.fieldArray, id: \.id) { field in
            FieldEditor(
                viewModel: viewModel,
                showAlert: $showDeleteAlert,
                field: field,
                isFieldOnFocus: focusedInput == viewModel.focusNumber(field: field.wrappedValue),
                isEditing: isEditing)
            .focused(
                $focusedInput,
                equals: viewModel.focusNumber(field: field.wrappedValue)
            )
        }
        .onMove(perform: viewModel.move)
    }
}

// MARK: - FieldEditor
fileprivate struct FieldEditor: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: FieldsInfoViewModel
    @Binding var showAlert: Bool
    @Binding var field: FieldInfoModel
    @State var list: [BulletDTO] = []
    @FocusState var isFocus: Bool
    var isFieldOnFocus: Bool
    var isEditing: Bool
    
    var body: some View {
        if field.type == .date {
            calendarFieldView()
            if field.isCalendarShowing {
                calendarView()
            }
        } else if field.type == .bulletList {
            bulletListView()
        } else {
            defaultField()
                .onAppear {
                    isFocus = isFieldOnFocus
                }
        }
    }
}

// MARK: - Private views
private extension FieldEditor {
    func defaultField() -> some View {
        HStack(spacing: 4) {
            if isEditing {
                Text(LocalizedStringKey(field.type.rawValue))
                    .font(.helveticaLight(size: 16))
                Spacer()
            }
            TextField("", text: $field.title.max(Constants.shared.charactersLimit),
                      prompt: Text(LocalizedStringKey(field.type.description))
                .foregroundColor(.secondary))
            .keyboardType(field.type.keyboard)
            .multilineTextAlignment(isEditing ? .trailing : .leading)
            .submitLabel(.done)
            .tint(themeManager.theme.sectionTextColor(colorScheme))
            .focused($isFocus)
            
            rightButtonsStack()
        }
    }
    
    func passwordView() -> some View {
        HStack {
            Text("password_title")
                .foregroundColor(themeManager.theme.sectionTextColor(colorScheme))
            Spacer()
            Text(field.title)
        }
    }
    
    func bulletListView() -> some View {
        Button {
            field.isShowingBulletView = true
        } label: {
            HStack(spacing: 5) {
                Text("info_bulletlist")
                    .font(isEditing ? .helveticaLight(size: 16) : .helveticaRegular(size: 16))
                Spacer()
                
                Text(list.isEmpty ? "Add" : "Edit")
                
            }
        }
        .fullScreenCover(isPresented: $field.isShowingBulletView, content: {
            BulletView(
                viewModel: BulletViewModel(appState: appState),
                taskBulletArray: $list,
                isShowing: $field.isShowingBulletView
            )
        })
        .onChange(of: list) { newValue in
            field.list = newValue
        }
        .onAppear(perform: {
            list = field.list
        })
        .tint(themeManager.theme.sectionTextColor(colorScheme))
        .foregroundColor(themeManager.theme.sectionTextColor(colorScheme))
    }
    
    func calendarFieldView() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            HStack(spacing: 5) {
                if isEditing {
                    Text(LocalizedStringKey(field.type.rawValue))
                        .font(.helveticaLight(size: 16))
                    Spacer()
                }
                Button {
                    field.isCalendarShowing.toggle()
                } label: {
                    Text(viewModel.dateType == .dayMonthYear ? field.title.formatToFormattedString(format: "dd.MM.yyyy") : field.title.formatToFormattedString(format: "MM.dd.yyyy"))
                        .padding(5)
                }
                .background(RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.selectedGrey)))
                if !isEditing {
                    Spacer()
                }
                
                rightButtonsStack()
            }
            .tint(themeManager.theme.sectionTextColor(colorScheme))
            .foregroundStyle( themeManager.theme.sectionTextColor(colorScheme))
        }
        .onChange(of: field.startDate) { newValue in
            field.title = newValue.description
        }
    }
    
    func calendarView() -> some View {
        CustomCalendarView(
            selectedCalendarDay: $field.startDate,
            isShowingCalendarPicker: $viewModel.isShowingStartDateCalendarPicker,
            currentMonthDatesColor: themeManager.theme.sectionTextColor(colorScheme),
            backgroundColor:themeManager.theme.sectionColor(colorScheme),
            calendar: Constants.shared.calendar
        )
    }
    
    func rightButtonsStack() -> some View {
        HStack {
            ThreeHorizontalLinesView()
            
            Button(action: {
                isFocus = false
                viewModel.deletedBullet = field
                showAlert = true
            }, label: {
                Image(.trash)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.red)
            })
            .buttonStyle(.borderless)
            .frame(width: 25, height: 25)
        }
    }
}
