//
//  Font+Ext.swift
//  Agile Task
//
//  Created by Artur Korol on 08.08.2023.
//

import SwiftUI

extension Font {
    static func sfProRegular(size: CGFloat) -> Font {
        .custom("SF-Pro", fixedSize: size)
    }
    static func helveticaRegular(size: CGFloat) -> Font {
        .custom("Helvetica", fixedSize: size)
    }
    static func helveticaBold(size: CGFloat) -> Font {
        .custom("Helvetica-Bold", fixedSize: size)
    }
}
