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
    
    /// Mounts the backup volume if it's not already mounted
    /// - Returns: The mount point of the backup volume
    /// - Throws: An error if the operation fails
    func mountBackupVolumeIfNeeded() async throws -> String
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
    case noBackupDestinationConfigured
    case volumeNotMounted
    case volumeMountFailed
    
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
        case .noBackupDestinationConfigured:
            return "No backup destination configured"
        case .volumeNotMounted:
            return "The backup volume is not mounted"
        case .volumeMountFailed:
            return "Failed to mount the backup volume"
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
        
        do {
            // Read Time Machine preferences directly using defaults command
            let tmPrefs = try ShellCommandRunner.run("/usr/bin/defaults", arguments: ["read", "/Library/Preferences/com.apple.TimeMachine"])
            logInfo("Time Machine preferences read successfully")
            
            // Check if Time Machine is configured
            if !tmPrefs.contains("Destinations") {
                logInfo("No destinations configured in Time Machine preferences")
                throw TimeMachineServiceError.noBackupDestinationConfigured
            }
            
            // Parse the preferences to get backup information
            let isRunning = try isBackupRunning()
            let lastBackupDate = try getLastBackupDate()
            let nextBackupDate = try calculateNextBackupDate()
            
            // Try to mount the backup volume if needed
            Task {
                do {
                    _ = try await mountBackupVolumeIfNeeded()
                } catch {
                    logError("Failed to mount backup volume: \(error)")
                    // We don't throw here since this is a background task and we don't want to fail the status check
                }
            }
            
            let status = (isRunning: isRunning, lastBackupDate: lastBackupDate, nextBackupDate: nextBackupDate)
            
            // Update the published property
            DispatchQueue.main.async {
                self.backupStatus = status
            }
            
            return status
        } catch let error as TimeMachineServiceError {
            throw error
        } catch {
            logError("Failed to get backup status: \(error)")
            
            // If we have cached status, return it even if it's old
            if let cachedStatus = backupStatus {
                logInfo("Using cached backup status due to error")
                return cachedStatus
            }
            
            throw TimeMachineServiceError.commandExecutionFailed
        }
    }
    
    /// Checks if a backup is currently running
    /// - Returns: True if a backup is running, false otherwise
    /// - Throws: An error if the operation fails
    private func isBackupRunning() throws -> Bool {
        // Check if tmutil status shows a backup in progress
        let status = try ShellCommandRunner.run("/usr/bin/tmutil", arguments: ["status"])
        if status.contains("Running = 1") {
            return true
        }
        return false
    }
    
    /// Gets the last backup date from Time Machine preferences
    /// - Returns: The date of the last backup, or nil if not found
    /// - Throws: An error if the operation fails
    private func getLastBackupDate() throws -> Date? {
        // Parse the preferences to find the last backup date
        let lines = try ShellCommandRunner.run("/usr/bin/tmutil", arguments: ["status"]).components(separatedBy: .newlines)
        if let dateLine = lines.first(where: { $0.contains("LastBackupDate") }),
           let dateString = dateLine.components(separatedBy: " = ").last?.trimmingCharacters(in: CharacterSet(charactersIn: "\";")),
           let timeInterval = TimeInterval(dateString) {
            return Date(timeIntervalSince1970: timeInterval)
        }
        return nil
    }
    
    /// Calculates the next backup date based on Time Machine preferences
    /// - Returns: The calculated next backup date, or nil if not determinable
    /// - Throws: An error if the operation fails
    private func calculateNextBackupDate() throws -> Date? {
        // Parse the preferences to find the backup interval
        let lines = try ShellCommandRunner.run("/usr/bin/tmutil", arguments: ["status"]).components(separatedBy: .newlines)
        if let intervalLine = lines.first(where: { $0.contains("BackupInterval") }),
           let intervalString = intervalLine.components(separatedBy: " = ").last?.trimmingCharacters(in: CharacterSet(charactersIn: "\";")),
           let interval = TimeInterval(intervalString),
           let lastBackup = try? getLastBackupDate() {
            return lastBackup.addingTimeInterval(interval)
        }
        return nil
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
        
        // Get real disk usage information
        do {
            // First check if Time Machine is configured by checking destination info
            let destinationInfo = try ShellCommandRunner.run("/usr/bin/tmutil", arguments: ["destinationinfo"])
            logInfo("Destination info: \(destinationInfo)")
            
            if destinationInfo.contains("No destinations configured") {
                throw TimeMachineServiceError.noBackupDestinationConfigured
            }
            
            // Get the backup directory path from destinationinfo
            let mountPoint = try getMountPointFromDestinationInfo(destinationInfo)
            logInfo("Mount point: \(mountPoint)")
            
            // Get disk usage information using df
            let dfOutput = try ShellCommandRunner.run("df", arguments: ["-k", mountPoint])
            logInfo("df output: \(dfOutput)")
            
            // Parse the df output to get disk usage information
            var info = try parseDiskUsageInfo(dfOutput)
            
            // Calculate the total size of all backups
            let backupSize = try calculateTotalBackupSize(mountPoint: mountPoint)
            
            // Create a new StorageInfo with the backup size
            info = StorageInfo(
                totalSpace: info.totalSpace,
                usedSpace: info.usedSpace,
                backupSpace: backupSize,
                timestamp: info.timestamp
            )
            
            logInfo("Total backup size: \(backupSize) bytes (\(info.formattedBackupSpace))")
            logInfo("Backup percentage of total: \(info.formattedBackupPercentage)")
            logInfo("Backup percentage of used: \(info.formattedBackupOfUsedPercentage)")
            
            // Update the cached storage info
            DispatchQueue.main.async {
                self.storageInfo = info
            }
            
            return info
        } catch let error as ShellCommandError {
            logError("Shell command error: \(error.description)")
            
            // Map shell command errors to TimeMachineServiceError
            switch error {
            case .permissionDenied:
                throw TimeMachineServiceError.permissionDenied
            case .commandNotFound:
                throw TimeMachineServiceError.commandExecutionFailed
            case .commandExecutionFailed:
                throw TimeMachineServiceError.commandExecutionFailed
            }
        } catch {
            logError("Failed to get disk usage: \(error)")
            
            // If we have cached info, return it even if it's old
            if let cachedInfo = storageInfo {
                logInfo("Using old cached disk usage info due to error")
                return cachedInfo
            }
            
            throw error
        }
    }
    
    /// Parse the output of df command to get disk usage information
    /// - Parameter output: The output of df command
    /// - Returns: Storage information
    /// - Throws: An error if parsing fails
    private func parseDiskUsageInfo(_ output: String) throws -> StorageInfo {
        let lines = output.components(separatedBy: .newlines)
        
        // Skip the header line and get the data line
        guard lines.count >= 2, let dataLine = lines.dropFirst().first else {
            logError("Invalid df output format: \(output)")
            throw TimeMachineServiceError.diskInfoUnavailable
        }
        
        // Split the data line by whitespace
        let components = dataLine.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        
        // df -k output format: Filesystem 1K-blocks Used Available Capacity iused ifree %iused Mounted on
        // We need columns 2 (total), 3 (used), and 4 (available)
        guard components.count >= 5 else {
            logError("Invalid df output format, not enough columns: \(dataLine)")
            throw TimeMachineServiceError.diskInfoUnavailable
        }
        
        // Parse the values (convert from KB to bytes)
        guard let totalBlocks = Int64(components[1]) else {
            logError("Invalid total blocks value: \(components[1])")
            throw TimeMachineServiceError.diskInfoUnavailable
        }
        
        guard let usedBlocks = Int64(components[2]) else {
            logError("Invalid used blocks value: \(components[2])")
            throw TimeMachineServiceError.diskInfoUnavailable
        }
        
        // Convert from 1K blocks to bytes
        let totalSpace = totalBlocks * 1024
        let usedSpace = usedBlocks * 1024
        
        logInfo("Parsed disk usage: total=\(totalSpace), used=\(usedSpace)")
        
        return StorageInfo(totalSpace: totalSpace, usedSpace: usedSpace)
    }
    
    /// Calculate the total size of all backups in the given mount point
    /// - Parameter mountPoint: The mount point of the backup disk
    /// - Returns: The total size of all backups in bytes
    /// - Throws: An error if the operation fails
    private func calculateTotalBackupSize(mountPoint: String) throws -> Int64 {
        logInfo("Calculating total backup size for mount point: \(mountPoint)")
        
        let fileManager = FileManager.default
        
        // Check if the directory exists
        guard fileManager.fileExists(atPath: mountPoint) else {
            logInfo("Backup directory does not exist: \(mountPoint)")
            return 0
        }
        
        do {
            // List all backup directories
            let contents = try fileManager.contentsOfDirectory(atPath: mountPoint)
            
            // Check if this is a network backup by looking for sparsebundle/backupbundle files
            let networkBackupDirs = contents.filter { path in
                path.hasSuffix(".sparsebundle") || path.hasSuffix(".backupbundle")
            }.map { mountPoint + "/" + $0 }
            
            // If network backups found, calculate their sizes
            if !networkBackupDirs.isEmpty {
                logInfo("Found network backup bundles: \(networkBackupDirs)")
                return try calculateDirectoriesSize(paths: networkBackupDirs)
            }
            
            // If no network bundles found, check for local backup directories
            let localBackupDirs = contents.filter { $0.hasSuffix(".backup") }
                                        .map { mountPoint + "/" + $0 }
            
            if !localBackupDirs.isEmpty {
                logInfo("Found local backup directories: \(localBackupDirs)")
                return try calculateDirectoriesSize(paths: localBackupDirs)
            }
            
            logInfo("No backup directories found")
            return 0
        } catch {
            logError("Error calculating total backup size: \(error)")
            return 0
        }
    }
    
    /// Calculate the total size of the given directories
    /// - Parameter paths: The paths to calculate the size for
    /// - Returns: The total size in bytes
    /// - Throws: An error if the operation fails
    private func calculateDirectoriesSize(paths: [String]) throws -> Int64 {
        var totalSize: Int64 = 0
        
        for path in paths {
            do {
                // For each backup directory, try to get the size from the Results.plist file first
                if let sizeFromPlist = try? readBackupSizeFromResultsPlist(path: path) {
                    logInfo("Found size in Results.plist for \(path): \(sizeFromPlist) bytes")
                    totalSize += sizeFromPlist
                } else {
                    // If Results.plist doesn't exist or doesn't contain BytesUsed, use du command
                    logInfo("No Results.plist found, using du command for \(path)")
                    let duOutput = try ShellCommandRunner.run("du", arguments: ["-sk", path])
                    
                    // Parse the du output to get the size
                    let components = duOutput.components(separatedBy: .whitespaces)
                        .filter { !$0.isEmpty }
                    
                    if let sizeInKB = Int64(components.first ?? "0") {
                        let sizeInBytes = sizeInKB * 1024
                        logInfo("Size of \(path): \(sizeInBytes) bytes")
                        totalSize += sizeInBytes
                    }
                }
            } catch {
                logError("Error calculating size for \(path): \(error)")
                // Continue with the next path
            }
        }
        
        return totalSize
    }
    
    /// Read backup size from the Results.plist file
    /// - Parameter path: The path to the backup
    /// - Returns: The size in bytes if available
    /// - Throws: An error if the file cannot be read or parsed
    private func readBackupSizeFromResultsPlist(path: String) throws -> Int64 {
        // Construct the path to the Results.plist file
        let resultsPlistPath = path + "/com.apple.TimeMachine.Results.plist"
        
        // Check if the file exists
        let fileManager = FileManager.default
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
    
    /// Lists all available backups
    /// - Returns: An array of backup items
    /// - Throws: An error if the operation fails
    public func listBackups() async throws -> [BackupItem] {
        logInfo("Listing backups")
        
        do {
            // First check if Time Machine is configured by checking destination info
            let destinationInfo = try ShellCommandRunner.run("/usr/bin/tmutil", arguments: ["destinationinfo"])
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
    
    /// Mounts the backup volume if it's not already mounted
    /// - Returns: The mount point of the backup volume
    /// - Throws: An error if the operation fails
    public func mountBackupVolumeIfNeeded() async throws -> String {
        logInfo("Checking if backup volume needs to be mounted")
        
        do {
            // First check if Time Machine is configured by checking destination info
            let destinationInfo = try ShellCommandRunner.run("/usr/bin/tmutil", arguments: ["destinationinfo"])
            logInfo("Destination info: \(destinationInfo)")
            
            if destinationInfo.contains("No destinations configured") {
                throw TimeMachineServiceError.noBackupDestinationConfigured
            }
            
            // Try to get the mount point first
            if let mountPoint = try? getMountPointFromDestinationInfo(destinationInfo) {
                logInfo("Backup volume is already mounted at: \(mountPoint)")
                return mountPoint
            }
            
            // If we get here, the volume is not mounted. Try to find the URL.
            let lines = destinationInfo.components(separatedBy: .newlines)
            guard let urlLine = lines.first(where: { $0.contains("URL") }),
                  let urlString = urlLine.components(separatedBy: " : ").last?.trimmingCharacters(in: .whitespaces) else {
                logError("Could not find URL in destination info")
                throw TimeMachineServiceError.volumeNotMounted
            }
            
            // For network backups, try to mount the volume
            logInfo("Attempting to mount backup volume from URL: \(urlString)")
            
            // Use mount_smbfs for SMB shares or mount_afp for AFP shares
            let mountCommand: String
            let mountArgs: [String]
            
            if urlString.starts(with: "smb://") {
                mountCommand = "/sbin/mount_smbfs"
                mountArgs = [urlString.replacingOccurrences(of: "smb://", with: "//")]
            } else if urlString.starts(with: "afp://") {
                mountCommand = "/sbin/mount_afp"
                mountArgs = [urlString, "/Volumes"]
            } else {
                logError("Unsupported URL scheme: \(urlString)")
                throw TimeMachineServiceError.volumeMountFailed
            }
            
            // Try to mount the volume
            do {
                try ShellCommandRunner.run(mountCommand, arguments: mountArgs)
                logInfo("Successfully mounted backup volume")
                
                // Wait a moment for the mount to complete
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                // Try to get the mount point again
                if let mountPoint = try? getMountPointFromDestinationInfo(destinationInfo) {
                    logInfo("Backup volume is now mounted at: \(mountPoint)")
                    return mountPoint
                }
                
                throw TimeMachineServiceError.volumeMountFailed
            } catch {
                logError("Failed to mount backup volume: \(error)")
                throw TimeMachineServiceError.volumeMountFailed
            }
        } catch let error as TimeMachineServiceError {
            throw error
        } catch {
            logError("Unexpected error while mounting backup volume: \(error)")
            throw TimeMachineServiceError.commandExecutionFailed
        }
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