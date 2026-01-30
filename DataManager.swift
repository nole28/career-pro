//
//  DataManager.swift
//  Career Pro
//
//  Created by Novak Velimirovic on 30.1.26..
//

import Foundation
import SwiftUI

/// Manages persistent storage for job applications using UserDefaults
/// Uses Singleton pattern to ensure consistent data access across the app
class DataManager: ObservableObject {
    /// Shared instance for app-wide data access
    static let shared = DataManager()
    
    /// Published array of job applications that automatically updates UI when changed
    @Published var applications: [JobApplication] = []
    
    /// Load saved data when DataManager is initialized
    init() {
        load()
    }
    
    /// Adds a new job application to the beginning of the list
    /// - Parameter job: The job application to add
    func add(_ job: JobApplication) {
        // Insert at position 0 so newest jobs appear first
        applications.insert(job, at: 0)
        save()
    }
    
    /// Removes a job application from the list
    /// - Parameter job: The job application to delete
    func delete(_ job: JobApplication) {
        applications.removeAll { $0.id == job.id }
        save()
    }
    
    /// Toggles the favorite status of a job application
    /// - Parameter job: The job application to update
    func toggleFavorite(_ job: JobApplication) {
        if let index = applications.firstIndex(where: { $0.id == job.id }) {
            applications[index].isFavorite.toggle()
            save()
        }
    }
    
    /// Saves current applications to UserDefaults
    private func save() {
        // Encode to JSON and store in UserDefaults
        if let encoded = try? JSONEncoder().encode(applications) {
            UserDefaults.standard.set(encoded, forKey: "savedJobs")
        }
    }
    
    /// Loads saved applications from UserDefaults
    private func load() {
        // Retrieve and decode JSON data from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "savedJobs"),
           let decoded = try? JSONDecoder().decode([JobApplication].self, from: data) {
            applications = decoded
        }
    }
}
