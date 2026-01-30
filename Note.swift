//
//  Note.swift
//  Career Pro
//
//  Created by Novak Velimirovic on 30.1.26..
//

import Foundation

/// Data model representing a standalone note with optional reminder
/// Conforms to Codable for UserDefaults persistence
struct Note: Identifiable, Codable {
    /// Unique identifier for each note
    var id = UUID()
    
    /// Note title or heading
    var title: String
    
    /// Main content of the note
    var content: String
    
    /// When the note was created (automatically set)
    var createdAt: Date
    
    /// Optional date for reminder notification
    var reminderDate: Date?
    
    /// Whether a reminder is set (computed from reminderDate)
    var hasReminder: Bool = false
    
    /// Creates a new note with optional reminder
    /// - Parameters:
    ///   - title: The note title
    ///   - content: The note content
    ///   - reminderDate: Optional date for reminder
    init(title: String, content: String, reminderDate: Date? = nil) {
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.reminderDate = reminderDate
        self.hasReminder = reminderDate != nil
    }
}
