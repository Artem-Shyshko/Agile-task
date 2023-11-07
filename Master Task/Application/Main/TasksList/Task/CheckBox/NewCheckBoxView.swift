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
    @Binding var checkBoxes: [CheckBoxObject]
    @ObservedResults(CheckBoxObject.self) var savedCheckBoxes
    
    @Environment(\.dismiss) var dismiss
    @FocusState var focusedInput: Int?
    var editedTask = false
    
    // MARK: - Body
    
    var body: some View {
        List {
            Group {
                listOfTextEditor()
                
                addPointButton()
            }
            .scrollContentBackground(.hidden)
        }
        .listStyle(.plain)
        .padding(.bottom, 10)
        .padding(.top, 30)
        .toolbar(.visible, for: .navigationBar)
        .navigationTitle("New Task")
        .modifier(TabViewChildModifier())
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                tabBarCancelButton()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                tabBarSaveButton()
            }
        }
        .onAppear(perform: {
            if checkBoxes.isEmpty {
                checkBoxes.append(CheckBoxObject(title: ""))
                focusedInput = 0
            }
        })
    }
}

// MARK: - Private views

private extension NewCheckBoxView {
    func textEditor(index: Int) -> some View {
        ZStack {
            TextField("New Check box", text: $checkBoxes[index].title, axis: .vertical)
                .focused($focusedInput, equals: index)
                .submitLabel(.next)
                .id(index)
                .onSubmit {
                    checkBoxes.append(CheckBoxObject(title: ""))
                    viewModel.onSubmit(checkBoxesCount: checkBoxes.count, textFieldIndex: index, focusedInput: &focusedInput)
                }
                .frame(minHeight: 35)
                .fixedSize(horizontal: false, vertical: true)
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
                .overlay(alignment: .leading) {
                    Image("empty-checkbox")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundColor(theme.selectedTheme.sectionTextColor)
                }
            
            Button {
                checkBoxes[index].title.append("\n")
            } label: {
                Image("enter")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(width: 13,height: 13)
                    .padding(.trailing, 16)
            }
            .frame(width: 13,height: 13)
            .hAlign(alignment: .trailing)
        }
    }
    
    func listOfTextEditor() -> some View {
        ForEach(checkBoxes.indices, id: \.self) { index in
            textEditor(index: index)
        }
    }
    
    func addPointButton() -> some View {
        Button(action: {
            checkBoxes.append(CheckBoxObject(title: ""))
            if focusedInput == nil {
                focusedInput = 0
            } else {
                focusedInput! += 1
            }
        }, label: {
            Text("add point")
                .hAlign(alignment: .leading)
                .padding(.leading, 20)
        })
    }
    
    func tabBarCancelButton() -> some View {
        Button {
            checkBoxes = [CheckBoxObject(title: "")]
            dismiss.callAsFunction()
        } label: {
            Text("Cancel")
        }
        .font(.helveticaRegular(size: 16))
    }
    
    func tabBarSaveButton() -> some View {
        Button {
            dismiss.callAsFunction()
        } label: {
            Text("Save")
        }
        .font(.helveticaRegular(size: 16))
    }
}

// MARK: - Preview

#Preview {
    NewCheckBoxView(viewModel: NewCheckBoxViewModel(), checkBoxes: .constant([CheckBoxObject(title: "")]))
        .environmentObject(AppThemeManager())
}
