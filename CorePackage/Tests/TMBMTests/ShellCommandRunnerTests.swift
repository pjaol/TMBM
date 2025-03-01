import XCTest
@testable import TMBM

final class ShellCommandRunnerTests: XCTestCase {
    func testRunValidCommand() {
        do {
            let output = try ShellCommandRunner.run("echo 'Hello, World!'")
            XCTAssertEqual(output.trimmingCharacters(in: .whitespacesAndNewlines), "Hello, World!")
        } catch {
            XCTFail("Valid command should not throw an error: \(error)")
        }
    }
    
    func testRunInvalidCommand() {
        do {
            _ = try ShellCommandRunner.run("command_that_does_not_exist")
            XCTFail("Invalid command should throw an error")
        } catch let error as ShellCommandError {
            // Expected error
            XCTAssertEqual(error, .commandNotFound)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testCommandWithOutput() {
        do {
            let output = try ShellCommandRunner.run("ls -la")
            // Just verify we got some output
            XCTAssertFalse(output.isEmpty)
        } catch {
            XCTFail("Command should not throw an error: \(error)")
        }
    }
} 