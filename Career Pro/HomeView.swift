//
//  HomeView.swift
//  Career Pro
//


import SwiftUI

struct HomeView: View {
    @StateObject private var dataManager = DataManager.shared
    
    @State private var showingAddSheet = false
    
    @State private var searchText = ""
    
    var filteredApps: [JobApplication] {
        if searchText.isEmpty { return dataManager.applications }
        return dataManager.applications.filter {
            $0.company.localizedCaseInsensitiveContains(searchText) ||
            $0.role.localizedCaseInsensitiveContains(searchText)
        }
    }
    
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
                
                ForEach(filteredApps) { app in
                    JobRow(app: app)
                        .swipeActions {
                            Button(role: .destructive) {
                                dataManager.delete(app)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
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
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack {
                        NavigationLink {
                            NotesListView()
                        } label: {
                            VStack {
                                Image(systemName: "note.text")
                                Text("Notes")
                                    .font(.caption2)
                            }
                            .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
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

struct JobRow: View {
    let app: JobApplication
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
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
                Text(app.status)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(4)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(app.appliedDate, style: .date)
                        .font(.caption)
                }
                .foregroundColor(.gray)
                
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
