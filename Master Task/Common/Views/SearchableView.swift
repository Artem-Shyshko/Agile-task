//
//  SearchableView.swift
//  Master Task
//
//  Created by Artur Korol on 02.11.2023.
//

import SwiftUI

struct SearchableView: View {
    @Binding var searchText: String
    @Binding var isSearchBarHidden: Bool
    @FocusState var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 5) {
            TextField("What are you looking for", text: $searchText)
                .focused($isFocused)
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                .frame(height: 45)
                .cornerRadius(4)
                .overlay(alignment: .leading) {
                    Image("Search")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .padding(.leading, 10.5)
                }
                .overlay(alignment: .trailing) {
                    Button {
                        searchText.removeAll()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.small)
                            .padding(.trailing, 9.5)
                    }
                }
                .onAppear {
                    isFocused = true
                }
            
            Button {
                isSearchBarHidden = true
                searchText.removeAll()
            } label: {
                Text("Cancel")
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 5)
    }
}

#Preview {
    SearchableView(searchText: .constant("Search"), isSearchBarHidden: .constant(true))
}
