import SwiftUI
import TMBM

@MainActor
class MenuBarViewModel: ObservableObject {
    private let timeMachineService: TimeMachineService
    private var updateTimer: Timer?
    
    @Published var lastBackupDate: Date?
    @Published var nextBackupDate: Date?
    @Published var isBackupRunning: Bool = false
    @Published var storageInfo: StorageInfo?
    @Published var backupStatus: String = "Unknown"
    @Published var statusImage: String = "clock.arrow.circlepath"
    @Published var statusColor: Color = .primary
    
    init() {
        self.timeMachineService = TimeMachineService()
        startUpdateTimer()
        Task {
            await updateStatus()
        }
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    private func startUpdateTimer() {
        // Update status every 30 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.updateStatus()
            }
        }
    }
    
    func updateStatus() async {
        do {
            let status = try timeMachineService.getBackupStatus()
            isBackupRunning = status.isRunning
            lastBackupDate = status.lastBackupDate
            nextBackupDate = status.nextBackupDate
            
            let diskUsage = try timeMachineService.getDiskUsage()
            storageInfo = diskUsage
            
            updateStatusDisplay()
        } catch {
            Logger.log("Failed to update menu bar status: \(error.localizedDescription)", level: .error)
        }
    }
    
    private func updateStatusDisplay() {
        if isBackupRunning {
            backupStatus = "Backup in progress..."
            statusImage = "arrow.clockwise.circle.fill"
            statusColor = .blue
        } else if let storage = storageInfo, storage.usagePercentage >= 90 {
            backupStatus = "Disk space critical"
            statusImage = "exclamationmark.circle.fill"
            statusColor = .red
        } else if let storage = storageInfo, storage.usagePercentage >= 75 {
            backupStatus = "Disk space low"
            statusImage = "exclamationmark.circle"
            statusColor = .yellow
        } else if let last = lastBackupDate {
            let formatter = RelativeDateTimeFormatter()
            backupStatus = "Last backup: \(formatter.localizedString(for: last, relativeTo: Date()))"
            statusImage = "clock.arrow.circlepath"
            statusColor = .primary
        } else {
            backupStatus = "No backups found"
            statusImage = "clock.arrow.circlepath"
            statusColor = .secondary
        }
    }
    
    func startBackup() {
        Task {
            do {
                try timeMachineService.startBackup()
                await updateStatus()
            } catch {
                Logger.log("Failed to start backup: \(error.localizedDescription)", level: .error)
            }
        }
    }
    
    func stopBackup() {
        Task {
            do {
                try timeMachineService.stopBackup()
                await updateStatus()
            } catch {
                Logger.log("Failed to stop backup: \(error.localizedDescription)", level: .error)
            }
        }
    }
} 