import Foundation
import os.log

/// Protocol for scheduling service
public protocol SchedulingServiceProtocol {
    /// Sets the backup frequency
    /// - Parameter frequency: The backup frequency
    func setBackupFrequency(_ frequency: AppPreferences.BackupFrequency)
    
    /// Pauses backups
    func pauseBackups()
    
    /// Resumes backups
    func resumeBackups()
    
    /// Checks if backups are paused
    /// - Returns: True if backups are paused, false otherwise
    func isBackupPaused() -> Bool
    
    /// Gets the next scheduled backup date
    /// - Returns: The next scheduled backup date, or nil if no backup is scheduled
    func getNextScheduledBackupDate() -> Date?
}

/// Service for scheduling backups
public class SchedulingService: SchedulingServiceProtocol {
    /// Singleton instance
    public static let shared = SchedulingService()
    
    /// The preferences service
    private let preferencesService = PreferencesService.shared
    
    /// The time machine service
    private let timeMachineService = TimeMachineService()
    
    /// The last backup date
    private var lastBackupDate: Date?
    
    /// The next scheduled backup date
    private var nextScheduledBackupDate: Date?
    
    /// Timer for scheduling backups
    private var schedulingTimer: Timer?
    
    /// Private initializer for singleton
    private init() {
        // Load initial backup status
        try? loadBackupStatus()
        
        // Schedule initial backup if not paused
        if !isBackupPaused() {
            scheduleNextBackup()
        }
    }
    
    /// Sets the backup frequency
    /// - Parameter frequency: The backup frequency
    public func setBackupFrequency(_ frequency: AppPreferences.BackupFrequency) {
        preferencesService.updatePreference(\.backupScheduleFrequency, value: frequency)
        
        // Reschedule backup if not paused
        if !isBackupPaused() {
            scheduleNextBackup()
        }
    }
    
    /// Pauses backups
    public func pauseBackups() {
        preferencesService.updatePreference(\.isBackupPaused, value: true)
        
        // Cancel any scheduled backups
        cancelScheduledBackups()
    }
    
    /// Resumes backups
    public func resumeBackups() {
        preferencesService.updatePreference(\.isBackupPaused, value: false)
        
        // Schedule next backup
        scheduleNextBackup()
    }
    
    /// Checks if backups are paused
    /// - Returns: True if backups are paused, false otherwise
    public func isBackupPaused() -> Bool {
        return preferencesService.getPreferences().isBackupPaused
    }
    
    /// Gets the next scheduled backup date
    /// - Returns: The next scheduled backup date, or nil if no backup is scheduled
    public func getNextScheduledBackupDate() -> Date? {
        return nextScheduledBackupDate
    }
    
    /// Schedules the next backup
    private func scheduleNextBackup() {
        // Cancel any existing scheduled backups
        cancelScheduledBackups()
        
        // Get the backup frequency
        let frequency = preferencesService.getPreferences().backupScheduleFrequency
        
        // Calculate the next backup date
        let nextBackupDate: Date
        
        if let lastDate = lastBackupDate {
            // Schedule based on last backup date
            nextBackupDate = lastDate.addingTimeInterval(frequency.intervalInSeconds)
        } else {
            // No previous backup, schedule from now
            nextBackupDate = Date().addingTimeInterval(frequency.intervalInSeconds)
        }
        
        // Store the next scheduled backup date
        nextScheduledBackupDate = nextBackupDate
        
        // Schedule the backup
        let timer = Timer(fire: nextBackupDate, interval: 0, repeats: false) { [weak self] _ in
            self?.performBackup()
        }
        
        // Add the timer to the run loop
        RunLoop.main.add(timer, forMode: .common)
        
        // Store the timer
        schedulingTimer = timer
        
        os_log("%{public}@", log: TMBMLogger, type: .info, "Next backup scheduled for \(nextBackupDate)")
    }
    
    /// Cancels any scheduled backups
    private func cancelScheduledBackups() {
        schedulingTimer?.invalidate()
        schedulingTimer = nil
        nextScheduledBackupDate = nil
    }
    
    /// Performs a backup
    private func performBackup() {
        // Only perform backup if not paused
        guard !isBackupPaused() else {
            return
        }
        
        do {
            // Start the backup
            try timeMachineService.startBackup()
            
            // Update the last backup date
            lastBackupDate = Date()
            
            // Schedule the next backup
            scheduleNextBackup()
            
            os_log("%{public}@", log: TMBMLogger, type: .info, "Backup started successfully")
        } catch {
            os_log("%{public}@", log: TMBMLogger, type: .error, "Failed to start backup: \(error.localizedDescription)")
        }
    }
    
    /// Loads the backup status
    private func loadBackupStatus() throws {
        let status = try timeMachineService.getBackupStatus()
        lastBackupDate = status.lastBackupDate
    }
} 