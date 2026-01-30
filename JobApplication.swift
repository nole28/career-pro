//
//  JobApplication.swift
//  Career Pro
//
//  Created by Novak Velimirovic on 30.1.26..
//

import Foundation

/// Represents the current status of a job application with emoji indicators
enum Status: String, CaseIterable, Codable {
    case interested = "⭐️ Interested"
    case applied = "📤 Applied"
    case interview = "🎤 Interview"
    case offer = "💰 Offer"
    case rejected = "❌ Rejected"
    case accepted = "✅ Accepted"
}

/// Main data model representing a job application
/// Conforms to Codable for easy JSON encoding/decoding with UserDefaults
struct JobApplication: Identifiable, Codable {
    /// Unique identifier for each job application
    var id = UUID()
    
    /// Company name where the job is located
    var company: String
    
    /// Job position or role title
    var role: String
    
    /// Optional URL to the job posting
    var url: String
    
    /// Date when the application was submitted
    var appliedDate: Date
    
    /// Optional follow-up date for reminders
    var nextStep: Date?
    
    /// Current status from the Status enum
    var status: String
    
    /// Array of notes attached to this application
    var notes: [Note] = []
    
    /// Whether this job is marked as a favorite
    var isFavorite: Bool = false
    
    /// Creates a new job application with default values
    /// - Parameters:
    ///   - company: The company name
    ///   - role: The job position
    ///   - url: Optional job posting URL
    ///   - status: Initial application status (defaults to interested)
    init(company: String, role: String, url: String = "", status: Status = .interested) {
        self.company = company
        self.role = role
        self.url = url
        self.appliedDate = Date()
        self.status = status.rawValue
    }
}
