import Foundation

struct BackupItem: Identifiable, Equatable {
    let id: UUID = UUID()
    let path: String
    let date: Date
    let size: Int64?
    let isComplete: Bool
    
    // Computed properties
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedSize: String {
        guard let size = size else {
            return "Unknown size"
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    // For preview and testing
    static var mockItems: [BackupItem] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            BackupItem(
                path: "/Volumes/TimeMachine/Backups.backupdb/Mac/2023-10-01-120000",
                date: calendar.date(byAdding: .day, value: -7, to: now)!,
                size: 1_000_000_000,
                isComplete: true
            ),
            BackupItem(
                path: "/Volumes/TimeMachine/Backups.backupdb/Mac/2023-10-02-120000",
                date: calendar.date(byAdding: .day, value: -6, to: now)!,
                size: 1_100_000_000,
                isComplete: true
            ),
            BackupItem(
                path: "/Volumes/TimeMachine/Backups.backupdb/Mac/2023-10-03-120000",
                date: calendar.date(byAdding: .day, value: -5, to: now)!,
                size: 1_200_000_000,
                isComplete: true
            ),
            BackupItem(
                path: "/Volumes/TimeMachine/Backups.backupdb/Mac/2023-10-04-120000",
                date: calendar.date(byAdding: .day, value: -4, to: now)!,
                size: 1_300_000_000,
                isComplete: true
            ),
            BackupItem(
                path: "/Volumes/TimeMachine/Backups.backupdb/Mac/2023-10-05-120000",
                date: calendar.date(byAdding: .day, value: -3, to: now)!,
                size: 1_400_000_000,
                isComplete: true
            ),
            BackupItem(
                path: "/Volumes/TimeMachine/Backups.backupdb/Mac/2023-10-06-120000",
                date: calendar.date(byAdding: .day, value: -2, to: now)!,
                size: 1_500_000_000,
                isComplete: true
            ),
            BackupItem(
                path: "/Volumes/TimeMachine/Backups.backupdb/Mac/2023-10-07-120000",
                date: calendar.date(byAdding: .day, value: -1, to: now)!,
                size: 1_600_000_000,
                isComplete: true
            ),
            BackupItem(
                path: "/Volumes/TimeMachine/Backups.backupdb/Mac/2023-10-08-120000",
                date: now,
                size: nil,
                isComplete: false
            )
        ]
    }
} 