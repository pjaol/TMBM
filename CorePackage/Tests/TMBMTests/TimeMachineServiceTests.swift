import XCTest
@testable import TMBM

final class TimeMachineServiceTests: XCTestCase {
    var service: TimeMachineService!
    
    override func setUp() {
        super.setUp()
        service = TimeMachineService()
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    func testGetBackupStatus() throws {
        // Since we're using mock data, we can check if it returns expected values
        let status = try service.getBackupStatus()
        // The status is a tuple with named fields
        XCTAssertNotNil(status.isRunning)
        XCTAssertNotNil(status.lastBackupDate)
        XCTAssertNotNil(status.nextBackupDate)
    }
    
    func testGetDiskUsage() throws {
        // Verify disk usage properties
        let diskUsage = try service.getDiskUsage()
        XCTAssertGreaterThan(diskUsage.totalSpace, 0)
        XCTAssertGreaterThanOrEqual(diskUsage.usedSpace, 0)
        XCTAssertGreaterThanOrEqual(diskUsage.availableSpace, 0)
        XCTAssertGreaterThanOrEqual(diskUsage.usagePercentage, 0)
        XCTAssertLessThanOrEqual(diskUsage.usagePercentage, 100)
    }
    
    func testListBackups() async throws {
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