import XCTest
@testable import TMBM

final class SchedulingServiceTests: XCTestCase {
    var preferencesService: PreferencesService!
    var schedulingService: SchedulingService!
    
    override func setUp() {
        super.setUp()
        
        // Reset UserDefaults for testing
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "backupFrequency")
        defaults.removeObject(forKey: "isBackupPaused")
        
        preferencesService = PreferencesService.shared
        schedulingService = SchedulingService.shared
    }
    
    func testSetBackupFrequency() {
        // Set the backup frequency to hourly
        schedulingService.setBackupFrequency(.hourly)
        
        // Check that the preference was updated
        let preferences = preferencesService.getPreferences()
        XCTAssertEqual(preferences.backupScheduleFrequency, .hourly)
    }
    
    func testPauseBackups() {
        // Pause backups
        schedulingService.pauseBackups()
        
        // Check that backups are paused
        XCTAssertTrue(schedulingService.isBackupPaused())
    }
    
    func testResumeBackups() {
        // First pause backups
        schedulingService.pauseBackups()
        
        // Then resume backups
        schedulingService.resumeBackups()
        
        // Check that backups are not paused
        XCTAssertFalse(schedulingService.isBackupPaused())
    }
    
    func testGetNextScheduledBackupDate() {
        // Resume backups to ensure a backup is scheduled
        schedulingService.resumeBackups()
        
        // Set the backup frequency to hourly
        schedulingService.setBackupFrequency(.hourly)
        
        // Check that a next backup date is set
        XCTAssertNotNil(schedulingService.getNextScheduledBackupDate())
    }
} 