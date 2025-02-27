import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    
    private var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request notification permissions
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
        
        // Setup any background services or observers here
        setupServices()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up any resources when app terminates
    }
    
    // MARK: - Notification Delegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               willPresent notification: UNNotification, 
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handle notifications when app is in foreground
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               didReceive response: UNNotificationResponse, 
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification response (e.g., user clicked on notification)
        completionHandler()
    }
    
    // MARK: - Private Methods
    
    private func setupServices() {
        // Initialize and configure services
        // This will be expanded as we implement more services
    }
} 