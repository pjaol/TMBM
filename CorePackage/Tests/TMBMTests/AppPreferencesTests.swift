import XCTest
@testable import TMBM

final class AppPreferencesTests: XCTestCase {
    func testDefaultPreferences() {
        // Test that default preferences are set correctly
        let defaults = AppPreferences.default
        
        // Check default values
        XCTAssertEqual(defaults.backupScheduleFrequency, .daily)
        XCTAssertFalse(defaults.isBackupPaused)
        XCTAssertTrue(defaults.launchAtLogin)
        XCTAssertFalse(defaults.showAdvancedOptions)
        XCTAssertEqual(defaults.lowSpaceThreshold, 20)
        XCTAssertEqual(defaults.criticalSpaceThreshold, 10)
    }
    
    func testBackupFrequencyDisplayNames() {
        // Test that backup frequency display names are correct
        XCTAssertEqual(AppPreferences.BackupFrequency.hourly.displayName, "Hourly")
        XCTAssertEqual(AppPreferences.BackupFrequency.daily.displayName, "Daily")
        XCTAssertEqual(AppPreferences.BackupFrequency.weekly.displayName, "Weekly")
    }
    
    func testBackupFrequencyIntervals() {
        // Test that backup frequency intervals are correct
        XCTAssertEqual(AppPreferences.BackupFrequency.hourly.intervalInSeconds, 3600)
        XCTAssertEqual(AppPreferences.BackupFrequency.daily.intervalInSeconds, 86400)
        XCTAssertEqual(AppPreferences.BackupFrequency.weekly.intervalInSeconds, 604800)
    }
    
    func testCustomPreferences() {
        // Test creating custom preferences
        let customPrefs = AppPreferences(
            backupScheduleFrequency: .weekly,
            isBackupPaused: true,
            launchAtLogin: false,
            showAdvancedOptions: true,
            lowSpaceThreshold: 15,
            criticalSpaceThreshold: 5
        )
        
        // Check custom values
        XCTAssertEqual(customPrefs.backupScheduleFrequency, .weekly)
        XCTAssertTrue(customPrefs.isBackupPaused)
        XCTAssertFalse(customPrefs.launchAtLogin)
        XCTAssertTrue(customPrefs.showAdvancedOptions)
        XCTAssertEqual(customPrefs.lowSpaceThreshold, 15)
        XCTAssertEqual(customPrefs.criticalSpaceThreshold, 5)
    }
} 