import Foundation
import UserNotifications

enum NotificationType {
    case backupStarted
    case backupCompleted
    case backupFailed(Error)
    case lowDiskSpace(available: String)
    case criticalDiskSpace(available: String)
    case custom(title: String, body: String)
    
    var title: String {
        switch self {
        case .backupStarted:
            return "Backup Started"
        case .backupCompleted:
            return "Backup Completed"
        case .backupFailed:
            return "Backup Failed"
        case .lowDiskSpace:
            return "Low Disk Space"
        case .criticalDiskSpace:
            return "Critical Disk Space"
        case .custom(let title, _):
            return title
        }
    }
    
    var body: String {
        switch self {
        case .backupStarted:
            return "Time Machine has started a new backup."
        case .backupCompleted:
            return "Time Machine has successfully completed a backup."
        case .backupFailed(let error):
            return "Time Machine backup failed: \(error.localizedDescription)"
        case .lowDiskSpace(let available):
            return "Your backup disk is running low on space. Available: \(available)"
        case .criticalDiskSpace(let available):
            return "Your backup disk is critically low on space! Available: \(available)"
        case .custom(_, let body):
            return body
        }
    }
    
    var identifier: String {
        switch self {
        case .backupStarted:
            return "com.pjaol.tmbm.notification.backupStarted"
        case .backupCompleted:
            return "com.pjaol.tmbm.notification.backupCompleted"
        case .backupFailed:
            return "com.pjaol.tmbm.notification.backupFailed"
        case .lowDiskSpace:
            return "com.pjaol.tmbm.notification.lowDiskSpace"
        case .criticalDiskSpace:
            return "com.pjaol.tmbm.notification.criticalDiskSpace"
        case .custom:
            return "com.pjaol.tmbm.notification.custom.\(UUID().uuidString)"
        }
    }
}

class NotificationService {
    static let shared = NotificationService()
    
    private init() {
        requestAuthorization()
    }
    
    // Request permission to show notifications
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                Logger.log("Notification permission granted", level: .info)
            } else if let error = error {
                Logger.log("Notification permission denied: \(error.localizedDescription)", level: .error)
            }
        }
    }
    
    // Send a notification
    func sendNotification(type: NotificationType, delay: TimeInterval = 0) {
        let content = UNMutableNotificationContent()
        content.title = type.title
        content.body = type.body
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: type.identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.log("Failed to send notification: \(error.localizedDescription)", level: .error)
            } else {
                Logger.log("Notification scheduled: \(type.title)", level: .info)
            }
        }
    }
    
    // Remove pending notifications
    func removePendingNotifications(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // Remove all pending notifications
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // Check if we have permission to send notifications
    func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let isAuthorized = settings.authorizationStatus == .authorized
            completion(isAuthorized)
        }
    }
    
    // Send a test notification
    func sendTestNotification() {
        sendNotification(type: .custom(
            title: "Test Notification",
            body: "This is a test notification from Time Machine Backup Manager."
        ))
    }
    
    // Send a notification based on storage info
    func checkAndNotifyForLowDiskSpace(storageInfo: StorageInfo, lowThreshold: Double, criticalThreshold: Double) {
        let availableGB = Double(storageInfo.availableSpace) / 1_000_000_000
        
        if availableGB < criticalThreshold {
            sendNotification(type: .criticalDiskSpace(available: storageInfo.formattedAvailableSpace))
        } else if availableGB < lowThreshold {
            sendNotification(type: .lowDiskSpace(available: storageInfo.formattedAvailableSpace))
        }
    }
} 