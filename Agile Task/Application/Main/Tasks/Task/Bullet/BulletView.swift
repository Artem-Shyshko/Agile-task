//
//  BulletView.swift
//  Agile Task
//
//  Created by Artur Korol on 08.01.2024.
//

import SwiftUI
import RealmSwift

struct BulletView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: BulletViewModel
    @Binding var taskBulletArray: [BulletDTO]
    @Binding var isShowing: Bool
    var task: TaskDTO?
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedInput: Int?
    @State var showDeleteAlert = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Constants.shared.viewSectionSpacing) {
            navigationBar()
            bulletsList()
        }
        .modifier(TabViewChildModifier())
        .onAppear(perform: {
            viewModel.bulletArray = taskBulletArray
            
            if $viewModel.bulletArray.isEmpty {
                viewModel.bulletArray.append(BulletDTO(object: BulletObject(title: "")))
                focusedInput = 0
            } else {
                focusedInput = viewModel.bulletArray.count - 1
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
                focusedInput = viewModel.bulletArray.count - 1
            } label: {
                Text("Delete")
            }
        }
    }
}

// MARK: - Private views

private extension BulletView {
    
    func bulletsList() -> some View {
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
        ForEach($viewModel.bulletArray, id: \.id) { bullet in
            TextEditor(title: bullet.title, isFieldOnFocus: focusedInput == viewModel.focusNumber(bullet: bullet.wrappedValue)) {
                viewModel.showDeleteAlert = true
            }
            .focused(
                $focusedInput,
                equals: viewModel.focusNumber(bullet: bullet.wrappedValue)
            )
        }
        .onMove(perform: viewModel.move)
    }
    
    func addPointButton() -> some View {
        Button(action: {
            viewModel.bulletArray.append(BulletDTO(object: BulletObject(title: "")))
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
            viewModel.saveButtonAction(task: task, taskBullets: &taskBulletArray)
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

struct TextEditor: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var title: String
    var isFieldOnFocus: Bool
    @FocusState private var isFocus: Bool
    var action: ()->()
    
    var body: some View {
        HStack(spacing: 4) {
            Image(.emptyCheckbox)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray)
                .frame(width: 13,height: 13)
            
            TextField("add a point", text: $title)
                .lineLimit(1...10)
                .frame(minHeight: 35)
                .fixedSize(horizontal: false, vertical: true)
                .submitLabel(.done)
                .tint(themeManager.theme.sectionTextColor(colorScheme))
                .focused($isFocus)
            
            HStack {
                ThreeHorizontalLinesView()
                
                Button(action: {
                    action()
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
