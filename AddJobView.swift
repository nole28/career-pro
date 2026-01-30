//
//  AddJobView.swift
//  Career Pro
//
//  Created by Novak Velimirovic on 30.1.26..
//

import SwiftUI

/// Form for adding new job applications with validation and keyboard management
struct AddJobView: View {
    /// Dismisses the sheet when job is saved or cancelled
    @Environment(\.dismiss) var dismiss
    
    /// Form field states
    @State private var company = ""
    @State private var role = ""
    @State private var url = ""
    @State private var status: Status = .interested
    @State private var notes = ""
    
    /// Tracks which text field is currently focused for keyboard navigation
    @FocusState private var focusedField: Field?
    
    /// Enum for tracking focused fields in the form
    enum Field {
        case company, role, url, notes
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Company and role details section
                Section("Job Details") {
                    TextField("Company", text: $company)
                        .focused($focusedField, equals: .company)
                        .submitLabel(.next)
                    
                    TextField("Role", text: $role)
                        .focused($focusedField, equals: .role)
                        .submitLabel(.next)
                    
                    TextField("URL (optional)", text: $url)
                        .focused($focusedField, equals: .url)
                        .keyboardType(.URL)
                        .submitLabel(.next)
                }
                
                // Status selection picker
                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(Status.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Optional notes section
                Section("Notes") {
                    TextEditor(text: $notes)
                        .focused($focusedField, equals: .notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                // Save button (disabled if required fields empty)
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveJob()
                        dismiss()
                    }
                    .disabled(company.isEmpty || role.isEmpty)
                }
                
                // Keyboard toolbar for better navigation
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .onAppear {
                // Auto-focus company field when view appears
                focusedField = .company
            }
        }
    }
    
    /// Validates and saves the new job application
    private func saveJob() {
        let job = JobApplication(
            company: company.trimmingCharacters(in: .whitespacesAndNewlines),
            role: role.trimmingCharacters(in: .whitespacesAndNewlines),
            url: url.trimmingCharacters(in: .whitespacesAndNewlines),
            status: status
        )
        
        // Add to shared data manager
        DataManager.shared.add(job)
    }
}

#Preview {
    AddJobView()
}
