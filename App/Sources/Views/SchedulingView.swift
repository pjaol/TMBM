import SwiftUI

struct SchedulingView: View {
    @State private var backupFrequency: BackupFrequency = .daily
    @State private var isBackupPaused: Bool = false
    @State private var nextBackupDate: Date? = Date().addingTimeInterval(3600) // Mock: 1 hour from now
    @State private var lastBackupDate: Date? = Date().addingTimeInterval(-3600) // Mock: 1 hour ago
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @State private var showingStartBackupConfirmation: Bool = false
    
    private let timeMachineService = TimeMachineService()
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading scheduling information...")
            } else if let error = errorMessage {
                VStack {
                    Text("Error loading scheduling information")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(error)
                        .foregroundColor(.secondary)
                    Button("Retry") {
                        loadSchedulingInfo()
                    }
                    .padding()
                }
            } else {
                Form {
                    Section(header: Text("Backup Status")) {
                        HStack {
                            Text("Last Backup:")
                            Spacer()
                            if let date = lastBackupDate {
                                Text(formatDate(date))
                            } else {
                                Text("Never")
                            }
                        }
                        
                        HStack {
                            Text("Next Backup:")
                            Spacer()
                            if isBackupPaused {
                                Text("Paused")
                                    .foregroundColor(.orange)
                            } else if let date = nextBackupDate {
                                Text(formatDate(date))
                            } else {
                                Text("Not scheduled")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Section(header: Text("Backup Schedule")) {
                        Picker("Backup Frequency", selection: $backupFrequency) {
                            Text("Hourly").tag(BackupFrequency.hourly)
                            Text("Daily").tag(BackupFrequency.daily)
                            Text("Weekly").tag(BackupFrequency.weekly)
                            Text("Monthly").tag(BackupFrequency.monthly)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: backupFrequency) { oldValue, newValue in
                            updateSchedule()
                        }
                        
                        Toggle("Pause Backups", isOn: $isBackupPaused)
                            .onChange(of: isBackupPaused) { oldValue, newValue in
                                toggleBackupPause()
                            }
                    }
                    
                    Section {
                        Button(action: {
                            showingStartBackupConfirmation = true
                        }) {
                            HStack {
                                Spacer()
                                Label("Start Backup Now", systemImage: "arrow.clockwise.circle")
                                Spacer()
                            }
                        }
                        .alert(isPresented: $showingStartBackupConfirmation) {
                            Alert(
                                title: Text("Start Backup"),
                                message: Text("Are you sure you want to start a backup now?"),
                                primaryButton: .default(Text("Start")) {
                                    startBackup()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Scheduling")
        .onAppear {
            loadSchedulingInfo()
        }
    }
    
    private func loadSchedulingInfo() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let status = try timeMachineService.getBackupStatus()
                
                DispatchQueue.main.async {
                    self.lastBackupDate = status.lastBackupDate
                    self.nextBackupDate = status.nextBackupDate
                    // In a real app, we would load these from UserDefaults
                    self.backupFrequency = .daily
                    self.isBackupPaused = false
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func updateSchedule() {
        // In a real app, we would update the system's backup schedule
        // For now, we'll just update our local state
        
        // Update the next backup date based on the frequency
        if !isBackupPaused {
            updateNextBackupDate()
        }
    }
    
    private func toggleBackupPause() {
        // In a real app, we would pause/resume the system's backup schedule
        // For now, we'll just update our local state
        
        if isBackupPaused {
            nextBackupDate = nil
        } else {
            updateNextBackupDate()
        }
    }
    
    private func updateNextBackupDate() {
        // Calculate the next backup date based on the frequency
        let now = Date()
        switch backupFrequency {
        case .hourly:
            nextBackupDate = now.addingTimeInterval(3600) // 1 hour
        case .daily:
            nextBackupDate = now.addingTimeInterval(86400) // 24 hours
        case .weekly:
            nextBackupDate = now.addingTimeInterval(604800) // 7 days
        case .monthly:
            nextBackupDate = now.addingTimeInterval(2592000) // 30 days
        }
    }
    
    private func startBackup() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try timeMachineService.startBackup()
                DispatchQueue.main.async {
                    // Update the last backup date
                    self.lastBackupDate = Date()
                    // Update the next backup date
                    self.updateNextBackupDate()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to start backup: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// Enum for backup frequency
enum BackupFrequency: String, CaseIterable, Identifiable {
    case hourly
    case daily
    case weekly
    case monthly
    
    var id: String { self.rawValue }
} 