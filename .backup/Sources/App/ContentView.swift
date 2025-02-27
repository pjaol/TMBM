import SwiftUI

struct ContentView: View {
    @State private var selectedSidebarItem: SidebarItem? = .dashboard
    @StateObject private var timeMachineViewModel = TimeMachineStatusViewModel()
    
    enum SidebarItem: String, Identifiable, CaseIterable {
        case dashboard = "Dashboard"
        case backups = "Backups"
        case storage = "Storage"
        case scheduling = "Scheduling"
        case advanced = "Advanced"
        case preferences = "Preferences"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .dashboard: return "gauge"
            case .backups: return "clock.arrow.circlepath"
            case .storage: return "externaldrive"
            case .scheduling: return "calendar"
            case .advanced: return "gearshape.2"
            case .preferences: return "gear"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(SidebarItem.allCases, selection: $selectedSidebarItem) { item in
                NavigationLink(value: item) {
                    Label(item.rawValue, systemImage: item.icon)
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        Task {
                            await timeMachineViewModel.startBackup()
                        }
                    }) {
                        Label("Start Backup", systemImage: "arrow.clockwise")
                    }
                    .disabled(timeMachineViewModel.isBackupRunning || timeMachineViewModel.isLoading)
                }
            }
        } detail: {
            // Detail view based on selection
            switch selectedSidebarItem {
            case .dashboard:
                TimeMachineStatusView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .backups:
                BackupListView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .storage:
                StorageView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .scheduling:
                SchedulingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .advanced:
                AdvancedView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .preferences:
                SettingsView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .none:
                Text("Select an item from the sidebar")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(selectedSidebarItem?.rawValue ?? "Time Machine Backup Manager")
        .onAppear {
            Task {
                await timeMachineViewModel.refreshStatus()
            }
        }
    }
}

// Placeholder views for sections we haven't implemented yet
struct StorageView: View {
    var body: some View {
        VStack {
            Image(systemName: "externaldrive")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("Storage Management")
                .font(.title)
                .padding(.top)
            Text("This feature will be implemented in a future update.")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SchedulingView: View {
    var body: some View {
        VStack {
            Image(systemName: "calendar")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("Backup Scheduling")
                .font(.title)
                .padding(.top)
            Text("This feature will be implemented in a future update.")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AdvancedView: View {
    var body: some View {
        VStack {
            Image(systemName: "gearshape.2")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("Advanced Options")
                .font(.title)
                .padding(.top)
            Text("This feature will be implemented in a future update.")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
} 