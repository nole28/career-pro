//
//  SettingsView.swift
//  Career Pro
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        NavigationView {
            List {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }

                    Link("GitHub", destination: URL(string: "https://github.com/nole28")!)
                }

                Section("Data") {
                    Button(role: .destructive) {
                        DataManager.shared.applications.removeAll()
                        UserDefaults.standard.removeObject(forKey: "savedJobs")
                    } label: {
                        Label("Clear All Data", systemImage: "trash")
                    }
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
