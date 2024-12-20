//
//  TipView.swift
//  agile-budget
//
//  Created by Artur Korol on 17.06.2024.
//

import SwiftUI

enum TipViewArrowEdge {
    case top, bottom, leading, trailing
}

struct TipView: View {
    var title: String
    var arrowEdge: TipViewArrowEdge
    var spacing: CGFloat = 45
    @State var isShowing = true
    private let triangleSize: CGFloat = 15
    
    var body: some View {
        ZStack {
            if isShowing {
                Button(action: {
                    isShowing = false
                    UserDefaults.standard.set(isShowing, forKey: title)
                }, label: {
                    HStack {
                        Text(title.localized)
                            .font(.helveticaRegular(size: 16))
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(size: 8)
                            .bold()
                    }
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(Color(.lightRed))
                    .cornerRadius(10)
                })
                .padding(edge(), spacing)
            }
        }
        .onAppear {
            isShowing = UserDefaults.standard.value(forKey: title) as? Bool ?? true
        }
    }
}

private extension TipView {
    func edge() -> Edge.Set {
        switch arrowEdge {
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }
}

#Preview {
    TipView(title: " dsa", arrowEdge: .bottom)
}

extension String {
    var localized: LocalizedStringKey {
        LocalizedStringKey(self)
    }
}
