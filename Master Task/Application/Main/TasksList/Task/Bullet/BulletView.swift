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
    
    @EnvironmentObject var theme: AppThemeManager
    @StateObject var viewModel: BulletViewModel
    @Binding var taskBulletArray: [BulletDTO]
    @Binding var isShowing: Bool
    var task: TaskDTO?
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedInput: Int?
    
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
        .alert("Are you sure you want to delete bullet?", isPresented: $viewModel.showDeleteAlert) {
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

private extension BulletView {
    
    func textEditor(index: Int) -> some View {
        HStack(spacing: 4) {
            Image(.bullet)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray)
                .frame(width: 13,height: 13)
            
            TextField("Write bullet point title", text: $viewModel.bulletArray[index].title)
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
                    .fill(Color(theme.selectedTheme.sectionColor.name))
            )
        }
        .listStyle(.plain)
        .listRowSpacing(Constants.shared.listRowSpacing)
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
        ForEach($viewModel.bulletArray.indices, id: \.self) { index in
            textEditor(index: index)
                .id(viewModel.bulletArray[index].id)
                .focused($focusedInput, equals: index)
            
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
        .environmentObject(AppThemeManager())
}
