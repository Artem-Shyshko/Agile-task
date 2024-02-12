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
        VStack {
            navigationBar()
            bulletsList()
        }
        .modifier(TabViewChildModifier())
        .onAppear(perform: {
            viewModel.bulletArray = taskBulletArray
            
            if $viewModel.bulletArray.isEmpty {
                viewModel.bulletArray.append(BulletDTO(object: BulletObject(title: "")))
                focusedInput = 0
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
            TextEditor(
                viewModel: viewModel,
                showAlert: $showDeleteAlert,
                bullet: bullet,
                isDisabledDeleteButton: focusedInput == viewModel.focusNumber(bullet: bullet.wrappedValue)
            )
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
            Image("Add")
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
    }
    
    func tabBarSaveButton() -> some View {
        Button {
            viewModel.saveButtonAction(task: task, taskBullets: &taskBulletArray)
            dismiss.callAsFunction()
        } label: {
            Text("Save")
        }
        .font(.helveticaRegular(size: 16))
    }
    
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: tabBarCancelButton(),
            header: NavigationTitle("Bullet list"),
            rightItem: tabBarSaveButton()
        )
    }
}

// MARK: - Preview

#Preview {
    BulletView(viewModel: BulletViewModel(), taskBulletArray: .constant([]), isShowing: .constant(true))
        .environmentObject(ThemeManager())
}

fileprivate struct TextEditor: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: BulletViewModel
    @Binding var showAlert: Bool
    @Binding var bullet: BulletDTO
    var isDisabledDeleteButton: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(.emptyCheckbox)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray)
                .frame(width: 13,height: 13)
            
            TextField("add a point", text: $bullet.title)
                .lineLimit(1...10)
                .frame(minHeight: 35)
                .fixedSize(horizontal: false, vertical: true)
                .submitLabel(.done)
                .tint(themeManager.theme.sectionTextColor(colorScheme))
            
            HStack {
                ThreeHorizontalLinesView()
                
                Button(action: {
                    viewModel.deletedBullet = bullet
                    showAlert = true
                }, label: {
                    Image("trash")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(isDisabledDeleteButton ? .gray.opacity(0.5) : .red)
                })
                .buttonStyle(.borderless)
                .frame(width: 20, height: 20)
            }
            .disabled(isDisabledDeleteButton)
        }
    }
}
