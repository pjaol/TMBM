import SwiftUI
import TMBM

@main
struct TMBMApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        #if os(macOS)
        // Add menu bar extra
        MenuBarExtra("TMBM", systemImage: "clock.arrow.circlepath") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
        #endif
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

// Placeholder views
struct BackupListView: View {
    var body: some View {
        Text("Backup List View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DiskUsageView: View {
    var body: some View {
        Text("Disk Usage View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SchedulingView: View {
    var body: some View {
        Text("Scheduling View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MenuBarView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Time Machine Status")
                .font(.headline)
            
            Divider()
            
            Text("Last Backup: 1 hour ago")
            Text("Next Backup: In 23 hours")
            Text("Disk Usage: 75%")
            
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
    }
} 