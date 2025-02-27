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
    
    func testGetBackupStatus() {
        do {
            let status = try service.getBackupStatus()
            // Since we're using mock data, we can check if it returns expected values
            XCTAssertNotNil(status.isRunning)
            XCTAssertNotNil(status.lastBackupDate)
            XCTAssertNotNil(status.nextBackupDate)
        } catch {
            XCTFail("Getting backup status should not throw an error: \(error)")
        }
    }
    
    func testGetDiskUsage() {
        do {
            let diskUsage = try service.getDiskUsage()
            // Verify disk usage properties
            XCTAssertGreaterThan(diskUsage.totalSpace, 0)
            XCTAssertGreaterThanOrEqual(diskUsage.usedSpace, 0)
            XCTAssertGreaterThanOrEqual(diskUsage.availableSpace, 0)
            XCTAssertGreaterThanOrEqual(diskUsage.usagePercentage, 0)
            XCTAssertLessThanOrEqual(diskUsage.usagePercentage, 100)
        } catch {
            XCTFail("Getting disk usage should not throw an error: \(error)")
        }
    }
    
    func testListBackups() {
        do {
            let backups = try service.listBackups()
            // Verify we get at least one backup in our mock data
            XCTAssertFalse(backups.isEmpty)
            
            // Check the first backup has valid properties
            if let firstBackup = backups.first {
                XCTAssertFalse(firstBackup.name.isEmpty)
                XCTAssertNotNil(firstBackup.date)
                XCTAssertGreaterThan(firstBackup.size, 0)
            }
        } catch {
            XCTFail("Listing backups should not throw an error: \(error)")
        }
    }
    
    func testGetSparsebundleInfo() {
        do {
            let info = try service.getSparsebundleInfo(path: "/Volumes/Backups/MyMac.sparsebundle")
            // Verify sparsebundle info properties
            XCTAssertFalse(info.path.isEmpty)
            XCTAssertGreaterThan(info.size, 0)
            XCTAssertGreaterThan(info.bandSize, 0)
            XCTAssertFalse(info.volumeName.isEmpty)
            XCTAssertNotNil(info.isEncrypted)
        } catch {
            XCTFail("Getting sparsebundle info should not throw an error: \(error)")
        }
    }
} 