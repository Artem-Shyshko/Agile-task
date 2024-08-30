//
//  InfoView.swift
//  Agile Task
//
//  Created by USER on 22.04.2024.
//

import SwiftUI

struct InfoView: View {
    // MARK: - Properties
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: FieldsInfoViewModel
    
    @Binding var copyText: String
    @Binding var isSharePresented: Bool
    @Binding var isTextCopied: Bool
    
    // MARK: - Body
    var body: some View {
        listOfTextEditor()
    }
}
// MARK: - Private Views
private extension InfoView {
    func listOfTextEditor() -> some View {
        ForEach($viewModel.fieldArray, id: \.id) { field in
            FieldViewer(viewModel: viewModel,
                        field: field,
                        copyText: $copyText,
                        isSharePresented: $isSharePresented,
                        isTextCopied: $isTextCopied)
        }
    }
}

// MARK: - FieldEditor
fileprivate struct FieldViewer: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: FieldsInfoViewModel
    @Binding var field: FieldInfoModel
    @Binding var copyText: String
    @Binding var isSharePresented: Bool
    @Binding var isTextCopied: Bool
    
    var body: some View {
        if field.type == .date {
            calendarFieldView()
        } else if field.type == .bulletList {
            bulletListView()
        } else {
            returnPasswordView()
        }
    }
}

// MARK: - Private views
private extension FieldViewer {
    @ViewBuilder
    func returnPasswordView() -> some View {
        defaultField()
    }
    
    func defaultField() -> some View {
        HStack(spacing: 4) {
            Text(LocalizedStringKey(field.type.rawValue))
                .font(.helveticaLight(size: 16))
            Spacer()
            Text(field.title)
                .tint(themeManager.theme.sectionTextColor(colorScheme))
            copyButtons()
        }
    }
    
    func bulletListView() -> some View {
        HStack(spacing: 5) {
            Text("info_bulletlist")
                .font(.helveticaLight(size: 16))
            Spacer()
            copyButtons()
        }
        .tint(themeManager.theme.sectionTextColor(colorScheme))
        .foregroundColor(themeManager.theme.sectionTextColor(colorScheme))
    }
    
    func calendarFieldView() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            HStack(spacing: 5) {
                Text(LocalizedStringKey(field.type.rawValue))
                    .font(.helveticaLight(size: 16))
                Spacer()
                Text(field.title)
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.selectedGrey)))
                copyButtons()
            }
            .tint(themeManager.theme.sectionTextColor(colorScheme))
            .foregroundStyle( themeManager.theme.sectionTextColor(colorScheme))
        }
    }
    
    func copyButtons() -> some View {
        HStack {
            Button {
                copyText = "\(field.typeTitle): \(field.title)"
                isSharePresented = true
            } label: {
                Image(.shareRecord)
            }
            .buttonStyle(.borderless)
            
            Button {
                copyText = "\(field.typeTitle): \(field.title)"
                isTextCopied = true
            } label: {
                Image(.copyRecord)
            }
            .buttonStyle(.borderless)
        }
    }
}

