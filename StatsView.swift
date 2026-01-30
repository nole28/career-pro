//
//  StatsView.swift
//  Career Pro
//
//  Created by Novak Velimirovic on 30.1.26..
//

import SwiftUI

/// View displaying application statistics and progress metrics
struct StatsView: View {
    /// Job applications to analyze (passed from parent view)
    let applications: [JobApplication]
    
    var body: some View {
        NavigationView {
            List {
                // Overview statistics section
                Section("Overview") {
                    StatRow(title: "Total Applications", value: "\(applications.count)", icon: "briefcase", color: .blue)
                    StatRow(title: "Interviews", value: "\(interviewsCount)", icon: "message", color: .orange)
                    StatRow(title: "Offers", value: "\(offersCount)", icon: "gift", color: .green)
                    StatRow(title: "Rejections", value: "\(rejectionsCount)", icon: "xmark", color: .red)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    /// Count of applications in interview stage
    private var interviewsCount: Int {
        applications.filter { $0.status == Status.interview.rawValue }.count
    }
    
    /// Count of applications with offers or accepted status
    private var offersCount: Int {
        applications.filter {
            $0.status == Status.offer.rawValue || $0.status == Status.accepted.rawValue
        }.count
    }
    
    /// Count of rejected applications
    private var rejectionsCount: Int {
        applications.filter { $0.status == Status.rejected.rawValue }.count
    }
}

/// Reusable row component for displaying statistic items
struct StatRow: View {
    /// Title of the statistic
    let title: String
    
    /// Value to display
    let value: String
    
    /// SF Symbol icon name
    let icon: String
    
    /// Color for icon and value
    let color: Color
    
    var body: some View {
        HStack {
            // Icon with consistent spacing
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            // Statistic title
            Text(title)
            
            Spacer()
            
            // Statistic value with emphasis
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
    }
}


