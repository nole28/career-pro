//
//  NotesListView.swift
//  Career Pro
//

import SwiftUI
import SwiftData

struct NotesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.createdAt, order: .reverse) private var notes: [Note]
    @StateObject private var notificationManager = NotificationManager.shared

    @State private var showingAddNote = false
    @State private var searchText = ""

    var filteredNotes: [Note] {
        if searchText.isEmpty { return notes }
        return notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var notesWithReminders: [Note] {
        notes.filter { $0.isReminderSet && $0.reminderDate ?? Date() > Date() }
            .sorted { ($0.reminderDate ?? Date()) < ($1.reminderDate ?? Date()) }
    }

    var body: some View {
        List {
            if !notesWithReminders.isEmpty {
                Section("🔔 Upcoming Reminders") {
                    ForEach(notesWithReminders) { note in
                        NoteRowView(note: note)
                    }
                }
            }

            Section("All Notes") {
                ForEach(filteredNotes) { note in
                    NoteRowView(note: note)
                }
                .onDelete(perform: deleteNotes)
            }
        }
        .searchable(text: $searchText, prompt: "Search notes...")
        .navigationTitle("Notes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddNote = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView()
        }
        .overlay {
            if notes.isEmpty {
                ContentUnavailableView(
                    "No Notes Yet",
                    systemImage: "note.text",
                    description: Text("Tap + to add your first note")
                )
            }
        }
    }

    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            let note = filteredNotes[index]
            notificationManager.cancelNotification(id: note.id.uuidString)
            modelContext.delete(note)
        }
    }
}

struct NoteRowView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(note.title)
                    .font(.headline)
                Spacer()
                if note.isReminderSet, let reminderDate = note.reminderDate {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text(reminderDate, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text(note.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Text(note.createdAt, style: .date)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct AddNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationManager = NotificationManager.shared

    @State private var title = ""
    @State private var content = ""
    @State private var hasReminder = false
    @State private var reminderDate = Date().addingTimeInterval(3600)

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextEditor(text: $content)
                        .frame(height: 150)
                }

                Section {
                    Toggle("Set Reminder", isOn: $hasReminder)
                    if hasReminder {
                        DatePicker("Remind at", selection: $reminderDate, in: Date()...)
                    }
                }
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveNote() {
        let note = Note(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        if hasReminder {
            note.reminderDate = reminderDate
            note.isReminderSet = true
            _ = notificationManager.scheduleNoteReminder(
                title: note.title,
                body: note.content,
                date: reminderDate
            )
        }
        modelContext.insert(note)
        dismiss()
    }
}
