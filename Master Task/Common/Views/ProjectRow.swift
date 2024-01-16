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
    
    var body: some View {
        Button {
            vm.selectAnotherProject(project)
        } label: {
            HStack(spacing: 5) {
                if project.isSelected { checkMark }
                
                Text(project.name)
            }
            .modifier(SectionStyle())
        }
        .swipeActions {
            NavigationLink {
                NewProjectView(vm: NewProjectViewModel(editedProject: project))
            } label: {
                Image("done-checkbox")
            }
            .tint(Color.editButtonColor)
            
            if !project.isSelected {
                Button {
                    vm.isAlert = true
                } label: {
                    Image("trash")
                }
                .tint(Color.red)
            }
        }
        .alert("Are you sure you want to delete", isPresented: $vm.isAlert) {
            Button("Cancel", role: .cancel) {
                vm.isAlert = false
            }
            
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
