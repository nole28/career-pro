//
//  JobApplication.swift
//  Career Pro
//

import Foundation

enum Status: String, CaseIterable, Codable {
    case interested = "⭐️ Interested"
    case applied = "📤 Applied"
    case interview = "🎤 Interview"
    case offer = "💰 Offer"
    case rejected = "❌ Rejected"
    case accepted = "✅ Accepted"
}

struct JobApplication: Identifiable, Codable {
    var id = UUID()
    var company: String
    var role: String
    var url: String
    var appliedDate: Date
    var nextStep: Date?
    var status: String
    var isFavorite: Bool = false

    init(company: String, role: String, url: String = "", status: Status = .interested) {
        self.company = company
        self.role = role
        self.url = url
        self.appliedDate = Date()
        self.status = status.rawValue
    }
}
