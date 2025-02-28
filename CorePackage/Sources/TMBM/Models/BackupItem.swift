import Foundation
import Combine

/// Model for representing a Time Machine backup
public class BackupItem: Identifiable, ObservableObject, @unchecked Sendable {
    /// Unique identifier for the backup
    public let id: UUID
    
    /// Name of the backup
    public let name: String
    
    /// Path to the backup
    public let path: String
    
    /// Date of the backup
    public let date: Date
    
    /// Size of the backup in bytes
    @Published public private(set) var size: Int64
    
    /// Whether the size is currently being calculated
    @Published public private(set) var isCalculatingSize: Bool
    
    /// Formatted size of the backup
    public var formattedSize: String {
        if isCalculatingSize {
            return "Calculating..."
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    /// Formatted date of the backup
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Initializes a new instance of BackupItem
    /// - Parameters:
    ///   - id: Unique identifier for the backup
    ///   - name: Name of the backup
    ///   - path: Path to the backup
    ///   - date: Date of the backup
    ///   - size: Size of the backup in bytes
    ///   - isCalculatingSize: Whether the size is currently being calculated
    public init(id: UUID = UUID(), name: String, path: String, date: Date, size: Int64, isCalculatingSize: Bool = true) {
        self.id = id
        self.name = name
        self.path = path
        self.date = date
        self.size = size
        self.isCalculatingSize = isCalculatingSize
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
    
    /// Updates the size of the backup
    /// - Parameter newSize: The new size in bytes
    public func updateSize(_ newSize: Int64) {
        // Explicitly trigger objectWillChange to ensure UI updates
        objectWillChange.send()
        self.size = newSize
        self.isCalculatingSize = false
    }
}

extension BackupItem: Equatable {
    public static func == (lhs: BackupItem, rhs: BackupItem) -> Bool {
        lhs.id == rhs.id
    }
} 