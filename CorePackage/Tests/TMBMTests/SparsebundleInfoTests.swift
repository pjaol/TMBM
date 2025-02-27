import XCTest
@testable import TMBM

final class SparsebundleInfoTests: XCTestCase {
    func testSparsebundleInfoInitialization() {
        // Test creating a SparsebundleInfo instance
        let info = SparsebundleInfo(
            path: "/Volumes/Backups/Test.sparsebundle",
            size: 1_000_000_000_000, // 1 TB
            bandSize: 8_388_608, // 8 MB
            volumeName: "Test Volume",
            isEncrypted: true
        )
        
        // Check properties
        XCTAssertEqual(info.path, "/Volumes/Backups/Test.sparsebundle")
        XCTAssertEqual(info.size, 1_000_000_000_000)
        XCTAssertEqual(info.bandSize, 8_388_608)
        XCTAssertEqual(info.volumeName, "Test Volume")
        XCTAssertTrue(info.isEncrypted)
    }
    
    func testFormattedSize() {
        // Test the formattedSize computed property
        let info = SparsebundleInfo(
            path: "/Volumes/Backups/Test.sparsebundle",
            size: 1_073_741_824, // 1 GB
            bandSize: 8_388_608, // 8 MB
            volumeName: "Test Volume",
            isEncrypted: false
        )
        
        // The exact string might vary by locale, but it should contain "GB" or "GiB"
        XCTAssertTrue(info.formattedSize.contains("GB") || info.formattedSize.contains("GiB"))
    }
    
    func testFormattedBandSize() {
        // Test the formattedBandSize computed property
        let info = SparsebundleInfo(
            path: "/Volumes/Backups/Test.sparsebundle",
            size: 1_000_000_000_000, // 1 TB
            bandSize: 8_388_608, // 8 MB
            volumeName: "Test Volume",
            isEncrypted: false
        )
        
        // The exact string might vary by locale, but it should contain "MB" or "MiB"
        XCTAssertTrue(info.formattedBandSize.contains("MB") || info.formattedBandSize.contains("MiB"))
    }
    
    func testMockSparsebundleInfo() {
        // Test the mockSparsebundleInfo static property
        let mockInfo = SparsebundleInfo.mockSparsebundleInfo
        
        // Check mock properties
        XCTAssertFalse(mockInfo.path.isEmpty)
        XCTAssertGreaterThan(mockInfo.size, 0)
        XCTAssertGreaterThan(mockInfo.bandSize, 0)
        XCTAssertFalse(mockInfo.volumeName.isEmpty)
        XCTAssertTrue(mockInfo.isEncrypted)
    }
} 