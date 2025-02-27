import SwiftUI

struct TimeMachineStatusView: View {
    @StateObject private var viewModel = TimeMachineStatusViewModel()
    @AppStorage("isBackupPaused") private var isBackupPaused = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Status Card
            statusCard
            
            // Storage Info
            storageInfoCard
            
            // Controls
            controlsSection
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            Task {
                await viewModel.refreshStatus()
            }
        }
    }
    
    private var statusCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Time Machine Status")
                    .font(.headline)
                Spacer()
                Button {
                    Task {
                        await viewModel.refreshStatus()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
            }
            
            if viewModel.isLoading {
                ProgressView("Checking status...")
            } else {
                HStack(spacing: 16) {
                    Image(systemName: statusIcon)
                        .font(.system(size: 36))
                        .foregroundColor(statusColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(statusTitle)
                            .font(.title3)
                            .bold()
                        
                        Text(statusDescription)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
            }
        }
    }
    
    private var storageInfoCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Backup Storage")
                    .font(.headline)
                Spacer()
            }
            
            if let storageInfo = viewModel.storageInfo {
                VStack(spacing: 12) {
                    HStack {
                        Text(storageInfo.volumeName)
                            .font(.title3)
                            .bold()
                        Spacer()
                        Text(storageInfo.formattedAvailableSpace)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Storage bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(NSColor.controlBackgroundColor))
                                .frame(height: 8)
                            
                            // Used space
                            RoundedRectangle(cornerRadius: 4)
                                .fill(storageInfo.spacePercentage > 0.9 ? Color.red : Color.blue)
                                .frame(width: max(0, min(geometry.size.width * CGFloat(storageInfo.spacePercentage), geometry.size.width)), height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    // Space details
                    HStack {
                        Text("Used: \(storageInfo.formattedUsedSpace)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Total: \(storageInfo.formattedTotalSpace)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
            } else if viewModel.isLoading {
                ProgressView("Loading storage info...")
                    .padding()
            } else {
                Text("No backup disk available")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
            }
        }
    }
    
    private var controlsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Backup Controls")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 12) {
                Button {
                    Task {
                        await viewModel.startBackup()
                    }
                } label: {
                    Label("Start Backup", systemImage: "arrow.clockwise.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isBackupRunning || viewModel.isLoading)
                
                Button {
                    Task {
                        await viewModel.stopBackup()
                    }
                } label: {
                    Label("Stop Backup", systemImage: "stop.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.isBackupRunning || viewModel.isLoading)
            }
            
            Toggle(isOn: $isBackupPaused) {
                Label("Pause Automatic Backups", systemImage: "pause.circle")
            }
            .onChange(of: isBackupPaused) { newValue in
                Task {
                    if newValue {
                        await viewModel.pauseBackups()
                    } else {
                        await viewModel.resumeBackups()
                    }
                }
            }
        }
    }
    
    // Status helpers
    private var statusIcon: String {
        if viewModel.isBackupRunning {
            return "arrow.clockwise.circle.fill"
        } else if isBackupPaused {
            return "pause.circle.fill"
        } else if viewModel.lastBackupDate != nil {
            return "checkmark.circle.fill"
        } else {
            return "exclamationmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        if viewModel.isBackupRunning {
            return .blue
        } else if isBackupPaused {
            return .orange
        } else if viewModel.lastBackupDate != nil {
            return .green
        } else {
            return .red
        }
    }
    
    private var statusTitle: String {
        if viewModel.isBackupRunning {
            return "Backup in Progress"
        } else if isBackupPaused {
            return "Backups Paused"
        } else if let lastBackupDate = viewModel.lastBackupDate {
            return "Last Backup: \(lastBackupDate)"
        } else {
            return "No Backups Found"
        }
    }
    
    private var statusDescription: String {
        if viewModel.isBackupRunning {
            return "Time Machine is currently backing up your data."
        } else if isBackupPaused {
            return "Automatic backups are currently paused."
        } else if viewModel.lastBackupDate != nil {
            return "Your Mac is being backed up regularly."
        } else {
            return "No backups have been completed yet."
        }
    }
}

class TimeMachineStatusViewModel: ObservableObject {
    @Published var isBackupRunning = false
    @Published var lastBackupDate: String? = nil
    @Published var storageInfo: StorageInfo? = nil
    @Published var isLoading = false
    @Published var error: Error? = nil
    
    private let timeMachineService = TimeMachineService()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    func refreshStatus() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            // Get backup status
            let status = try await timeMachineService.getTimeMachineStatus()
            let diskInfo = try? await timeMachineService.getBackupDiskInfo()
            
            await MainActor.run {
                self.isBackupRunning = status.isBackupRunning
                
                if let date = status.lastBackupDate {
                    self.lastBackupDate = dateFormatter.string(from: date)
                } else {
                    self.lastBackupDate = nil
                }
                
                self.storageInfo = diskInfo
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    func startBackup() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            try await timeMachineService.startBackup()
            await refreshStatus()
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    func stopBackup() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            try await timeMachineService.stopBackup()
            await refreshStatus()
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    func pauseBackups() async {
        do {
            try await timeMachineService.pauseBackups()
            await refreshStatus()
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func resumeBackups() async {
        do {
            try await timeMachineService.resumeBackups()
            await refreshStatus()
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
}

#Preview {
    TimeMachineStatusView()
} 