import XCTest
@testable import TMBM

final class TimeMachineServiceTests: XCTestCase {
    var service: TimeMachineService!
    var mockShellRunner: MockShellCommandRunner!
    
    override func setUp() {
        super.setUp()
        mockShellRunner = MockShellCommandRunner()
        service = TimeMachineService(shellRunner: mockShellRunner)
    }
    
    override func tearDown() {
        service = nil
        mockShellRunner = nil
        super.tearDown()
    }
    
    func testListBackups() async throws {
        // Setup mock response
        let mockOutput = """
        /Volumes/TimeMachine/Backups.backupdb/MacBook/2023-01-01-120000
        /Volumes/TimeMachine/Backups.backupdb/MacBook/2023-01-02-120000
        /Volumes/TimeMachine/Backups.backupdb/MacBook/2023-01-03-120000
        """
        mockShellRunner.mockResponses["tmutil listbackups"] = mockOutput
        
        // Execute
        let backups = try await service.listBackups()
        
        // Verify
        XCTAssertEqual(backups.count, 3, "Should have 3 backups")
        XCTAssertEqual(backups[0].path, "/Volumes/TimeMachine/Backups.backupdb/MacBook/2023-01-01-120000")
        XCTAssertEqual(backups[1].path, "/Volumes/TimeMachine/Backups.backupdb/MacBook/2023-01-02-120000")
        XCTAssertEqual(backups[2].path, "/Volumes/TimeMachine/Backups.backupdb/MacBook/2023-01-03-120000")
    }
    
    func testDeleteBackup() async throws {
        // Setup mock response
        mockShellRunner.mockResponses["tmutil delete /Volumes/TimeMachine/Backups.backupdb/MacBook/2023-01-01-120000"] = "Deleted: /Volumes/TimeMachine/Backups.backupdb/MacBook/2023-01-01-120000"
        
        // Execute
        try await service.deleteBackup("/Volumes/TimeMachine/Backups.backupdb/MacBook/2023-01-01-120000")
        
        // Verify
        XCTAssertTrue(mockShellRunner.commandsExecuted.contains("tmutil delete /Volumes/TimeMachine/Backups.backupdb/MacBook/2023-01-01-120000"))
    }
    
    func testGetDiskUsage() async throws {
        // Setup mock response
        let mockOutput = """
        Filesystem    Size    Used   Avail Capacity  iused    ifree %iused  Mounted on
        /dev/disk3s1  2.0T    1.5T   500G    75%  1000000  9000000   10%   /Volumes/TimeMachine
        """
        mockShellRunner.mockResponses["df -h /Volumes/TimeMachine"] = mockOutput
        
        // Execute
        let storageInfo = try await service.getBackupDiskInfo()
        
        // Verify
        XCTAssertEqual(storageInfo.volumeName, "TimeMachine")
        XCTAssertEqual(storageInfo.totalSpace, 2_000_000_000_000) // 2.0T in bytes
        XCTAssertEqual(storageInfo.usedSpace, 1_500_000_000_000) // 1.5T in bytes
        XCTAssertEqual(storageInfo.availableSpace, 500_000_000_000) // 500G in bytes
        XCTAssertEqual(storageInfo.spacePercentage, 0.75) // 75%
    }
    
    func testIsBackupRunning() async {
        // Setup mock response
        mockShellRunner.mockResponses["tmutil status"] = "Backup session is running"
        
        // Execute
        let isRunning = await service.isBackupRunning()
        
        // Verify
        XCTAssertTrue(isRunning)
    }
    
    func testIsBackupNotRunning() async {
        // Setup mock response
        mockShellRunner.mockResponses["tmutil status"] = "Backup session is not running"
        
        // Execute
        let isRunning = await service.isBackupRunning()
        
        // Verify
        XCTAssertFalse(isRunning)
    }
}

// Mock implementation of ShellCommandRunner for testing
class MockShellCommandRunner {
    var mockResponses: [String: String] = [:]
    var commandsExecuted: [String] = []
    
    func run(_ command: String, arguments: [String] = []) async throws -> String {
        let fullCommand = command + " " + arguments.joined(separator: " ")
        commandsExecuted.append(fullCommand.trimmingCharacters(in: .whitespaces))
        
        if let response = mockResponses[fullCommand.trimmingCharacters(in: .whitespaces)] {
            return response
        }
        
        // Check if we have a partial match (for commands with arguments)
        for (cmd, response) in mockResponses {
            if fullCommand.contains(cmd) {
                return response
            }
        }
        
        throw NSError(domain: "MockShellCommandRunner", code: 1, userInfo: [NSLocalizedDescriptionKey: "No mock response for command: \(fullCommand)"])
    }
    
    func runWithAdminPrivileges(_ command: String, arguments: [String] = []) async throws -> String {
        return try await run(command, arguments: arguments)
    }
} 