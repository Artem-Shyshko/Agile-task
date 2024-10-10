//
//  ProjectRow.swift
//  Agile Task
//
//  Created by Artur Korol on 29.12.2023.
//

import SwiftUI

struct ProjectRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var vm: ProjectsViewModel
    var project: ProjectDTO
    @State var isShowingDeleteAlert = false
    @Binding var path: [ProjectNavigation]
    
    var body: some View {
        Button {
            vm.selectProject(project)
        } label: {
            GeometryReader { geometry in
                HStack(alignment: .center, spacing: 5) {
                    if project.isSelected { checkMark }
                    
                    Text(project.name)
                        .font(.helveticaRegular(size: 16))
                        .foregroundStyle(themeManager.theme.sectionTextColor(colorScheme))
                    Spacer()
                }
                .frame(width: geometry.size.width)
                .padding(.top, 8)
                .overlay(alignment: .trailingLastTextBaseline, content: {
                    Button {
                        path.append(.newProject(editHabit: project))
                    } label: {
                        Image(.swipes)
                            .frame(size: 20)
                    }
                    .offset(x: setOffsetForSwipesButton(), y: 4)
                    .buttonStyle(.borderless)
                })
            }
        }
        .swipeActions {
            if !project.isSelected {
                Button {
                    isShowingDeleteAlert = true
                } label: {
                    Image("trash")
                }
                .tint(Color.white)
            }
            
            NavigationLink {
                NewProjectView(vm: NewProjectViewModel(appState: vm.appState, editedProject: project))
            } label: {
                Image(.edit)
            }
            .tint(Color.white)
        }
        .alert("Are you sure you want to delete", isPresented: $isShowingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            
            Button("Delete") {
                vm.deleteProject(project)
            }
        }
        .padding(.horizontal, Constants.shared.listRowHorizontalPadding)
//        .listRowBackground(
//            RoundedRectangle(cornerRadius: 4)
//                .fill(themeManager.theme.sectionColor(colorScheme))
//                .padding(.trailing, 10)
//            .overlay(alignment: .trailing   , content: {
//                Image(.swipes)
//                    .onTapGesture {
//                        path.append(.newProject(editHabit: project))
//                    }
//            })
//        )
//        .padding(.trailing, 10)
        
        .listRowBackground(
            RoundedRectangle(cornerRadius: 4)
                .fill(themeManager.theme.sectionColor(colorScheme))
                .padding(.trailing, 12)
        )
        .padding(.trailing, 12)
//        .overlay(alignment: .trailing, content: {
//            Button {
////                path.append(.createTask(editedTask: task))
//            } label: {
//                Image(.swipes)
//                    .padding(.trailing, 2)
//                    .frame(size: 20)
//            }
////            .offset(x: 25)
//            .buttonStyle(.borderless)
//        })
    }
    
    var checkMark: some View {
        Image("Check")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 15, height: 15)
            .foregroundStyle(themeManager.theme.sectionTextColor(colorScheme))
    }
    
    func setOffsetForSwipesButton() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.size.width
        // different value for iPads and phones with smaller width
        return (screenWidth < 744 && screenWidth > 400) ? 26 : 21.5
    }
}
