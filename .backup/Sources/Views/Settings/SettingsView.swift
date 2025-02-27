import SwiftUI

struct SettingsView: View {
    @AppStorage("backupScheduleFrequency") private var backupScheduleFrequency = BackupFrequency.daily.rawValue
    @AppStorage("launchAtLogin") private var launchAtLogin = true
    @AppStorage("showAdvancedOptions") private var showAdvancedOptions = false
    @AppStorage("lowSpaceThreshold") private var lowSpaceThreshold = 10.0 // GB
    @AppStorage("criticalSpaceThreshold") private var criticalSpaceThreshold = 5.0 // GB
    
    @State private var isTestingNotifications = false
    
    var body: some View {
        Form {
            generalSection
            
            notificationSection
            
            if showAdvancedOptions {
                advancedSection
            }
            
            aboutSection
        }
        .padding()
        .frame(width: 500, height: 400)
    }
    
    private var generalSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                Text("General")
                    .font(.headline)
                
                Picker("Backup Schedule", selection: $backupScheduleFrequency) {
                    Text("Hourly").tag(BackupFrequency.hourly.rawValue)
                    Text("Daily").tag(BackupFrequency.daily.rawValue)
                    Text("Weekly").tag(BackupFrequency.weekly.rawValue)
                }
                
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        updateLoginItem(enabled: newValue)
                    }
                
                Toggle("Show Advanced Options", isOn: $showAdvancedOptions)
            }
            .padding(.bottom)
        }
    }
    
    private var notificationSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                Text("Notifications")
                    .font(.headline)
                
                HStack {
                    Text("Low Space Warning")
                    Spacer()
                    Text("\(Int(lowSpaceThreshold)) GB")
                        .foregroundColor(.secondary)
                }
                
                Slider(value: $lowSpaceThreshold, in: 5...50, step: 1) {
                    Text("Low Space Warning")
                }
                
                HStack {
                    Text("Critical Space Warning")
                    Spacer()
                    Text("\(Int(criticalSpaceThreshold)) GB")
                        .foregroundColor(.secondary)
                }
                
                Slider(value: $criticalSpaceThreshold, in: 1...20, step: 1) {
                    Text("Critical Space Warning")
                }
                
                Button("Test Notifications") {
                    isTestingNotifications = true
                    sendTestNotification()
                }
                .disabled(isTestingNotifications)
            }
            .padding(.bottom)
        }
    }
    
    private var advancedSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                Text("Advanced")
                    .font(.headline)
                
                Button("Verify Backups") {
                    verifyBackups()
                }
                
                Button("Repair Permissions") {
                    repairPermissions()
                }
                
                Button("Reset Time Machine") {
                    resetTimeMachine()
                }
                .foregroundColor(.red)
            }
            .padding(.bottom)
        }
    }
    
    private var aboutSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("About")
                    .font(.headline)
                
                Text("Time Machine Backup Manager")
                    .font(.subheadline)
                    .bold()
                
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Link("View on GitHub", destination: URL(string: "https://github.com/pjaol/tmbm")!)
                    .font(.caption)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateLoginItem(enabled: Bool) {
        // In a real app, this would use the ServiceManagement framework
        // to add/remove the app from login items
        Logger.log("Setting launch at login: \(enabled)", level: .info)
    }
    
    private func sendTestNotification() {
        // In a real app, this would send a test notification
        Logger.log("Sending test notification", level: .info)
        
        // Simulate notification sending
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isTestingNotifications = false
        }
    }
    
    private func verifyBackups() {
        // In a real app, this would verify the integrity of backups
        Logger.log("Verifying backups", level: .info)
    }
    
    private func repairPermissions() {
        // In a real app, this would repair permissions on the backup disk
        Logger.log("Repairing permissions", level: .info)
    }
    
    private func resetTimeMachine() {
        // In a real app, this would reset Time Machine settings
        Logger.log("Resetting Time Machine", level: .info)
    }
}

// Helper extension to convert between BackupFrequency enum and raw values
extension BackupFrequency {
    static func fromRawValue(_ rawValue: String) -> BackupFrequency {
        return BackupFrequency(rawValue: rawValue) ?? .daily
    }
}

#Preview {
    SettingsView()
} 