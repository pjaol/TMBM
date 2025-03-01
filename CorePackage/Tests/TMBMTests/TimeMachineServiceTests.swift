import XCTest
@testable import TMBM

/// A mock implementation of TimeMachineService for testing in CI environments
class MockTimeMachineService: TimeMachineServiceProtocol {
    func isTimeMachineConfigured() async -> Bool {
        return true
    }
    
    func getBackupStatus() throws -> (isRunning: Bool, lastBackupDate: Date?, nextBackupDate: Date?) {
        return (isRunning: false, lastBackupDate: Date(), nextBackupDate: Date().addingTimeInterval(3600))
    }
    
    func getDiskUsage() throws -> StorageInfo {
        return StorageInfo(
            totalSpace: 1000000000000,
            usedSpace: 500000000000,
            backupSpace: 200000000000
        )
    }
    
    func listBackups() async throws -> [BackupItem] {
        let mockBackup = BackupItem(
            id: UUID(),
            name: "Mock Backup",
            path: "/Volumes/Backups/Mock.backupbundle",
            date: Date(),
            size: 1000000000
        )
        return [mockBackup]
    }
    
    func getSparsebundleInfo(path: String) throws -> SparsebundleInfo {
        return SparsebundleInfo(
            path: path,
            size: 1000000000,
            bandSize: 8388608,
            volumeName: "MockVolume",
            isEncrypted: false
        )
    }
    
    func startBackup() throws {
        // Mock implementation
    }
    
    func stopBackup() throws {
        // Mock implementation
    }
    
    func deleteBackup(path: String) async throws {
        // Mock implementation
    }
    
    func resizeSparsebundle(path: String, newSize: Int64) throws {
        // Mock implementation
    }
}

final class TimeMachineServiceTests: XCTestCase {
    var service: TimeMachineServiceProtocol!
    var isCIEnvironment: Bool {
        // Check if we're running in a CI environment
        return ProcessInfo.processInfo.environment["CI"] != nil || 
               ProcessInfo.processInfo.environment["GITHUB_ACTIONS"] != nil
    }
    
    override func setUp() {
        super.setUp()
        // Use mock service in CI environment, real service otherwise
        if isCIEnvironment {
            service = MockTimeMachineService()
        } else {
            service = TimeMachineService()
        }
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    func testGetBackupStatus() throws {
        do {
            // Since we're using mock data, we can check if it returns expected values
            let status = try service.getBackupStatus()
            // The status is a tuple with named fields
            XCTAssertNotNil(status.isRunning)
            XCTAssertNotNil(status.lastBackupDate)
            XCTAssertNotNil(status.nextBackupDate)
        } catch TimeMachineServiceError.noBackupDestinationConfigured {
            // Skip test if no backup destination is configured (in CI environment)
            if !isCIEnvironment {
                throw TimeMachineServiceError.noBackupDestinationConfigured
            }
        }
    }
    
    func testGetDiskUsage() throws {
        do {
            // Verify disk usage properties
            let diskUsage = try service.getDiskUsage()
            XCTAssertGreaterThan(diskUsage.totalSpace, 0)
            XCTAssertGreaterThanOrEqual(diskUsage.usedSpace, 0)
            XCTAssertGreaterThanOrEqual(diskUsage.availableSpace, 0)
            XCTAssertGreaterThanOrEqual(diskUsage.usagePercentage, 0)
            XCTAssertLessThanOrEqual(diskUsage.usagePercentage, 100)
        } catch TimeMachineServiceError.noBackupDestinationConfigured {
            // Skip test if no backup destination is configured (in CI environment)
            if !isCIEnvironment {
                throw TimeMachineServiceError.noBackupDestinationConfigured
            }
        }
    }
    
    func testListBackups() async throws {
        do {
            // Verify we get at least one backup in our mock data
            let backups = try await service.listBackups()
            XCTAssertFalse(backups.isEmpty)
            
            // Check the first backup has valid properties
            if let firstBackup = backups.first {
                XCTAssertFalse(firstBackup.name.isEmpty)
                XCTAssertNotNil(firstBackup.date)
                // Size might be 0 initially as it's calculated asynchronously
                XCTAssertGreaterThanOrEqual(firstBackup.size, 0)
            }
        } catch TimeMachineServiceError.noBackupsFound {
            // Skip test if no backups are found (in CI environment)
            if !isCIEnvironment {
                throw TimeMachineServiceError.noBackupsFound
            }
        }
    }
    
    func testGetSparsebundleInfo() throws {
        // Verify sparsebundle info properties
        let info = try service.getSparsebundleInfo(path: "/Volumes/Backups/MyMac.sparsebundle")
        XCTAssertFalse(info.path.isEmpty)
        XCTAssertGreaterThan(info.size, 0)
        XCTAssertGreaterThan(info.bandSize, 0)
        XCTAssertFalse(info.volumeName.isEmpty)
        XCTAssertNotNil(info.isEncrypted)
    }
} 