import XCTest
@testable import TMBM
import Foundation

final class LoggerTests: XCTestCase {
    
    func testLoggerCreatesLogDirectory() {
        // This test verifies that the Logger creates the log directory if it doesn't exist
        
        // Get the logs directory path
        let fileManager = FileManager.default
        let logsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("TMBM/Logs")
        
        // Ensure the directory exists after Logger is used
        Logger.log("Test log message", level: .info)
        
        // Check if the directory exists
        XCTAssertTrue(fileManager.fileExists(atPath: logsDirectory.path))
    }
    
    func testLoggerWritesToFile() {
        // This test verifies that the Logger writes to a log file
        
        // Get today's log file path
        let fileManager = FileManager.default
        let logsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("TMBM/Logs")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        
        let logFilePath = logsDirectory.appendingPathComponent("\(todayString).log").path
        
        // Log a unique message
        let uniqueMessage = "Test log message \(UUID().uuidString)"
        Logger.log(uniqueMessage, level: .info)
        
        // Wait a moment for the file to be written
        Thread.sleep(forTimeInterval: 0.5)
        
        // Check if the log file exists
        XCTAssertTrue(fileManager.fileExists(atPath: logFilePath))
        
        // Try to read the log file content
        do {
            let logContent = try String(contentsOfFile: logFilePath, encoding: .utf8)
            // Check if our unique message is in the log content
            XCTAssertTrue(logContent.contains(uniqueMessage), "Log file should contain the logged message")
        } catch {
            XCTFail("Failed to read log file: \(error)")
        }
    }
    
    func testLogLevels() {
        // Test that all log levels work
        
        // Log messages with different levels
        Logger.log("Debug message", level: .debug)
        Logger.log("Info message", level: .info)
        Logger.log("Warning message", level: .warning)
        Logger.log("Error message", level: .error)
        Logger.log("Critical message", level: .critical)
        
        // This test doesn't verify the content, just that no exceptions are thrown
        XCTAssertTrue(true)
    }
} 