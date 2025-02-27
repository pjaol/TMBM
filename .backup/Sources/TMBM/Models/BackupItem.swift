import Foundation

/// Model for representing a Time Machine backup
public struct BackupItem: Identifiable {
    /// Unique identifier for the backup
    public let id: UUID
    
    /// Name of the backup
    public let name: String
    
    /// Path to the backup
    public let path: String
    
    /// Date of the backup
    public let date: Date
    
    /// Size of the backup in bytes
    public let size: Int64
    
    /// Formatted size of the backup
    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    /// Formatted date of the backup
    public var formattedDate: String {
        DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
    }
    
    /// Initializes a new instance of BackupItem
    /// - Parameters:
    ///   - id: Unique identifier for the backup
    ///   - name: Name of the backup
    ///   - path: Path to the backup
    ///   - date: Date of the backup
    ///   - size: Size of the backup in bytes
    public init(id: UUID = UUID(), name: String, path: String, date: Date, size: Int64) {
        self.id = id
        self.name = name
        self.path = path
        self.date = date
        self.size = size
    }
    
    /// Creates a mock backup item for testing
    /// - Returns: A mock backup item
    public static func mockBackupItem() -> BackupItem {
        BackupItem(
            name: "Backup 2023-01-01-120000",
            path: "/Volumes/TimeMachine/Backups.backupdb/MyMac/2023-01-01-120000",
            date: Date().addingTimeInterval(-86400), // 1 day ago
            size: 50_000_000_000 // 50 GB
        )
    }
    
    /// Creates an array of mock backup items for testing
    /// - Parameter count: Number of mock items to create
    /// - Returns: An array of mock backup items
    public static func mockBackupItems(count: Int = 5) -> [BackupItem] {
        var items: [BackupItem] = []
        
        for i in 0..<count {
            let date = Date().addingTimeInterval(Double(-i) * 86400) // i days ago
            let name = "Backup \(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short))"
            let size = Int64(50_000_000_000 - (i * 1_000_000_000)) // Decreasing sizes
            
            items.append(BackupItem(
                name: name,
                path: "/Volumes/TimeMachine/Backups.backupdb/MyMac/\(name)",
                date: date,
                size: size
            ))
        }
        
        return items
    }
} 