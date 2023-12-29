//
//  ProjectRow.swift
//  Agile Task
//
//  Created by Artur Korol on 29.12.2023.
//

import SwiftUI

struct ProjectRow: View {
    @EnvironmentObject var userState: UserState
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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    var checkMark: some View {
        Image("Check")
            .resizable()
            .scaledToFit()
            .frame(width: 12, height: 12)
    }
}
