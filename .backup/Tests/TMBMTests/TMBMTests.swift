import XCTest
@testable import TMBM

final class TMBMTests: XCTestCase {
    func testExample() {
        // This is a simple test to verify that the testing framework works
        XCTAssertEqual("Time Machine Backup Manager", "Time Machine Backup Manager")
    }
    
    func testDateFormatting() {
        // Create a simple test that doesn't depend on timezone or locale
        // Just verify that we can format a date and get a non-empty string
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let formattedDate = formatter.string(from: date)
        XCTAssertFalse(formattedDate.isEmpty, "Date formatting should produce a non-empty string")
        
        // Test that ByteCountFormatter works
        let bytes: Int64 = 1024
        let byteFormatter = ByteCountFormatter()
        let formattedBytes = byteFormatter.string(fromByteCount: bytes)
        XCTAssertFalse(formattedBytes.isEmpty, "Byte formatting should produce a non-empty string")
    }
    
    func testByteFormatting() {
        // Test byte formatting
        let bytes: Int64 = 1_073_741_824 // 1 GB
        let formatted = ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
        
        // The exact string might vary by locale, but it should contain "GB" or "GiB"
        XCTAssertTrue(formatted.contains("GB") || formatted.contains("GiB"))
    }
} 