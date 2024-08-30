//
//  ShareViewController.swift
//  Agile Task
//
//  Created by USER on 15.04.2024.
//

import Foundation

import SwiftUI

struct ShareViewController: UIViewControllerRepresentable {
    @Binding var textToCopy: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: [textToCopy], applicationActivities: nil)
        return activityViewController
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: Context) {

    }
}

