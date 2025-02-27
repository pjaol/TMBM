import Foundation

/// Model for storing user preferences
public struct AppPreferences {
    /// Frequency of backup scheduling
    public enum BackupFrequency: Equatable {
        case hourly
        case daily
        case weekly
        
        /// Display name for the backup frequency
        public var displayName: String {
            switch self {
            case .hourly:
                return "Hourly"
            case .daily:
                return "Daily"
            case .weekly:
                return "Weekly"
            }
        }
        
        /// Interval in seconds for the backup frequency
        public var intervalInSeconds: TimeInterval {
            switch self {
            case .hourly:
                return 3600 // 1 hour
            case .daily:
                return 86400 // 24 hours
            case .weekly:
                return 604800 // 7 days
            }
        }
    }
    
    /// The frequency of backup scheduling
    public var backupScheduleFrequency: BackupFrequency
    
    /// Whether backups are currently paused
    public var isBackupPaused: Bool
    
    /// Whether the app should launch at login
    public var launchAtLogin: Bool
    
    /// Whether to show advanced options in the UI
    public var showAdvancedOptions: Bool
    
    /// Threshold percentage for low disk space warning
    public var lowSpaceThreshold: Int
    
    /// Threshold percentage for critical disk space warning
    public var criticalSpaceThreshold: Int
    
    /// Default preferences
    public static var `default`: AppPreferences {
        AppPreferences(
            backupScheduleFrequency: .daily,
            isBackupPaused: false,
            launchAtLogin: true,
            showAdvancedOptions: false,
            lowSpaceThreshold: 20,
            criticalSpaceThreshold: 10
        )
    }
    
    /// Initializes a new instance of AppPreferences
    /// - Parameters:
    ///   - backupScheduleFrequency: The frequency of backup scheduling
    ///   - isBackupPaused: Whether backups are currently paused
    ///   - launchAtLogin: Whether the app should launch at login
    ///   - showAdvancedOptions: Whether to show advanced options in the UI
    ///   - lowSpaceThreshold: Threshold percentage for low disk space warning
    ///   - criticalSpaceThreshold: Threshold percentage for critical disk space warning
    public init(
        backupScheduleFrequency: BackupFrequency,
        isBackupPaused: Bool,
        launchAtLogin: Bool,
        showAdvancedOptions: Bool,
        lowSpaceThreshold: Int,
        criticalSpaceThreshold: Int
    ) {
        self.backupScheduleFrequency = backupScheduleFrequency
        self.isBackupPaused = isBackupPaused
        self.launchAtLogin = launchAtLogin
        self.showAdvancedOptions = showAdvancedOptions
        self.lowSpaceThreshold = lowSpaceThreshold
        self.criticalSpaceThreshold = criticalSpaceThreshold
    }
} 