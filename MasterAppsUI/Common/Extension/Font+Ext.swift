//
//  Font+Ext.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 13.10.2023.
//

import SwiftUI

extension Font {
    static func helveticaRegular(size: CGFloat) -> Font {
        .custom("Helvetica", fixedSize: size)
    }
    static func helveticaBold(size: CGFloat) -> Font {
        .custom("Helvetica-Bold", fixedSize: size)
    }
}
