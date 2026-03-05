//
//  CareerProApp.swift
//  Career Pro
//

import SwiftUI
import SwiftData

@main
struct CareerProApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .modelContainer(for: Note.self)
        }
    }
}
