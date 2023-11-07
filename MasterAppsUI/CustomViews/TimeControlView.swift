//
//  TimeControlView.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 06.10.2023.
//

import SwiftUI

public struct TimeControlView: View {
    var title: String
    var leftButtonAction: () -> Void
    var rightButtonAction: () -> Void
    
    public init(title: String, leftButtonAction: @escaping () -> Void, rightButtonAction: @escaping () -> Void) {
        self.title = title
        self.leftButtonAction = leftButtonAction
        self.rightButtonAction = rightButtonAction
    }
    
    public var body: some View {
        HStack {
            Button {
                leftButtonAction()
            } label: {
                Image("Arrow Left")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 45)
            }
            
            Text(title)
                .font(.helveticaRegular(size: 16))
                .frame(width: 110)
            
            Button {
                rightButtonAction()
            } label: {
                Image("Arrow Right")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 45)
            }
        }
    }
}

struct TimeControlView_Previews: PreviewProvider {
    static var previews: some View {
        TimeControlView(title: "Monday", leftButtonAction: {}, rightButtonAction: {})
            .previewLayout(.sizeThatFits)
            .background(.red)
    }
}
