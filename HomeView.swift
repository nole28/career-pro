//
//  HomeView.swift
//  Career Pro
//
//  Created by Novak Velimirovic on 30.1.26..
//

import SwiftUI

/// Main screen displaying job applications with search, stats, and management features
struct HomeView: View {
    /// Shared data manager for loading and saving applications
    @StateObject private var dataManager = DataManager.shared
    
    /// Controls visibility of the add job sheet
    @State private var showingAddSheet = false
    
    /// Text input for searching through applications
    @State private var searchText = ""
    
    /// Filters applications based on search text
    var filteredApps: [JobApplication] {
        if searchText.isEmpty { return dataManager.applications }
        return dataManager.applications.filter {
            $0.company.localizedCaseInsensitiveContains(searchText) ||
            $0.role.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    /// Calculates application statistics for display
    var stats: (total: Int, interviews: Int, offers: Int) {
        let total = dataManager.applications.count
        let interviews = dataManager.applications.filter { $0.status == Status.interview.rawValue }.count
        let offers = dataManager.applications.filter {
            $0.status == Status.offer.rawValue || $0.status == Status.accepted.rawValue
        }.count
        return (total, interviews, offers)
    }
    
    var body: some View {
        NavigationView {
            List {
                // Statistics card showing quick overview
                Section {
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(stats.total)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                            .frame(height: 40)
                        
                        VStack {
                            Text("\(stats.interviews)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Text("Interviews")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                            .frame(height: 40)
                        
                        VStack {
                            Text("\(stats.offers)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Offers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
                // Main list of job applications
                ForEach(filteredApps) { app in
                    JobRow(app: app)
                        .swipeActions {
                            // Swipe to delete action
                            Button(role: .destructive) {
                                dataManager.delete(app)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            // Swipe to toggle favorite
                            Button {
                                dataManager.toggleFavorite(app)
                            } label: {
                                Label(app.isFavorite ? "Unstar" : "Star",
                                      systemImage: app.isFavorite ? "star.slash" : "star")
                            }
                            .tint(.yellow)
                        }
                }
            }
            .searchable(text: $searchText, prompt: "Search jobs...")
            .navigationTitle("Job Tracker")
            .toolbar {
                // Settings button in top left
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                
                // Add job button in top right
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
                
                // Bottom navigation bar
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack {
                        // Notes section link
                        NavigationLink {
                            NotesView()
                        } label: {
                            VStack {
                                Image(systemName: "note.text")
                                Text("Notes")
                                    .font(.caption2)
                            }
                            .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        // Statistics section link
                        NavigationLink {
                            StatsView(applications: dataManager.applications)
                        } label: {
                            VStack {
                                Image(systemName: "chart.bar")
                                Text("Stats")
                                    .font(.caption2)
                            }
                            .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        // Quick add shortcut
                        Button(action: { showingAddSheet = true }) {
                            VStack {
                                Image(systemName: "bolt.fill")
                                Text("Quick Add")
                                    .font(.caption2)
                            }
                            .foregroundColor(.purple)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddJobView()
            }
            .overlay {
                // Empty state when no jobs exist
                if dataManager.applications.isEmpty {
                    VStack {
                        Image(systemName: "briefcase")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .padding(.bottom, 8)
                        Text("No jobs yet")
                            .font(.title3)
                            .foregroundColor(.gray)
                        Button("Add your first job") {
                            showingAddSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)
                    }
                }
            }
        }
    }
}

/// Individual row view for displaying a job application in the list
struct JobRow: View {
    /// The job application to display
    let app: JobApplication
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                // Company logo circle with first letter
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Text(app.company.prefix(1))
                        .font(.headline)
                        .foregroundColor(statusColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(app.company)
                            .font(.headline)
                        Spacer()
                        // Favorite indicator
                        if app.isFavorite {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Text(app.role)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                // Status badge with colored background
                Text(app.status)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(4)
                
                Spacer()
                
                // Application date
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(app.appliedDate, style: .date)
                        .font(.caption)
                }
                .foregroundColor(.gray)
                
                // Follow-up date if set
                if let nextStep = app.nextStep {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "bell.fill")
                            .font(.caption2)
                        Text(nextStep, style: .date)
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    /// Returns color based on application status
    private var statusColor: Color {
        switch Status(rawValue: app.status) {
        case .interested: return .yellow
        case .applied: return .blue
        case .interview: return .orange
        case .offer: return .green
        case .rejected: return .red
        case .accepted: return .purple
        case nil: return .gray
        }
    }
}

#Preview {
    HomeView()
}
