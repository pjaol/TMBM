import SwiftUI

struct SettingsView: View {
    @State private var launchAtLogin: Bool = false
    @State private var showNotifications: Bool = true
    @State private var diskSpaceWarningThreshold: Double = 80.0
    
    var body: some View {
        Form {
            Section(header: Text("General")) {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { oldValue, newValue in
                        // In a real app, we would update the preferences
                        // For now, we'll just log the change
                        print("Launch at login: \(newValue)")
                    }
                
                Toggle("Show Notifications", isOn: $showNotifications)
                    .onChange(of: showNotifications) { oldValue, newValue in
                        // In a real app, we would update the preferences
                        // For now, we'll just log the change
                        print("Show notifications: \(newValue)")
                    }
            }
            
            Section(header: Text("Disk Space")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Warn when disk space is below: \(Int(diskSpaceWarningThreshold))%")
                    Slider(value: $diskSpaceWarningThreshold, in: 5...95, step: 5)
                        .padding(.vertical, 8)
                        .onChange(of: diskSpaceWarningThreshold) { oldValue, newValue in
                            // In a real app, we would update the preferences
                            // For now, we'll just log the change
                            print("Disk space warning threshold: \(newValue)")
                        }
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                Link("View on GitHub", destination: URL(string: "https://github.com/yourusername/tmbm")!)
            }
        }
        .padding(.horizontal, 16)
        .navigationTitle("Settings")
        .onAppear {
            // Load preferences
            // In a real app, we would load from UserDefaults
            // For now, we'll use default values
            launchAtLogin = true
            showNotifications = true
            diskSpaceWarningThreshold = 80.0
        }
    }
} 