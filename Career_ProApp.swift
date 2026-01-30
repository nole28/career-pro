//
//  Career_ProApp.swift
//  Career Pro
//
//  Created by Novak Velimirovic on 30.1.26..
//

import SwiftUI
import SwiftData

/// Main app entry point - defines the app structure and initial view
@main
struct CareerProApp: App {
    var body: some Scene {
        WindowGroup {
            // HomeView is the main screen that launches when app starts
            HomeView()
        }
    }
}
