//
//  AddJobView.swift
//  Career Pro
//

import SwiftUI

struct AddJobView: View {
    @Environment(\.dismiss) var dismiss

    @State private var company = ""
    @State private var role = ""
    @State private var url = ""
    @State private var status: Status = .interested
    @State private var notes = ""
    @FocusState private var focusedField: Field?

    enum Field {
        case company, role, url, notes
    }

    var body: some View {
        NavigationView {
            Form {
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
                        .autocapitalization(.none)
                        .submitLabel(.next)
                }

                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(Status.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .focused($focusedField, equals: .notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveJob()
                        dismiss()
                    }
                    .disabled(company.isEmpty || role.isEmpty)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
            .onAppear {
                focusedField = .company
            }
        }
    }

    private func saveJob() {
        let job = JobApplication(
            company: company.trimmingCharacters(in: .whitespacesAndNewlines),
            role: role.trimmingCharacters(in: .whitespacesAndNewlines),
            url: url.trimmingCharacters(in: .whitespacesAndNewlines),
            status: status
        )
        DataManager.shared.add(job)
    }
}

#Preview {
    AddJobView()
}
