//
//  TermsOfUseButton.swift
//  Agile Task
//
//  Created by Artur Korol on 07.03.2024.
//

import SwiftUI

struct TermsOfUseButton: View {
    var body: some View {
        if let url = URL(string: Constants.shared.termsOfServiceURL) {
            Link("Terms of Service (EULA)", destination: url)
        }
    }
}

#Preview {
    TermsOfUseButton()
}
