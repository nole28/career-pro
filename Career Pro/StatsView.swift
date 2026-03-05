//
//  StatsView.swift
//  Career Pro
//

import SwiftUI

struct StatsView: View {
    let applications: [JobApplication]

    private var interviewsCount: Int {
        applications.filter { $0.status == Status.interview.rawValue }.count
    }

    private var offersCount: Int {
        applications.filter {
            $0.status == Status.offer.rawValue || $0.status == Status.accepted.rawValue
        }.count
    }

    private var rejectionsCount: Int {
        applications.filter { $0.status == Status.rejected.rawValue }.count
    }

    private var successRate: String {
        guard applications.count > 0 else { return "0%" }
        let rate = Double(offersCount) / Double(applications.count) * 100
        return String(format: "%.1f%%", rate)
    }

    var body: some View {
        NavigationView {
            List {
                Section("Overview") {
                    StatRow(title: "Total Applications", value: "\(applications.count)", icon: "briefcase", color: .blue)
                    StatRow(title: "Interviews", value: "\(interviewsCount)", icon: "message", color: .orange)
                    StatRow(title: "Offers", value: "\(offersCount)", icon: "gift", color: .green)
                    StatRow(title: "Rejections", value: "\(rejectionsCount)", icon: "xmark", color: .red)
                }

                Section("Performance") {
                    StatRow(title: "Success Rate", value: successRate, icon: "chart.line.uptrend.xyaxis", color: .purple)
                    StatRow(title: "Interview Rate", value: applications.count > 0 ? "\(Int(Double(interviewsCount) / Double(applications.count) * 100))%" : "0%", icon: "person.wave.2", color: .orange)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            Text(title)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
    }
}
