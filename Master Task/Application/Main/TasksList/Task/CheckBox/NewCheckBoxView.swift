//
//  NewCheckBoxView.swift
//  Master Task
//
//  Created by Artur Korol on 30.10.2023.
//

import SwiftUI
import RealmSwift

struct NewCheckBoxView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var theme: AppThemeManager
    @StateObject var viewModel: NewCheckBoxViewModel
    @Binding var taskCheckboxes: [CheckboxDTO]
    @Binding var isShowing: Bool
    var task: TaskDTO?
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedInput: Int?
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            navigationBar()
            checkBoxesList()
        }
        .modifier(TabViewChildModifier())
        .onAppear(perform: {
            viewModel.checkboxes = taskCheckboxes
            
            if $viewModel.checkboxes.isEmpty {
                viewModel.checkboxes.append(CheckboxDTO(object: CheckboxObject(title: "")))
                focusedInput = 0
            }
        })
        .alert("Are you sure you want to delete task?", isPresented: $viewModel.showDeleteAlert) {
            Button {
                viewModel.showDeleteAlert = false
            } label: {
                Text("Cancel")
            }
            
            Button {
                viewModel.trashButtonAction(task: task, index: viewModel.deletedCheckboxIndex)
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
                    .fill(Color(theme.selectedTheme.sectionColor.name))
            )
        }
        .listStyle(.plain)
        .listRowSpacing(Constants.shared.listRowSpacing)
    }
    
    func textEditor(index: Int) -> some View {
        HStack(spacing: 4) {
            Image(.emptyCheckbox)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray)
                .frame(width: 13,height: 13)
            
            TextField("Write check point title", text: $viewModel.checkboxes[index].title)
                .lineLimit(1...10)
                .frame(minHeight: 35)
                .fixedSize(horizontal: false, vertical: true)
                .submitLabel(.done)
                .tint(theme.selectedTheme.sectionTextColor)
            
            HStack {
                ThreeHorizontalLinesView()
                trashButton(index: index)
            }
            .disabled(focusedInput == index)
        }
    }
    
    func trashButton(index: Int) -> some View {
        Button(action: {
            viewModel.deletedCheckboxIndex = index
            viewModel.showDeleteAlert = true
        }, label: {
            Image("trash")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(focusedInput == index ? .gray.opacity(0.5) : .red)
        })
        .buttonStyle(.borderless)
        .frame(width: 20, height: 20)
    }
    
    func listOfTextEditor() -> some View {
        ForEach($viewModel.checkboxes.indices, id: \.self) { index in
            textEditor(index: index)
                .id(viewModel.checkboxes[index].id)
                .focused($focusedInput, equals: index)
            
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
            Image(systemName: "plus")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .bold()
                .frame(width: 10, height: 10)
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
    }
    
    func tabBarSaveButton() -> some View {
        Button {
            viewModel.saveButtonAction(task: task, taskCheckboxes: &taskCheckboxes)
            dismiss.callAsFunction()
        } label: {
            Text("Save")
        }
        .font(.helveticaRegular(size: 16))
    }
    
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: tabBarCancelButton(),
            header: NavigationTitle("Check list"),
            rightItem: tabBarSaveButton()
        )
    }
}

// MARK: - Preview

#Preview {
    NewCheckBoxView(viewModel: NewCheckBoxViewModel(), taskCheckboxes: .constant([]), isShowing: .constant(true))
        .environmentObject(AppThemeManager())
}
