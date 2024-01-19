//
//  ProjectRow.swift
//  Agile Task
//
//  Created by Artur Korol on 29.12.2023.
//

import SwiftUI

struct ProjectRow: View {
    @StateObject var vm: ProjectsViewModel
    var project: ProjectDTO
    @State var isShowingDeleteAlert = false
    
    var body: some View {
        Button {
            vm.selectProject(project)
        } label: {
            HStack(spacing: 5) {
                if project.isSelected { checkMark }
                
                Text(project.name)
                    .font(.helveticaRegular(size: 16))
            }
        }
        .swipeActions {
            if !project.isSelected {
                Button {
                    isShowingDeleteAlert = true
                } label: {
                    Image("trash")
                }
                .tint(Color.red)
            }
            
            NavigationLink {
                NewProjectView(vm: NewProjectViewModel(editedProject: project))
            } label: {
                Image(.edit)
            }
            .tint(Color.editButtonColor)
        }
        .alert("Are you sure you want to delete", isPresented: $isShowingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            
            Button("Delete") {
                vm.deleteProject(project)
            }
        }
    }
    
    var checkMark: some View {
        Image("Check")
            .resizable()
            .scaledToFit()
            .frame(width: 15, height: 15)
    }
}
