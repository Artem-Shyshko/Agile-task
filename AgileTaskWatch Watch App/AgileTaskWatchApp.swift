//
//  AgileTaskWatchApp.swift
//  AgileTaskWatch Watch App
//
//  Created by Artur Korol on 26.06.2024.
//

import SwiftUI

@main
struct AgileTask_Watch_App: App {
    @StateObject var connector = WatchToiOSConnector()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connector)
        }
    }
}
