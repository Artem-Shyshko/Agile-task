//
//  File.swift
//  Agile Task
//
//  Created by Artur Korol on 29.12.2023.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = MFMailComposeViewController
    
    // MARK: - Methods
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let view = MFMailComposeViewController()
        view.mailComposeDelegate = context.coordinator
        view.setToRecipients(["SENDTO@gmail.com"])
        view.setSubject("Master Task")
        view.setMessageBody("", isHTML: false)
        return view
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
}
