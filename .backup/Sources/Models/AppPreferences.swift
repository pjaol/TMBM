import Foundation

struct AppPreferences: Codable {
    var backupScheduleFrequency: BackupFrequency = .daily
    var isBackupPaused: Bool = false
    var launchAtLogin: Bool = true
    var showAdvancedOptions: Bool = false
    var lowSpaceThreshold: Double = 0.8  // 80%
    var criticalSpaceThreshold: Double = 0.95  // 95%
    
    enum BackupFrequency: String, Codable, CaseIterable {
        case hourly
        case daily
        case weekly
        
        var displayName: String {
            switch self {
            case .hourly: return "Hourly"
            case .daily: return "Daily"
            case .weekly: return "Weekly"
            }
        }
        
        var intervalInSeconds: TimeInterval {
            switch self {
            case .hourly: return 60 * 60  // 1 hour
            case .daily: return 60 * 60 * 24  // 24 hours
            case .weekly: return 60 * 60 * 24 * 7  // 7 days
            }
        }
    }
    
    // Default preferences
    static var `default`: AppPreferences {
        return AppPreferences()
    }
} 