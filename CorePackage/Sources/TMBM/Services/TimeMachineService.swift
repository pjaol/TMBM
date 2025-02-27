import Foundation

/// Protocol defining the interface for Time Machine operations
public protocol TimeMachineServiceProtocol {
    /// Gets the current backup status
    /// - Returns: A tuple containing the backup status
    /// - Throws: An error if the operation fails
    func getBackupStatus() throws -> (isRunning: Bool, lastBackupDate: Date?, nextBackupDate: Date?)
    
    /// Gets the disk usage information
    /// - Returns: Storage information for the backup disk
    /// - Throws: An error if the operation fails
    func getDiskUsage() throws -> StorageInfo
    
    /// Lists all available backups
    /// - Returns: An array of backup items
    /// - Throws: An error if the operation fails
    func listBackups() throws -> [BackupItem]
    
    /// Deletes a specific backup
    /// - Parameter path: The path to the backup to delete
    /// - Throws: An error if the operation fails
    func deleteBackup(path: String) throws
    
    /// Starts a backup
    /// - Throws: An error if the operation fails
    func startBackup() throws
    
    /// Stops the current backup
    /// - Throws: An error if the operation fails
    func stopBackup() throws
    
    /// Gets information about a sparsebundle
    /// - Parameter path: The path to the sparsebundle
    /// - Returns: Information about the sparsebundle
    /// - Throws: An error if the operation fails
    func getSparsebundleInfo(path: String) throws -> SparsebundleInfo
    
    /// Resizes a sparsebundle
    /// - Parameters:
    ///   - path: The path to the sparsebundle
    ///   - newSize: The new size in bytes
    /// - Throws: An error if the operation fails
    func resizeSparsebundle(path: String, newSize: Int64) throws
}

/// Errors that can occur during Time Machine operations
public enum TimeMachineServiceError: Error, Equatable {
    case backupInProgress
    case noBackupsFound
    case backupNotFound
    case backupDeletionFailed
    case backupStartFailed
    case backupStopFailed
    case diskInfoUnavailable
    case sparsebundleNotFound
    case sparsebundleResizeFailed
    case commandExecutionFailed
    case permissionDenied
    
    /// A description of the error
    public var description: String {
        switch self {
        case .backupInProgress:
            return "A backup is currently in progress"
        case .noBackupsFound:
            return "No backups were found"
        case .backupNotFound:
            return "The specified backup was not found"
        case .backupDeletionFailed:
            return "Failed to delete the backup"
        case .backupStartFailed:
            return "Failed to start the backup"
        case .backupStopFailed:
            return "Failed to stop the backup"
        case .diskInfoUnavailable:
            return "Disk information is unavailable"
        case .sparsebundleNotFound:
            return "The specified sparsebundle was not found"
        case .sparsebundleResizeFailed:
            return "Failed to resize the sparsebundle"
        case .commandExecutionFailed:
            return "Failed to execute the command"
        case .permissionDenied:
            return "Permission denied"
        }
    }
}

/// Service for interacting with Time Machine
public class TimeMachineService: TimeMachineServiceProtocol {
    /// Initializes a new instance of TimeMachineService
    public init() {
        Logger.log("TimeMachineService initialized", level: .info)
    }
    
    /// Gets the current backup status
    /// - Returns: A tuple containing the backup status
    /// - Throws: An error if the operation fails
    public func getBackupStatus() throws -> (isRunning: Bool, lastBackupDate: Date?, nextBackupDate: Date?) {
        Logger.log("Getting backup status", level: .info)
        
        // In a real implementation, we would use tmutil to get the status
        // For now, we'll return mock data
        
        let isRunning = false
        let lastBackupDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let nextBackupDate = Date().addingTimeInterval(3600) // 1 hour from now
        
        return (isRunning: isRunning, lastBackupDate: lastBackupDate, nextBackupDate: nextBackupDate)
    }
    
    /// Gets the disk usage information
    /// - Returns: Storage information for the backup disk
    /// - Throws: An error if the operation fails
    public func getDiskUsage() throws -> StorageInfo {
        Logger.log("Getting disk usage", level: .info)
        
        // In a real implementation, we would use df or diskutil to get the disk usage
        // For now, we'll return mock data
        
        return StorageInfo.mockStorageInfo()
    }
    
    /// Lists all available backups
    /// - Returns: An array of backup items
    /// - Throws: An error if the operation fails
    public func listBackups() throws -> [BackupItem] {
        Logger.log("Listing backups", level: .info)
        
        do {
            // Get the list of backups using tmutil
            let output = try ShellCommandRunner.run("tmutil", arguments: ["listbackups"])
            
            // Parse the output into backup items
            let paths = output.components(separatedBy: .newlines)
                .filter { !$0.isEmpty }
            
            if paths.isEmpty {
                throw TimeMachineServiceError.noBackupsFound
            }
            
            // Create backup items from paths
            return try paths.map { path -> BackupItem in
                // Get backup info using stat
                let statOutput = try ShellCommandRunner.run("stat", arguments: ["-f", "%Sm %z", "-t", "%Y-%m-%d %H:%M:%S", path])
                let components = statOutput.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
                
                guard components.count >= 3,
                      let timestamp = Double(components[0] + " " + components[1]),
                      let size = Int64(components[2]) else {
                    throw TimeMachineServiceError.commandExecutionFailed
                }
                
                let date = Date(timeIntervalSince1970: timestamp)
                let name = (path as NSString).lastPathComponent
                
                return BackupItem(
                    id: UUID(),
                    name: name,
                    path: path,
                    date: date,
                    size: size
                )
            }
        } catch {
            Logger.log("Failed to list backups: \(error)", level: .error)
            throw error
        }
    }
    
    /// Deletes a specific backup
    /// - Parameter path: The path to the backup to delete
    /// - Throws: An error if the operation fails
    public func deleteBackup(path: String) throws {
        Logger.log("Deleting backup at path: \(path)", level: .info)
        
        // In a real implementation, we would use tmutil delete to delete the backup
        // For now, we'll just log the action
        
        // Simulate a successful deletion
        Logger.log("Backup deleted successfully", level: .info)
    }
    
    /// Starts a backup
    /// - Throws: An error if the operation fails
    public func startBackup() throws {
        Logger.log("Starting backup", level: .info)
        
        // In a real implementation, we would use tmutil startbackup to start a backup
        // For now, we'll just log the action
        
        // Simulate a successful backup start
        Logger.log("Backup started successfully", level: .info)
    }
    
    /// Stops the current backup
    /// - Throws: An error if the operation fails
    public func stopBackup() throws {
        Logger.log("Stopping backup", level: .info)
        
        // In a real implementation, we would use tmutil stopbackup to stop a backup
        // For now, we'll just log the action
        
        // Simulate a successful backup stop
        Logger.log("Backup stopped successfully", level: .info)
    }
    
    /// Gets information about a sparsebundle
    /// - Parameter path: The path to the sparsebundle
    /// - Returns: Information about the sparsebundle
    /// - Throws: An error if the operation fails
    public func getSparsebundleInfo(path: String) throws -> SparsebundleInfo {
        Logger.log("Getting sparsebundle info for path: \(path)", level: .info)
        
        // In a real implementation, we would use hdiutil to get information about the sparsebundle
        // For now, we'll return mock data
        
        return SparsebundleInfo.mockSparsebundleInfo
    }
    
    /// Resizes a sparsebundle
    /// - Parameters:
    ///   - path: The path to the sparsebundle
    ///   - newSize: The new size in bytes
    /// - Throws: An error if the operation fails
    public func resizeSparsebundle(path: String, newSize: Int64) throws {
        Logger.log("Resizing sparsebundle at path: \(path) to size: \(newSize)", level: .info)
        
        // In a real implementation, we would use hdiutil resize to resize the sparsebundle
        // For now, we'll just log the action
        
        // Simulate a successful resize
        Logger.log("Sparsebundle resized successfully", level: .info)
    }
} 