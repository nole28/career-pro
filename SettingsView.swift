//
//  SettingsView.swift
//  Career Pro
//
//  Created by Novak Velimirovic on 30.1.26..
//

import SwiftUI

/// App settings and configuration view
struct SettingsView: View {
    /// Dismisses the settings sheet
    @Environment(\.dismiss) private var dismiss
    
    /// Persistent storage for dark mode preference
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            List {
                // Appearance settings section
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                }
                
                // App information section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    // External link to GitHub repository
                    Link("GitHub", destination: URL(string: "https://github.com/yourusername")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
    }
}

#Preview {
    SettingsView()
}
