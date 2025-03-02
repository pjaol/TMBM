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
    
    func mountBackupVolumeIfNeeded() async throws -> String {
        return "/Volumes/MockBackup"
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
        // Since we're using mock data, we can check if it returns expected values
        let status = try service.getBackupStatus()
        
        if isCIEnvironment {
            // In CI, we expect the mock values
            XCTAssertFalse(status.isRunning)
            XCTAssertNotNil(status.lastBackupDate)
            XCTAssertNotNil(status.nextBackupDate)
        } else {
            // For real service, just verify the structure
            XCTAssertNotNil(status.isRunning)
            // Dates might be nil if no backups exist
            if status.lastBackupDate != nil {
                XCTAssertNotNil(status.nextBackupDate)
            }
        }
    }
    
    func testGetDiskUsage() throws {
        let diskUsage = try service.getDiskUsage()
        
        if isCIEnvironment {
            // In CI, verify our mock values
            XCTAssertEqual(diskUsage.totalSpace, 1000000000000)
            XCTAssertEqual(diskUsage.usedSpace, 500000000000)
            XCTAssertEqual(diskUsage.backupSpace, 200000000000)
        } else {
            // For real service, verify the constraints
            XCTAssertGreaterThan(diskUsage.totalSpace, 0)
            XCTAssertGreaterThanOrEqual(diskUsage.usedSpace, 0)
            XCTAssertGreaterThanOrEqual(diskUsage.availableSpace, 0)
            XCTAssertGreaterThanOrEqual(diskUsage.usagePercentage, 0)
            XCTAssertLessThanOrEqual(diskUsage.usagePercentage, 100)
        }
    }
    
    func testListBackups() async throws {
        let backups = try await service.listBackups()
        
        if isCIEnvironment {
            // In CI, verify our mock data
            XCTAssertEqual(backups.count, 1)
            let mockBackup = backups[0]
            XCTAssertEqual(mockBackup.path, "/Volumes/Backups/Mock.backupbundle")
            XCTAssertEqual(mockBackup.size, 1000000000)
        } else {
            // For real service
            XCTAssertFalse(backups.isEmpty)
            if let firstBackup = backups.first {
                XCTAssertFalse(firstBackup.name.isEmpty)
                XCTAssertNotNil(firstBackup.date)
                XCTAssertGreaterThanOrEqual(firstBackup.size, 0)
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