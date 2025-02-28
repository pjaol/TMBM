import Foundation

/// Model for representing storage information
public struct StorageInfo {
    /// Total space in bytes
    public let totalSpace: Int64
    
    /// Used space in bytes
    public let usedSpace: Int64
    
    /// Timestamp when this information was collected
    public let timestamp: Date
    
    /// Available space in bytes
    public var availableSpace: Int64 {
        totalSpace - usedSpace
    }
    
    /// Usage percentage (0-100)
    public var usagePercentage: Double {
        Double(usedSpace) / Double(totalSpace) * 100
    }
    
    /// Formatted total space
    public var formattedTotalSpace: String {
        ByteCountFormatter.string(fromByteCount: totalSpace, countStyle: .file)
    }
    
    /// Formatted used space
    public var formattedUsedSpace: String {
        ByteCountFormatter.string(fromByteCount: usedSpace, countStyle: .file)
    }
    
    /// Formatted available space
    public var formattedAvailableSpace: String {
        ByteCountFormatter.string(fromByteCount: availableSpace, countStyle: .file)
    }
    
    /// Formatted usage percentage
    public var formattedUsagePercentage: String {
        String(format: "%.1f%%", usagePercentage)
    }
    
    /// Initializes a new instance of StorageInfo
    /// - Parameters:
    ///   - totalSpace: Total space in bytes
    ///   - usedSpace: Used space in bytes
    ///   - timestamp: When this information was collected (defaults to current time)
    public init(totalSpace: Int64, usedSpace: Int64, timestamp: Date = Date()) {
        self.totalSpace = totalSpace
        self.usedSpace = usedSpace
        self.timestamp = timestamp
    }
    
    /// Creates a mock storage info for testing
    /// - Returns: A mock storage info
    public static func mockStorageInfo() -> StorageInfo {
        StorageInfo(
            totalSpace: 2_000_000_000_000, // 2 TB
            usedSpace: 1_500_000_000_000, // 1.5 TB
            timestamp: Date()
        )
    }
} 