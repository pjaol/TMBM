import Foundation

/// A service for executing shell commands
public class ShellCommandRunner {
    /// Executes a shell command and returns its output
    /// - Parameters:
    ///   - command: The command to execute
    ///   - arguments: The arguments for the command
    /// - Returns: The output of the command
    /// - Throws: An error if the command fails
    public static func run(_ command: String, arguments: [String] = []) throws -> String {
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [command] + arguments
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                if process.terminationStatus != 0 {
                    throw TimeMachineServiceError.commandExecutionFailed
                }
                return output
            } else {
                throw TimeMachineServiceError.commandExecutionFailed
            }
        } catch {
            throw TimeMachineServiceError.commandExecutionFailed
        }
    }
    
    /// Executes a shell command with sudo privileges
    /// - Parameters:
    ///   - command: The command to execute
    ///   - arguments: The arguments for the command
    /// - Returns: The output of the command
    /// - Throws: An error if the command fails or permission is denied
    public static func runWithPrivileges(_ command: String, arguments: [String] = []) throws -> String {
        do {
            return try run("sudo", arguments: [command] + arguments)
        } catch {
            throw TimeMachineServiceError.permissionDenied
        }
    }
} 