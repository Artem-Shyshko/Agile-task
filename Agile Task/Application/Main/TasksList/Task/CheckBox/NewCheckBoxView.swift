//
//  NewCheckBoxView.swift
//  Agile Task
//
//  Created by Artur Korol on 30.10.2023.
//

import SwiftUI
import RealmSwift

struct NewCheckBoxView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: NewCheckBoxViewModel
    @Binding var taskCheckboxes: [CheckboxDTO]
    @Binding var isShowing: Bool
    var task: TaskDTO?
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedInput: Int?
    @State var showDeleteAlert = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Constants.shared.viewSectionSpacing) {
            navigationBar()
            checkBoxesList()
        }
        .modifier(TabViewChildModifier())
        .onAppear(perform: {
            viewModel.checkboxes = taskCheckboxes
            
            if $viewModel.checkboxes.isEmpty {
                viewModel.checkboxes.append(CheckboxDTO(object: CheckboxObject(title: "")))
                focusedInput = 0
            } else {
                focusedInput = viewModel.checkboxes.count - 1
            }
        })
        .alert("Are you sure you want to delete the point?", isPresented: $showDeleteAlert) {
            Button {
                showDeleteAlert = false
            } label: {
                Text("Cancel")
            }
            
            Button {
                viewModel.trashButtonAction(task: task)
                focusedInput = viewModel.checkboxes.count - 1
            } label: {
                Text("Delete")
            }
        }
    }
}

// MARK: - Private views

private extension NewCheckBoxView {
    
    func checkBoxesList() -> some View {
        List {
            Group {
                listOfTextEditor()
                
                addPointButton()
            }
            .scrollContentBackground(.hidden)
            .listRowSeparator(.hidden)
            .listRowBackground(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(themeManager.theme.sectionColor(colorScheme).name))
            )
        }
        .listStyle(.plain)
        .listRowSpacing(Constants.shared.listRowSpacing)
    }
    
    func listOfTextEditor() -> some View {
        ForEach($viewModel.checkboxes, id: \.id) { checkbox in
            TextEditor(
                viewModel: viewModel,
                showAlert: $showDeleteAlert,
                checkbox: checkbox,
                isFieldOnFocus: focusedInput == viewModel.focusNumber(checkbox: checkbox.wrappedValue)
            )
            .focused(
                $focusedInput,
                equals: viewModel.focusNumber(checkbox: checkbox.wrappedValue)
            )
        }
        .onMove(perform: viewModel.move)
    }
    
    func addPointButton() -> some View {
        Button(action: {
            viewModel.checkboxes.append(CheckboxDTO(object: CheckboxObject(title: "")))
            if focusedInput == nil {
                focusedInput = 0
            } else {
                focusedInput! += 1
            }
        }, label: {
            Image(.add)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .hAlign(alignment: .leading)
        })
    }
    
    func tabBarCancelButton() -> some View {
        Button {
            dismiss.callAsFunction()
        } label: {
            Text("Cancel")
        }
        .font(.helveticaRegular(size: 16))
        .foregroundColor(.white)
    }
    
    func tabBarSaveButton() -> some View {
        Button {
            viewModel.saveButtonAction(task: task, taskCheckboxes: &taskCheckboxes)
            dismiss.callAsFunction()
        } label: {
            Text("Save")
        }
        .font(.helveticaRegular(size: 16))
        .foregroundColor(.white)
    }
    
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: tabBarCancelButton(),
            header: NavigationTitle("Bullet list"),
            rightItem: tabBarSaveButton()
        )
    }
}

// MARK: - TextEditor

fileprivate struct TextEditor: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: NewCheckBoxViewModel
    @Binding var showAlert: Bool
    @Binding var checkbox: CheckboxDTO
    var isFieldOnFocus: Bool
    @FocusState var isFocus: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(.emptyCheckbox)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray)
                .frame(width: 13,height: 13)
            
            TextField("add a point", text: $checkbox.title)
                .lineLimit(1...10)
                .frame(minHeight: 35)
                .fixedSize(horizontal: false, vertical: true)
                .submitLabel(.done)
                .tint(themeManager.theme.sectionTextColor(colorScheme))
                .focused($isFocus)
            
            HStack {
                ThreeHorizontalLinesView()
                
                Button(action: {
                    isFocus = false
                    viewModel.deletedCheckbox = checkbox
                    showAlert = true
                }, label: {
                    Image(.trash)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.red)
                })
                .buttonStyle(.borderless)
                .frame(width: 20, height: 20)
            }
        }
        .onAppear {
            isFocus = isFieldOnFocus
        }
    }
}
