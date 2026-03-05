//
//  Note.swift
//  Career Pro
//

import Foundation
import SwiftData

@Model
class Note {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var reminderDate: Date?
    var isReminderSet: Bool

    init(title: String, content: String) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.reminderDate = nil
        self.isReminderSet = false
    }
}
