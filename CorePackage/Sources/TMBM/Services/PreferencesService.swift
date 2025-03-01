import Foundation

/// Service for managing user preferences
public class PreferencesService {
    /// Singleton instance
    public static let shared = PreferencesService()
    
    /// UserDefaults keys
    private enum Keys {
        static let backupFrequency = "backupFrequency"
        static let isBackupPaused = "isBackupPaused"
        static let launchAtLogin = "launchAtLogin"
        static let showAdvancedOptions = "showAdvancedOptions"
        static let lowSpaceThreshold = "lowSpaceThreshold"
        static let criticalSpaceThreshold = "criticalSpaceThreshold"
    }
    
    /// UserDefaults instance
    private let defaults = UserDefaults.standard
    
    /// Private initializer for singleton
    private init() {}
    
    /// Gets the current preferences
    /// - Returns: The current preferences
    public func getPreferences() -> AppPreferences {
        let backupFrequencyString = defaults.string(forKey: Keys.backupFrequency) ?? "daily"
        let backupFrequency: AppPreferences.BackupFrequency
        
        switch backupFrequencyString {
        case "hourly":
            backupFrequency = .hourly
        case "weekly":
            backupFrequency = .weekly
        default:
            backupFrequency = .daily
        }
        
        return AppPreferences(
            backupScheduleFrequency: backupFrequency,
            isBackupPaused: defaults.bool(forKey: Keys.isBackupPaused),
            launchAtLogin: defaults.bool(forKey: Keys.launchAtLogin),
            showAdvancedOptions: defaults.bool(forKey: Keys.showAdvancedOptions),
            lowSpaceThreshold: defaults.integer(forKey: Keys.lowSpaceThreshold),
            criticalSpaceThreshold: defaults.integer(forKey: Keys.criticalSpaceThreshold)
        )
    }
    
    /// Saves the preferences
    /// - Parameter preferences: The preferences to save
    public func savePreferences(_ preferences: AppPreferences) {
        let backupFrequencyString: String
        
        switch preferences.backupScheduleFrequency {
        case .hourly:
            backupFrequencyString = "hourly"
        case .daily:
            backupFrequencyString = "daily"
        case .weekly:
            backupFrequencyString = "weekly"
        }
        
        defaults.set(backupFrequencyString, forKey: Keys.backupFrequency)
        defaults.set(preferences.isBackupPaused, forKey: Keys.isBackupPaused)
        defaults.set(preferences.launchAtLogin, forKey: Keys.launchAtLogin)
        defaults.set(preferences.showAdvancedOptions, forKey: Keys.showAdvancedOptions)
        defaults.set(preferences.lowSpaceThreshold, forKey: Keys.lowSpaceThreshold)
        defaults.set(preferences.criticalSpaceThreshold, forKey: Keys.criticalSpaceThreshold)
    }
    
    /// Updates a specific preference
    /// - Parameters:
    ///   - keyPath: The key path of the preference to update
    ///   - value: The new value
    public func updatePreference<T>(_ keyPath: WritableKeyPath<AppPreferences, T>, value: T) {
        var preferences = getPreferences()
        preferences[keyPath: keyPath] = value
        savePreferences(preferences)
    }
} 