//
//  PrivacyPolicyButton.swift
//  Agile Task
//
//  Created by Artur Korol on 07.03.2024.
//

import SwiftUI

struct PrivacyPolicyButton: View {
    var body: some View {
        if let url = URL(string: Constants.shared.privacyPolicyURL) {
            Link("Privacy Policy", destination: url)
        }
    }
}

#Preview {
    PrivacyPolicyButton()
}
