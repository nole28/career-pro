//
//  DataManager.swift
//  Career Pro
//

import Foundation
import SwiftUI

class DataManager: ObservableObject {
    static let shared = DataManager()

    @Published var applications: [JobApplication] = []

    init() {
        load()
    }

    func add(_ job: JobApplication) {
        applications.insert(job, at: 0)
        save()
    }

    func delete(_ job: JobApplication) {
        applications.removeAll { $0.id == job.id }
        save()
    }

    func toggleFavorite(_ job: JobApplication) {
        if let index = applications.firstIndex(where: { $0.id == job.id }) {
            applications[index].isFavorite.toggle()
            save()
        }
    }

    func updateStatus(_ job: JobApplication, status: Status) {
        if let index = applications.firstIndex(where: { $0.id == job.id }) {
            applications[index].status = status.rawValue
            save()
        }
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(applications) {
            UserDefaults.standard.set(encoded, forKey: "savedJobs")
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: "savedJobs"),
           let decoded = try? JSONDecoder().decode([JobApplication].self, from: data) {
            applications = decoded
        }
    }
}
