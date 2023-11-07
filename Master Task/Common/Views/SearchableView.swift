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
    
    var body: some View {
        HStack(spacing: 5) {
            TextField("What are you looking for", text: $searchText)
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                .frame(height: 45)
                .cornerRadius(4)
                .overlay(alignment: .leading) {
                    Image(systemName: "magnifyingglass")
                        .imageScale(.small)
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
