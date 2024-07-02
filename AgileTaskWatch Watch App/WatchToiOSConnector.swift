//
//  WatchToiOSConnector.swift
//  AgileTaskWatch Watch App
//
//  Created by Artur Korol on 27.06.2024.
//

import Foundation
import WatchConnectivity

class WatchToiOSConnector: NSObject, ObservableObject {
    var session: WCSession
    @Published var tasks: [String] = []
    private let userDefaults = UserDefaults.standard
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
}

extension WatchToiOSConnector: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error {
            print("session activation failed with error: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        guard let tasks = applicationContext["tasks"] as? [String] else {
            return
          }
        
        Task {
            await MainActor.run {
                    print(tasks)
                self.tasks = tasks
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        guard let tasks = userInfo["tasks"] as? [String] else {
            return
          }
        
        Task {
            await MainActor.run {
                    print(tasks)
                self.tasks = tasks
            }
        }
    }
}
