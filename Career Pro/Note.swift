//
//  Note.swift
//  Career Pro
//

import Foundation

struct Note: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var createdAt: Date
    var reminderDate: Date?
    var hasReminder: Bool = false

    init(title: String, content: String, reminderDate: Date? = nil) {
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.reminderDate = reminderDate
        self.hasReminder = reminderDate != nil
    }
}
