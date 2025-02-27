import Foundation

class ShellCommandRunner {
    enum ShellCommandError: Error, LocalizedError {
        case executionFailed(command: String, exitCode: Int32, output: String)
        case commandNotFound(command: String)
        case permissionDenied(command: String)
        
        var errorDescription: String? {
            switch self {
            case .executionFailed(let command, let exitCode, let output):
                return "Failed to execute command '\(command)' (exit code: \(exitCode)): \(output)"
            case .commandNotFound(let command):
                return "Command not found: \(command)"
            case .permissionDenied(let command):
                return "Permission denied for command: \(command)"
            }
        }
    }
    
    /// Run a shell command and return its output
    /// - Parameters:
    ///   - command: The command to run
    ///   - arguments: Arguments for the command
    /// - Returns: The command output as a string
    static func run(_ command: String, arguments: [String] = []) async throws -> String {
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [command] + arguments
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
        } catch {
            if error.localizedDescription.contains("not found") {
                throw ShellCommandError.commandNotFound(command: command)
            } else if error.localizedDescription.contains("permission denied") {
                throw ShellCommandError.permissionDenied(command: command)
            } else {
                throw error
            }
        }
        
        // Wait for the process to complete
        return await withCheckedContinuation { continuation in
            process.terminationHandler = { process in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                
                if process.terminationStatus == 0 {
                    continuation.resume(returning: output)
                } else {
                    // Process failed, but we'll return the output and handle the error at the call site
                    continuation.resume(returning: output)
                }
            }
        }
    }
    
    /// Run a shell command with admin privileges using sudo
    /// - Parameters:
    ///   - command: The command to run
    ///   - arguments: Arguments for the command
    /// - Returns: The command output as a string
    static func runWithAdminPrivileges(_ command: String, arguments: [String] = []) async throws -> String {
        // This is a simplified version - in a real app, you would use authorization services
        // or guide the user to grant permissions in System Settings
        return try await run("sudo", arguments: [command] + arguments)
    }
} 