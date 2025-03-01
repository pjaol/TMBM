import SwiftUI
import TMBM

struct SchedulingView: View {
    @State private var selectedFrequency: AppPreferences.BackupFrequency = .daily
    @State private var isBackupPaused: Bool = false
    @State private var lastBackupDate: Date?
    @State private var nextBackupDate: Date?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @State private var showingStartBackupConfirmation: Bool = false
    
    private let timeMachineService = TimeMachineService()
    private let schedulingService = SchedulingService.shared
    private let preferencesService = PreferencesService.shared
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Loading backup schedule...")
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                Button("Retry") {
                    loadBackupStatus()
                }
            } else {
                // Backup Status
                VStack(alignment: .leading, spacing: 10) {
                    Text("Backup Status")
                        .font(.headline)
                    
                    if let last = lastBackupDate {
                        Text("Last backup: \(RelativeDateTimeFormatter().localizedString(for: last, relativeTo: Date()))")
                    } else {
                        Text("No previous backups found")
                            .foregroundColor(.secondary)
                    }
                    
                    if let next = nextBackupDate {
                        Text("Next backup: \(RelativeDateTimeFormatter().localizedString(for: next, relativeTo: Date()))")
                    }
                }
                .padding()
                .background(Color(.windowBackgroundColor))
                .cornerRadius(8)
                
                // Schedule Controls
                VStack(alignment: .leading, spacing: 10) {
                    Text("Schedule Settings")
                        .font(.headline)
                    
                    Picker("Backup Frequency", selection: $selectedFrequency) {
                        Text("Hourly").tag(AppPreferences.BackupFrequency.hourly)
                        Text("Daily").tag(AppPreferences.BackupFrequency.daily)
                        Text("Weekly").tag(AppPreferences.BackupFrequency.weekly)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(isBackupPaused)
                    .onChange(of: selectedFrequency) { oldValue, newValue in
                        updateBackupFrequency(frequency: newValue)
                    }
                    
                    Toggle("Pause Backups", isOn: $isBackupPaused)
                        .onChange(of: isBackupPaused) { oldValue, newValue in
                            updateBackupStatus(isPaused: newValue)
                        }
                }
                .padding()
                .background(Color(.windowBackgroundColor))
                .cornerRadius(8)
                
                // Manual Controls
                VStack(alignment: .leading, spacing: 10) {
                    Text("Manual Controls")
                        .font(.headline)
                    
                    Button("Start Backup Now") {
                        showingStartBackupConfirmation = true
                    }
                    .disabled(isBackupPaused)
                }
                .padding()
                .background(Color(.windowBackgroundColor))
                .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadBackupStatus()
            loadPreferences()
        }
        .alert("Start Backup", isPresented: $showingStartBackupConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Start") {
                startBackup()
            }
        } message: {
            Text("Are you sure you want to start a backup now?")
        }
    }
    
    private func loadBackupStatus() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let status = try timeMachineService.getBackupStatus()
                lastBackupDate = status.lastBackupDate
                nextBackupDate = schedulingService.getNextScheduledBackupDate()
                
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load backup status: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func loadPreferences() {
        let preferences = preferencesService.getPreferences()
        
        DispatchQueue.main.async {
            self.selectedFrequency = preferences.backupScheduleFrequency
            self.isBackupPaused = preferences.isBackupPaused
        }
    }
    
    private func updateBackupFrequency(frequency: AppPreferences.BackupFrequency) {
        Task {
            schedulingService.setBackupFrequency(frequency)
            loadBackupStatus()
        }
    }
    
    private func updateBackupStatus(isPaused: Bool) {
        Task {
            if isPaused {
                schedulingService.pauseBackups()
            } else {
                schedulingService.resumeBackups()
            }
            loadBackupStatus()
        }
    }
    
    private func startBackup() {
        Task {
            do {
                try timeMachineService.startBackup()
                loadBackupStatus()
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to start backup: \(error.localizedDescription)"
                }
            }
        }
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