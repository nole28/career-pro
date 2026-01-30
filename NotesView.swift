//
//  NotesView.swift
//  Career Pro
//
//  Created by Novak Velimirovic on 30.1.26..
//

import SwiftUI

/// View for managing notes with search, reminders, and persistent storage
struct NotesView: View {
    /// Local storage for notes (separate from job applications)
    @State private var notes: [Note] = []
    
    /// Controls visibility of add note sheet
    @State private var showingAddNote = false
    
    /// Text input for filtering notes
    @State private var searchText = ""
    
    /// Filters notes based on search query
    var filteredNotes: [Note] {
        if searchText.isEmpty { return notes }
        return notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                // Show empty state or list based on note count
                if notes.isEmpty {
                    emptyStateView
                } else {
                    notesListView
                }
            }
            .navigationTitle("Notes")
            .searchable(text: $searchText, prompt: "Search notes...")
            .toolbar {
                // Add note button
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddNote = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                // Pass callback to insert new note at top
                AddNoteView(onSave: { note in
                    notes.insert(note, at: 0)
                    saveNotes()
                })
            }
            .onAppear {
                // Load saved notes when view appears
                loadNotes()
            }
        }
    }
    
    /// List view displaying all notes with reminders
    private var notesListView: some View {
        List {
            ForEach(filteredNotes) { note in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        // Note title
                        Text(note.title)
                            .font(.headline)
                            .lineLimit(1)
                        Spacer()
                        
                        // Reminder indicator
                        if note.hasReminder {
                            Image(systemName: "bell.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Note content preview
                    Text(note.content)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        // Creation date
                        Text(note.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        // Reminder date if set
                        if let reminder = note.reminderDate {
                            Spacer()
                            Text("Reminder: \(reminder, style: .date) \(reminder, style: .time)")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.vertical, 6)
                .swipeActions {
                    // Swipe to delete action
                    Button(role: .destructive) {
                        deleteNote(note)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
    
    /// Empty state shown when no notes exist
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            // Visual empty state icon
            Image(systemName: "note.text")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Notes Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Tap the pencil icon to add your first note")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Call to action button
            Button(action: { showingAddNote = true }) {
                Label("Add Note", systemImage: "plus")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)
        }
    }
    
    /// Loads notes from UserDefaults storage
    private func loadNotes() {
        // Retrieve and decode saved notes, sort by newest first
        if let data = UserDefaults.standard.data(forKey: "savedNotes"),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            notes = decoded.sorted { $0.createdAt > $1.createdAt }
        }
    }
    
    /// Saves current notes to UserDefaults
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "savedNotes")
        }
    }
    
    /// Deletes a specific note from storage
    /// - Parameter note: The note to remove
    private func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
}

/// View for creating new notes with reminder options
struct AddNoteView: View {
    /// Dismisses the sheet
    @Environment(\.dismiss) var dismiss
    
    /// Callback to pass the saved note back to parent
    let onSave: (Note) -> Void
    
    /// Form field states
    @State private var title = ""
    @State private var content = ""
    @State private var addReminder = false
    @State private var reminderDate = Date().addingTimeInterval(3600) // Default: 1 hour from now
    
    var body: some View {
        NavigationView {
            Form {
                // Title and content section
                Section {
                    TextField("Title", text: $title)
                        .font(.headline)
                    
                    TextEditor(text: $content)
                        .frame(height: 150)
                        .overlay(
                            // Placeholder text when content is empty
                            Group {
                                if content.isEmpty {
                                    Text("What's on your mind?")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 4)
                                        .padding(.top, 8)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                // Reminder toggle and date picker
                Section("Reminder") {
                    Toggle("Set Reminder", isOn: $addReminder)
                    
                    if addReminder {
                        DatePicker("Date & Time", selection: $reminderDate, in: Date()...)
                            .datePickerStyle(.compact)
                        
                        // Quick-set buttons for common times
                        HStack {
                            Button("1 hour") {
                                reminderDate = Date().addingTimeInterval(3600)
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                            
                            Button("Tomorrow 9 AM") {
                                setTomorrow9AM()
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                            
                            Button("This weekend") {
                                setThisWeekend()
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                        }
                    }
                }
                
                // Live preview of note content
                if !content.isEmpty {
                    Section("Preview") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(title.isEmpty ? "Untitled" : title)
                                .font(.headline)
                            
                            Text(content)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                // Save button (disabled if title empty)
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    /// Creates and saves a new note
    private func saveNote() {
        let note = Note(
            title: title,
            content: content,
            reminderDate: addReminder ? reminderDate : nil
        )
        onSave(note)
        dismiss()
    }
    
    /// Sets reminder date to tomorrow at 9:00 AM
    private func setTomorrow9AM() {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.day = (components.day ?? 0) + 1
        components.hour = 9
        components.minute = 0
        reminderDate = Calendar.current.date(from: components) ?? Date().addingTimeInterval(86400)
    }
    
    /// Sets reminder date to the upcoming Saturday
    private func setThisWeekend() {
        let today = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: today)
        let daysUntilSaturday = (7 - weekday + 7) % 7
        reminderDate = calendar.date(byAdding: .day, value: daysUntilSaturday, to: today) ?? today
    }
}

#Preview {
    NotesView()
}
