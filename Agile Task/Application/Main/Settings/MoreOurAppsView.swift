//
//  File.swift
//  Agile Task
//
//  Created by Artur Korol on 29.12.2023.
//

import SwiftUI
import StoreKit

struct MoreOurAppsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview
    
    var body: some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            navigationBar()
            visitOurWebsiteButton()
            reviewOurAppsButton()
            leaveReviewButton()
            PrivacyPolicyButton()
                .modifier(SectionStyle())
            TermsOfUseButton()
                .modifier(SectionStyle())
            Spacer()
        }
        .modifier(TabViewChildModifier())
    }
}

// MARK: - Private views

private extension MoreOurAppsView {
    
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: backButton(),
            header: NavigationTitle("Settings"),
            rightItem: EmptyView()
        )
    }
    
    func backButton() -> some View {
        backButton {
            dismiss.callAsFunction()
        }
    }
    
    @ViewBuilder
    func visitOurWebsiteButton() -> some View {
        if let url = URL(string: Constants.shared.appURL) {
            Link("Visit our website", destination: url)
                .modifier(SectionStyle())
        }
    }
    
    @ViewBuilder
    func reviewOurAppsButton() -> some View {
        if let url = URL(string: Constants.shared.appStoreLink) {
            Link("Review our apps in the Apps store", destination: url)
                .modifier(SectionStyle())
        }
    }
    
    @MainActor func leaveReviewButton() -> some View {
        Button("Like the app? Please leave a review") {
            requestReview()
        }
        .modifier(SectionStyle())
    }
}

// MARK: - Preview

#Preview {
    MoreOurAppsView()
}
