import SwiftUI
import AppKit
import TMBM

@available(macOS 13.0, *)
struct TMBMApp: App {
    @StateObject private var menuBarViewModel = MenuBarViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        MenuBarExtra(title: "TMBM", systemImage: menuBarViewModel.statusImage) {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: .constant(true))
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: BackupListView()) {
                    Label("Backups", systemImage: "clock.arrow.circlepath")
                }
                
                NavigationLink(destination: DiskUsageView()) {
                    Label("Disk Usage", systemImage: "externaldrive.fill")
                }
                
                NavigationLink(destination: SchedulingView()) {
                    Label("Scheduling", systemImage: "calendar")
                }
                
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200)
            
            Text("Select an option from the sidebar")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Time Machine Backup Manager")
        .frame(minWidth: 800, minHeight: 600)
    }
}

struct MenuBarView: View {
    @State private var lastBackupDate: Date? = Date().addingTimeInterval(-3600) // Mock: 1 hour ago
    @State private var nextBackupDate: Date? = Date().addingTimeInterval(3600) // Mock: 1 hour from now
    @State private var diskUsage: Double = 75.0 // Mock: 75%
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Time Machine Status")
                .font(.headline)
            
            Divider()
            
            if let lastDate = lastBackupDate {
                Text("Last Backup: \(formatDate(lastDate))")
            } else {
                Text("Last Backup: Never")
            }
            
            if let nextDate = nextBackupDate {
                Text("Next Backup: \(formatDate(nextDate))")
            } else {
                Text("Next Backup: Not scheduled")
            }
            
            Text("Disk Usage: \(Int(diskUsage))%")
            
            Divider()
            
            Button("Open Backup Manager") {
                NSApp.activate(ignoringOtherApps: true)
            }
            
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
        .padding()
        .frame(width: 250)
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        // In a real app, we would load this data from the TimeMachineService
        // For now, we'll use mock data
        let timeMachineService = TimeMachineService()
        
        do {
            let status = try timeMachineService.getBackupStatus()
            lastBackupDate = status.lastBackupDate
            nextBackupDate = status.nextBackupDate
            
            let storageInfo = try timeMachineService.getDiskUsage()
            diskUsage = storageInfo.usagePercentage
        } catch {
            print("Error loading data: \(error.localizedDescription)")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
} 
