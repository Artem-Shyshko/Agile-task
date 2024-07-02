//
//  WatchConnector.swift
//  Agile Task
//
//  Created by Artur Korol on 27.06.2024.
//

import Foundation
import WatchConnectivity

class WatchConnector: NSObject, ObservableObject {
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
}

extension WatchConnector: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        session.activate()
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error {
            print("session activation failed with error: \(error.localizedDescription)")
        }
    }
    
    func sendTasks(_ tasks: [TaskDTO]) {
        let data: [String: [String]] = [
            "tasks": tasks
                .map(\.title)
        ]
        
        do {
            try session.updateApplicationContext(data)
        } catch {
            print(error)
        }
        session.transferUserInfo(data)
    }
}
