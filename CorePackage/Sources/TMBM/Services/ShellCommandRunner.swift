import Foundation

/// Errors that can occur when running shell commands
public enum ShellCommandError: Error, Equatable {
    case commandExecutionFailed
    case commandNotFound
    case permissionDenied
    
    /// A description of the error
    public var description: String {
        switch self {
        case .commandExecutionFailed:
            return "The command failed to execute properly"
        case .commandNotFound:
            return "The specified command was not found"
        case .permissionDenied:
            return "Permission denied when executing the command"
        }
    }
}

/// A service for executing shell commands
public class ShellCommandRunner {
    /// Executes a shell command and returns its output
    /// - Parameters:
    ///   - command: The command to execute
    ///   - arguments: The arguments for the command
    /// - Returns: The output of the command
    /// - Throws: An error if the command fails
    public static func run(_ command: String, arguments: [String] = []) throws -> String {
        // If command contains spaces and no arguments are provided, use bash to run it
        if command.contains(" ") && arguments.isEmpty {
            return try runInBash(command)
        }
        
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
            guard let output = String(data: data, encoding: .utf8) else {
                throw ShellCommandError.commandExecutionFailed
            }
            
            // Check exit status
            if process.terminationStatus != 0 {
                if output.contains("Permission denied") {
                    throw ShellCommandError.permissionDenied
                } else if output.contains("command not found") || output.contains("No such file or directory") {
                    throw ShellCommandError.commandNotFound
                } else {
                    throw ShellCommandError.commandExecutionFailed
                }
            }
            
            return output
        } catch let error as ShellCommandError {
            throw error
        } catch {
            throw ShellCommandError.commandExecutionFailed
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
            throw ShellCommandError.permissionDenied
        }
    }
    
    /// Runs a shell command using bash
    /// - Parameter command: The full command string to run in bash
    /// - Returns: The output of the command
    /// - Throws: ShellCommandError if the command fails
    public static func runInBash(_ command: String) throws -> String {
        return try run("bash", arguments: ["-c", command])
    }
} 