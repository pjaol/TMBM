import Foundation

struct StorageInfo {
    let totalSpace: Int64
    let usedSpace: Int64
    let availableSpace: Int64
    let backupVolumePath: String
    
    // Default thresholds
    var lowSpaceThreshold: Double = 0.8  // 80%
    var criticalSpaceThreshold: Double = 0.95  // 95%
    
    // Computed properties
    var usagePercentage: Double {
        guard totalSpace > 0 else { return 0 }
        return Double(usedSpace) / Double(totalSpace)
    }
    
    var formattedTotalSpace: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalSpace)
    }
    
    var formattedUsedSpace: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: usedSpace)
    }
    
    var formattedAvailableSpace: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: availableSpace)
    }
    
    var isLowSpace: Bool {
        return usagePercentage >= lowSpaceThreshold
    }
    
    var isCriticalSpace: Bool {
        return usagePercentage >= criticalSpaceThreshold
    }
    
    // For preview and testing
    static var mockStorageInfo: StorageInfo {
        return StorageInfo(
            totalSpace: 1_000_000_000_000,  // 1 TB
            usedSpace: 300_000_000_000,     // 300 GB
            availableSpace: 700_000_000_000, // 700 GB
            backupVolumePath: "/Volumes/TimeMachine"
        )
    }
    
    static var mockLowSpaceInfo: StorageInfo {
        return StorageInfo(
            totalSpace: 1_000_000_000_000,  // 1 TB
            usedSpace: 850_000_000_000,     // 850 GB
            availableSpace: 150_000_000_000, // 150 GB
            backupVolumePath: "/Volumes/TimeMachine"
        )
    }
    
    static var mockCriticalSpaceInfo: StorageInfo {
        return StorageInfo(
            totalSpace: 1_000_000_000_000,  // 1 TB
            usedSpace: 970_000_000_000,     // 970 GB
            availableSpace: 30_000_000_000,  // 30 GB
            backupVolumePath: "/Volumes/TimeMachine"
        )
    }
} 