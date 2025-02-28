import Foundation

/// Model for representing storage information
public struct StorageInfo {
    /// Total space in bytes
    public let totalSpace: Int64
    
    /// Used space in bytes
    public let usedSpace: Int64
    
    /// Space used by backups in bytes
    public let backupSpace: Int64
    
    /// Timestamp when this information was collected
    public let timestamp: Date
    
    /// Available space in bytes
    public var availableSpace: Int64 {
        totalSpace - usedSpace
    }
    
    /// Non-backup used space in bytes
    public var nonBackupSpace: Int64 {
        usedSpace - backupSpace
    }
    
    /// Usage percentage (0-100)
    public var usagePercentage: Double {
        Double(usedSpace) / Double(totalSpace) * 100
    }
    
    /// Backup usage percentage relative to total space (0-100)
    public var backupPercentage: Double {
        Double(backupSpace) / Double(totalSpace) * 100
    }
    
    /// Non-backup usage percentage relative to total space (0-100)
    public var nonBackupPercentage: Double {
        Double(nonBackupSpace) / Double(totalSpace) * 100
    }
    
    /// Backup usage percentage relative to used space (0-100)
    public var backupOfUsedPercentage: Double {
        usedSpace > 0 ? Double(backupSpace) / Double(usedSpace) * 100 : 0
    }
    
    /// Formatted total space
    public var formattedTotalSpace: String {
        ByteCountFormatter.string(fromByteCount: totalSpace, countStyle: .file)
    }
    
    /// Formatted used space
    public var formattedUsedSpace: String {
        ByteCountFormatter.string(fromByteCount: usedSpace, countStyle: .file)
    }
    
    /// Formatted backup space
    public var formattedBackupSpace: String {
        ByteCountFormatter.string(fromByteCount: backupSpace, countStyle: .file)
    }
    
    /// Formatted non-backup space
    public var formattedNonBackupSpace: String {
        ByteCountFormatter.string(fromByteCount: nonBackupSpace, countStyle: .file)
    }
    
    /// Formatted available space
    public var formattedAvailableSpace: String {
        ByteCountFormatter.string(fromByteCount: availableSpace, countStyle: .file)
    }
    
    /// Formatted usage percentage
    public var formattedUsagePercentage: String {
        String(format: "%.1f%%", usagePercentage)
    }
    
    /// Formatted backup percentage
    public var formattedBackupPercentage: String {
        String(format: "%.1f%%", backupPercentage)
    }
    
    /// Formatted non-backup percentage
    public var formattedNonBackupPercentage: String {
        String(format: "%.1f%%", nonBackupPercentage)
    }
    
    /// Formatted backup of used percentage
    public var formattedBackupOfUsedPercentage: String {
        String(format: "%.1f%%", backupOfUsedPercentage)
    }
    
    /// Initializes a new instance of StorageInfo
    /// - Parameters:
    ///   - totalSpace: Total space in bytes
    ///   - usedSpace: Used space in bytes
    ///   - backupSpace: Space used by backups in bytes
    ///   - timestamp: When this information was collected (defaults to current time)
    public init(totalSpace: Int64, usedSpace: Int64, backupSpace: Int64 = 0, timestamp: Date = Date()) {
        self.totalSpace = totalSpace
        self.usedSpace = usedSpace
        self.backupSpace = backupSpace
        self.timestamp = timestamp
    }
    
    /// Creates a mock storage info for testing
    /// - Returns: A mock storage info
    public static func mockStorageInfo() -> StorageInfo {
        StorageInfo(
            totalSpace: 2_000_000_000_000, // 2 TB
            usedSpace: 1_500_000_000_000, // 1.5 TB
            backupSpace: 1_200_000_000_000, // 1.2 TB
            timestamp: Date()
        )
    }
} 