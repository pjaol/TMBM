import Foundation
import Combine
import os.log

/// Logger for the TMBM module
public let TMBMLogger = {
    if #available(macOS 10.12, *) {
        return OSLog(subsystem: "com.thevgergroup.tmbm", category: "TimeMachineService")
    } else {
        return OSLog.default
    }
}()

// Helper function for logging
public func logDebug(_ message: String) {
    os_log("%{public}@", log: TMBMLogger, type: .debug, message)
}

public func logInfo(_ message: String) {
    os_log("%{public}@", log: TMBMLogger, type: .info, message)
}

public func logError(_ message: String) {
    os_log("%{public}@", log: TMBMLogger, type: .error, message)
}

/// A class to manage backup size cache
public class BackupSizeCache {
    /// Singleton instance
    public static let shared = BackupSizeCache()
    
    /// Cache structure
    private struct CacheEntry {
        let size: Int64
        let timestamp: Date
        let modificationDate: Date
    }
    
    /// The cache dictionary
    private var cache: [String: CacheEntry] = [:]
    
    /// Cache expiration time (24 hours)
    private let cacheExpirationInterval: TimeInterval = 86400
    
    /// Queue for thread-safe access to the cache
    private let queue = DispatchQueue(label: "com.tmbm.backupSizeCache", attributes: .concurrent)
    
    private init() {
        // Load cache from persistent store if available
        loadCache()
    }
    
    /// Get size from cache if available and valid
    /// - Parameters:
    ///   - path: The path to the backup
    ///   - modificationDate: The current modification date of the backup
    /// - Returns: The cached size if valid, nil otherwise
    func getCachedSize(for path: String, modificationDate: Date) -> Int64? {
        // Restore original cache logic
        var result: Int64? = nil
        
        queue.sync {
            guard let entry = cache[path] else { return }
            
            // Check if cache is still valid (not expired and modification date hasn't changed)
            let now = Date()
            let isExpired = now.timeIntervalSince(entry.timestamp) > cacheExpirationInterval
            let isModified = modificationDate != entry.modificationDate
            
            if !isExpired && !isModified {
                result = entry.size
                logInfo("Using cached size for \(path): \(entry.size) bytes")
            }
        }
        
        return result
    }
    
    /// Store size in cache
    /// - Parameters:
    ///   - size: The size to cache
    ///   - path: The path to the backup
    ///   - modificationDate: The current modification date of the backup
    func cacheSize(_ size: Int64, for path: String, modificationDate: Date) {
        queue.async(flags: .barrier) {
            self.cache[path] = CacheEntry(
                size: size,
                timestamp: Date(),
                modificationDate: modificationDate
            )
            self.saveCache()
        }
    }
    
    /// Clear the entire cache
    func clearCache() {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
            self.saveCache()
        }
    }
    
    /// Remove a specific entry from the cache
    /// - Parameter path: The path to remove
    func removeEntry(for path: String) {
        queue.async(flags: .barrier) {
            self.cache.removeValue(forKey: path)
            self.saveCache()
        }
    }
    
    /// Save cache to persistent store
    private func saveCache() {
        // Convert cache to a serializable format
        var serializableCache: [String: [String: Any]] = [:]
        
        for (path, entry) in cache {
            serializableCache[path] = [
                "size": entry.size,
                "timestamp": entry.timestamp,
                "modificationDate": entry.modificationDate
            ]
        }
        
        // Save to UserDefaults for simplicity
        // In a production app, consider using a more robust solution
        UserDefaults.standard.set(serializableCache, forKey: "backupSizeCache")
    }
    
    /// Load cache from persistent store
    private func loadCache() {
        guard let serializableCache = UserDefaults.standard.dictionary(forKey: "backupSizeCache") as? [String: [String: Any]] else {
            return
        }
        
        for (path, entryDict) in serializableCache {
            guard let size = entryDict["size"] as? Int64,
                  let timestamp = entryDict["timestamp"] as? Date,
                  let modificationDate = entryDict["modificationDate"] as? Date else {
                continue
            }
            
            cache[path] = CacheEntry(
                size: size,
                timestamp: timestamp,
                modificationDate: modificationDate
            )
        }
    }
}

/// A class to manage backup size calculation operations
public class BackupSizeManager: ObservableObject {
    /// Singleton instance
    public static let shared = BackupSizeManager()
    
    /// Published property for backup sizes
    @Published public private(set) var backupSizes: [UUID: Int64] = [:]
    
    /// Active calculation tasks
    private var calculationTasks: [String: Task<Int64, Error>] = [:]
    
    /// Queue for thread-safe access to tasks
    private let queue = DispatchQueue(label: "com.tmbm.backupSizeManager", attributes: .concurrent)
    
    private init() {}
    
    /// Get or calculate the size of a backup
    /// - Parameters:
    ///   - path: The path to the backup
    ///   - backupId: The UUID of the backup
    /// - Returns: An async stream of size updates
    public func getSizeStream(for path: String, backupId: UUID) -> AsyncStream<Int64> {
        return AsyncStream { continuation in
            Task {
                do {
                    let size = try await getSize(for: path, backupId: backupId)
                    logInfo("Yielding size \(size) for backup \(backupId)")
                    continuation.yield(size)
                    continuation.finish()
                } catch {
                    logError("Error calculating size for \(path): \(error.localizedDescription)")
                    continuation.finish()
                }
            }
        }
    }
    
    /// Get or calculate the size of a backup
    /// - Parameters:
    ///   - path: The path to the backup
    ///   - backupId: The UUID of the backup
    /// - Returns: The size in bytes
    public func getSize(for path: String, backupId: UUID) async throws -> Int64 {
        // Check if we already have a task calculating this size
        if let existingTask = getExistingTask(for: path) {
            logInfo("Using existing calculation task for \(path)")
            return try await existingTask.value
        }
        
        // Create a new task for calculating the size
        let task = Task<Int64, Error> {
            do {
                // Get file attributes to check modification date
                let fileManager = FileManager.default
                let attributes = try fileManager.attributesOfItem(atPath: path)
                let modificationDate = attributes[.modificationDate] as? Date ?? Date()
                
                // Check cache first
                if let cachedSize = BackupSizeCache.shared.getCachedSize(for: path, modificationDate: modificationDate) {
                    logInfo("Using cached size for \(path): \(cachedSize) bytes")
                    await updateSize(backupId: backupId, size: cachedSize)
                    return cachedSize
                }
                
                // Calculate size if not in cache
                let size = try await calculateBackupSize(path: path, fileManager: fileManager)
                
                // Cache the result
                BackupSizeCache.shared.cacheSize(size, for: path, modificationDate: modificationDate)
                
                // Update the published property
                await updateSize(backupId: backupId, size: size)
                
                return size
            } catch {
                throw error
            }
        }
        
        // Store the task
        storeTask(task, for: path)
        
        // Wait for the result
        do {
            let result = try await task.value
            removeTask(for: path)
            return result
        } catch {
            removeTask(for: path)
            throw error
        }
    }
    
    /// Update the size for a backup ID
    /// - Parameters:
    ///   - backupId: The UUID of the backup
    ///   - size: The size in bytes
    @MainActor
    private func updateSize(backupId: UUID, size: Int64) {
        logInfo("Updating size for backup \(backupId) to \(size) bytes")
        // Explicitly trigger objectWillChange before modifying the published property
        objectWillChange.send()
        backupSizes[backupId] = size
    }
    
    /// Get an existing calculation task for a path
    /// - Parameter path: The path to the backup
    /// - Returns: The task if it exists
    private func getExistingTask(for path: String) -> Task<Int64, Error>? {
        var result: Task<Int64, Error>? = nil
        queue.sync {
            result = calculationTasks[path]
        }
        return result
    }
    
    /// Store a calculation task for a path
    /// - Parameters:
    ///   - task: The task
    ///   - path: The path to the backup
    private func storeTask(_ task: Task<Int64, Error>, for path: String) {
        queue.async(flags: .barrier) {
            self.calculationTasks[path] = task
        }
    }
    
    /// Remove a calculation task for a path
    /// - Parameter path: The path to the backup
    private func removeTask(for path: String) {
        queue.async(flags: .barrier) {
            self.calculationTasks.removeValue(forKey: path)
        }
    }
    
    /// Calculate the size of a backup
    /// - Parameters:
    ///   - path: The path to the backup
    ///   - fileManager: The file manager to use
    /// - Returns: The size in bytes
    private func calculateBackupSize(path: String, fileManager: FileManager) async throws -> Int64 {
        logInfo("Starting size calculation for \(path)")
        
        // First, try to get the size from the Results.plist file
        if let sizeFromPlist = try? getBackupSizeFromResultsPlist(path: path, fileManager: fileManager) {
            logInfo("Found size in Results.plist for \(path): \(sizeFromPlist) bytes")
            return sizeFromPlist
        }
        
        // If Results.plist doesn't exist or doesn't contain BytesUsed, fall back to the mock calculation
        logInfo("No Results.plist found, using mock size calculation for \(path)")
        
        // Add a random delay between 8-15 seconds to simulate slow network calculation
        let delaySeconds = Double.random(in: 8...15)
        logInfo("Delaying for \(delaySeconds) seconds to simulate calculation time")
        
        try await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
        
        // Generate a mock size between 100GB and 2TB
        let mockSize = Int64.random(in: 100_000_000_000...2_000_000_000_000)
        logInfo("Mock size calculated for \(path): \(mockSize) bytes")
        
        return mockSize
    }
    
    /// Get backup size from the Results.plist file
    /// - Parameters:
    ///   - path: The path to the backup
    ///   - fileManager: The file manager to use
    /// - Returns: The size in bytes if available
    /// - Throws: An error if the file cannot be read or parsed
    private func getBackupSizeFromResultsPlist(path: String, fileManager: FileManager) throws -> Int64 {
        // Construct the path to the Results.plist file
        let resultsPlistPath = path + "/com.apple.TimeMachine.Results.plist"
        
        // Check if the file exists
        guard fileManager.fileExists(atPath: resultsPlistPath) else {
            logInfo("Results.plist not found at \(resultsPlistPath)")
            throw NSError(domain: "com.tmbm", code: 404, userInfo: [NSLocalizedDescriptionKey: "Results.plist not found"])
        }
        
        // Read the plist file
        let plistData = try Data(contentsOf: URL(fileURLWithPath: resultsPlistPath))
        
        // Parse the plist
        let plistDict = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any]
        
        // Extract the BytesUsed value
        guard let bytesUsed = plistDict?["BytesUsed"] as? Int64 else {
            logInfo("BytesUsed not found in Results.plist at \(resultsPlistPath)")
            throw NSError(domain: "com.tmbm", code: 404, userInfo: [NSLocalizedDescriptionKey: "BytesUsed not found in Results.plist"])
        }
        
        logInfo("Successfully read BytesUsed from Results.plist: \(bytesUsed) bytes")
        return bytesUsed
    }
}

extension Notification.Name {
    /// Notification posted when a backup's size has been calculated
    public static let backupSizeUpdated = Notification.Name("backupSizeUpdated")
}

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
    func listBackups() async throws -> [BackupItem]
    
    /// Deletes a specific backup
    /// - Parameter path: The path to the backup to delete
    /// - Throws: An error if the operation fails
    func deleteBackup(path: String) async throws
    
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
    case fullDiskAccessRequired
    
    /// A description of the error
    public var description: String {
        switch self {
        case .backupInProgress:
            return "A backup is currently in progress"
        case .noBackupsFound:
            return "No Time Machine backups were found. Please ensure Time Machine is configured and has completed at least one backup. You can configure Time Machine in System Settings > Time Machine."
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
        case .fullDiskAccessRequired:
            return "Full Disk Access required. Please grant access in System Settings > Privacy & Security > Full Disk Access."
        }
    }
}

/// Service for interacting with Time Machine
public class TimeMachineService: TimeMachineServiceProtocol, ObservableObject {
    /// Published storage info for SwiftUI binding
    @Published public private(set) var storageInfo: StorageInfo?
    
    /// Published backup status for SwiftUI binding
    @Published public private(set) var backupStatus: (isRunning: Bool, lastBackupDate: Date?, nextBackupDate: Date?)?
    
    /// Initializes a new instance of TimeMachineService
    public init() {
        logInfo("TimeMachineService initialized")
    }
    
    /// Gets the current backup status
    /// - Returns: A tuple containing the backup status
    /// - Throws: An error if the operation fails
    public func getBackupStatus() throws -> (isRunning: Bool, lastBackupDate: Date?, nextBackupDate: Date?) {
        logInfo("Getting backup status")
        
        // In a real implementation, we would use tmutil to get the status
        // For now, we'll return mock data
        
        let isRunning = false
        let lastBackupDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let nextBackupDate = Date().addingTimeInterval(3600) // 1 hour from now
        
        let status = (isRunning: isRunning, lastBackupDate: lastBackupDate, nextBackupDate: nextBackupDate)
        
        // Update the published property
        DispatchQueue.main.async {
            self.backupStatus = status
        }
        
        return status
    }
    
    /// Gets the disk usage information with caching
    /// - Returns: Storage information for the backup disk
    /// - Throws: An error if the operation fails
    public func getDiskUsage() throws -> StorageInfo {
        logInfo("Getting disk usage")
        
        // Check if we have cached storage info that's less than 5 minutes old
        if let cachedInfo = storageInfo, 
           Date().timeIntervalSince(cachedInfo.timestamp) < 300 {
            logInfo("Using cached disk usage info")
            logInfo("Cached info: \(cachedInfo)")
            return cachedInfo
        }
        
        // In a real implementation, we would use df or diskutil to get the disk usage
        // For now, we'll return mock data with current timestamp
        let info = StorageInfo.mockStorageInfo()
        
        // Update the published property
        DispatchQueue.main.async {
            self.storageInfo = info
        }
        
        return info
    }
    
    /// Lists all available backups
    /// - Returns: An array of backup items
    /// - Throws: An error if the operation fails
    public func listBackups() async throws -> [BackupItem] {
        logInfo("Listing backups")
        
        do {
            // First check if Time Machine is configured by checking destination info
            let destinationInfo = try ShellCommandRunner.run("tmutil destinationinfo")
            logInfo("Destination info: \(destinationInfo)")
            
            if destinationInfo.contains("No destinations configured") {
                logInfo("Time Machine is not configured")
                throw TimeMachineServiceError.noBackupsFound
            }
            
            // Get the backup directory path from destinationinfo
            let mountPoint = try getMountPointFromDestinationInfo(destinationInfo)
            logInfo("Backup mount point: \(mountPoint)")
            
            // Check if the directory exists
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: mountPoint) else {
                logInfo("Backup directory does not exist: \(mountPoint)")
                throw TimeMachineServiceError.noBackupsFound
            }
            
            // List all backup directories
            let contents = try fileManager.contentsOfDirectory(atPath: mountPoint)
            
            // Check if this is a network backup by looking for sparsebundle/backupbundle files
            let networkBackupDirs = contents.filter { path in
                path.hasSuffix(".sparsebundle") || path.hasSuffix(".backupbundle")
            }.map { mountPoint + "/" + $0 }
             .sorted()
            
            if !networkBackupDirs.isEmpty {
                logInfo("Found network backup bundles: \(networkBackupDirs)")
                return try await createBackupItems(from: networkBackupDirs, fileManager: fileManager)
            }
            
            // If no network bundles found, check for local backup directories
            let localBackupDirs = contents.filter { $0.hasSuffix(".backup") }
                                        .map { mountPoint + "/" + $0 }
                                        .sorted()
            
            if localBackupDirs.isEmpty {
                logInfo("No backup directories found")
                throw TimeMachineServiceError.noBackupsFound
            }
            
            return try await createBackupItems(from: localBackupDirs, fileManager: fileManager)
        } catch let error as TimeMachineServiceError {
            throw error
        } catch {
            logError("Unexpected error: \(error)")
            throw TimeMachineServiceError.commandExecutionFailed
        }
    }
    
    /// Extract the mount point from tmutil destinationinfo output
    private func getMountPointFromDestinationInfo(_ output: String) throws -> String {
        // Look for either MountPoint or URL in the output
        let lines = output.components(separatedBy: .newlines)
        
        // First try to find a mount point (for local backups)
        if let mountPointLine = lines.first(where: { $0.contains("MountPoint") }),
           let mountPoint = mountPointLine.components(separatedBy: " : ").last?.trimmingCharacters(in: .whitespaces) {
            return mountPoint
        }
        
        // If no mount point, look for URL (for network backups)
        if let urlLine = lines.first(where: { $0.contains("URL") }),
           let urlString = urlLine.components(separatedBy: " : ").last?.trimmingCharacters(in: .whitespaces) {
            // For network backups, we need to check if it's mounted
            // The mount point will be under /Volumes
            let urlComponents = urlString.components(separatedBy: "/")
            if let shareName = urlComponents.last {
                let potentialMountPoint = "/Volumes/" + shareName
                if FileManager.default.fileExists(atPath: potentialMountPoint) {
                    return potentialMountPoint
                } else {
                    logInfo("Mount point does not exist: \(potentialMountPoint)")
                }
            }
        }
        
        logError("Could not find valid mount point in destinationinfo output")
        logInfo("Destination info output: \(output)")
        throw TimeMachineServiceError.diskInfoUnavailable
    }
    
    /// Create BackupItem objects from a list of backup directory paths, with async size updates
    private func createBackupItems(from paths: [String], fileManager: FileManager) async throws -> [BackupItem] {
        // First create backup items with size 0
        let backupItems = try paths.map { path -> BackupItem in
            logInfo("Creating initial backup item for path: \(path)")
            
            let attributes = try fileManager.attributesOfItem(atPath: path)
            let date = attributes[.modificationDate] as? Date ?? Date()
            let name = (path as NSString).lastPathComponent
            
            // Generate a consistent UUID based on the path
            let pathUUID = uuidFromString(path)
            logInfo("Generated consistent UUID \(pathUUID) for path: \(path)")
            
            return BackupItem(
                id: pathUUID,
                name: name,
                path: path,
                date: date,
                size: 0,  // Initial size is 0
                isCalculatingSize: true
            )
        }
        
        // Start async size calculation for each backup item
        for backupItem in backupItems {
            Task {
                // Use the BackupSizeManager to get the size
                logInfo("Starting size calculation task for backup: \(backupItem.id)")
                _ = BackupSizeManager.shared.getSizeStream(for: backupItem.path, backupId: backupItem.id)
                logInfo("Size calculation task started for backup: \(backupItem.path)")
            }
        }
        
        return backupItems
    }
    
    /// Deletes a specific backup
    /// - Parameter path: The path to the backup to delete
    /// - Throws: An error if the operation fails
    public func deleteBackup(path: String) async throws {
        logInfo("Deleting backup at path: \(path)")
        
        // In a real implementation, we would use tmutil delete to delete the backup
        // For now, we'll just log the action
        
        // Remove from cache
        BackupSizeCache.shared.removeEntry(for: path)
        
        // Simulate a successful deletion
        logInfo("Backup deleted successfully")
    }
    
    /// Starts a backup
    /// - Throws: An error if the operation fails
    public func startBackup() throws {
        logInfo("Starting backup")
        
        // In a real implementation, we would use tmutil startbackup to start a backup
        // For now, we'll just log the action
        
        // Simulate a successful backup start
        logInfo("Backup started successfully")
    }
    
    /// Stops the current backup
    /// - Throws: An error if the operation fails
    public func stopBackup() throws {
        logInfo("Stopping backup")
        
        // In a real implementation, we would use tmutil stopbackup to stop a backup
        // For now, we'll just log the action
        
        // Simulate a successful backup stop
        logInfo("Backup stopped successfully")
    }
    
    /// Gets information about a sparsebundle
    /// - Parameter path: The path to the sparsebundle
    /// - Returns: Information about the sparsebundle
    /// - Throws: An error if the operation fails
    public func getSparsebundleInfo(path: String) throws -> SparsebundleInfo {
        logInfo("Getting sparsebundle info for path: \(path)")
        
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
        logInfo("Resizing sparsebundle at path: \(path) to size: \(newSize)")
        
        // In a real implementation, we would use hdiutil resize to resize the sparsebundle
        // For now, we'll just log the action
        
        // Simulate a successful resize
        logInfo("Sparsebundle resized successfully")
    }
}

/// Helper method to generate a consistent UUID from a string
private func uuidFromString(_ string: String) -> UUID {
    // Use a hash of the string to create a deterministic UUID
    let stringData = string.data(using: .utf8)!
    var digest = [UInt8](repeating: 0, count: 16)
    
    // Simple hash function - in production, you might want to use a more robust hash
    for (index, byte) in stringData.enumerated() {
        digest[index % 16] = digest[index % 16] &+ byte
    }
    
    // Set version to 4 (random) and variant to 1 (RFC 4122)
    digest[6] = (digest[6] & 0x0F) | 0x40 // version 4
    digest[8] = (digest[8] & 0x3F) | 0x80 // variant 1
    
    return UUID(uuid: (
        digest[0], digest[1], digest[2], digest[3],
        digest[4], digest[5], digest[6], digest[7],
        digest[8], digest[9], digest[10], digest[11],
        digest[12], digest[13], digest[14], digest[15]
    ))
} 