# Time Machine Backup Manager - Technical Specifications

This document provides detailed technical specifications for the core components of the Time Machine Backup Manager application, including service interfaces, data models, UI components, and system integration details.

## 1. Data Models

### BackupItem

Represents a single Time Machine backup snapshot.

```swift
struct BackupItem: Identifiable, Equatable {
    let id: UUID
    let path: String               // Full path to the backup
    let date: Date                 // Date and time of the backup
    let size: Int64?               // Size in bytes (optional as it may require calculation)
    let isComplete: Bool           // Whether the backup completed successfully
    
    // Computed properties
    var formattedDate: String { /* Date formatter logic */ }
    var formattedSize: String { /* Size formatter logic */ }
}
```

### StorageInfo

Represents disk usage information for the backup drive.

```swift
struct StorageInfo {
    let totalSpace: Int64          // Total capacity in bytes
    let usedSpace: Int64           // Used space in bytes
    let availableSpace: Int64      // Available space in bytes
    let backupVolumePath: String   // Path to the backup volume
    
    // Computed properties
    var usagePercentage: Double { /* Calculation logic */ }
    var formattedTotalSpace: String { /* Formatter logic */ }
    var formattedUsedSpace: String { /* Formatter logic */ }
    var formattedAvailableSpace: String { /* Formatter logic */ }
    
    var isLowSpace: Bool { /* Logic to determine if space is low */ }
    var isCriticalSpace: Bool { /* Logic to determine if space is critically low */ }
}
```

### SparsebundleInfo

Represents information about a Time Machine sparsebundle (network backup container).

```swift
struct SparsebundleInfo {
    let path: String               // Path to the sparsebundle
    let size: Int64                // Current size in bytes
    let bandSize: Int64            // Size of each band file
    let volumeName: String         // Name of the volume
    let isEncrypted: Bool          // Whether the sparsebundle is encrypted
    
    // Computed properties
    var formattedSize: String { /* Size formatter logic */ }
    var formattedBandSize: String { /* Size formatter logic */ }
}
```

### AppPreferences

Stores user preferences for the application.

```swift
struct AppPreferences: Codable {
    var backupScheduleFrequency: BackupFrequency = .daily
    var isBackupPaused: Bool = false
    var launchAtLogin: Bool = true
    var showAdvancedOptions: Bool = false
    var lowSpaceThreshold: Double = 0.8  // 80%
    var criticalSpaceThreshold: Double = 0.95  // 95%
    
    enum BackupFrequency: String, Codable, CaseIterable {
        case hourly
        case daily
        case weekly
        
        var displayName: String {
            switch self {
            case .hourly: return "Hourly"
            case .daily: return "Daily"
            case .weekly: return "Weekly"
            }
        }
    }
}
```

## 2. Service Interfaces

### TimeMachineService

Primary service for interacting with Time Machine functionality.

```swift
protocol TimeMachineServiceProtocol {
    // Backup Management
    func listBackups() async throws -> [BackupItem]
    func deleteBackup(_ backupId: String) async throws
    func startBackup() async throws
    func stopBackup() async throws
    func isBackupInProgress() async -> Bool
    
    // Disk Usage
    func getDiskUsage() async throws -> StorageInfo
    
    // Sparsebundle Operations (Advanced)
    func getSparsebundleInfo() async throws -> SparsebundleInfo?
    func resizeSparsebundle(newSize: Int64) async throws
    
    // Time Machine Status
    func isTimeMachineEnabled() async -> Bool
    func getLastBackupDate() async throws -> Date?
    func getNextBackupDate() async -> Date?
}

class TimeMachineService: TimeMachineServiceProtocol {
    // Implementation details not shown here
    // Will use ShellCommandRunner to execute tmutil and other commands
}
```

### BackupScanner

Service for periodically scanning backup state and notifying relevant components.

```swift
protocol BackupScannerProtocol {
    var delegate: BackupScannerDelegate? { get set }
    
    func startScanning(interval: TimeInterval)
    func stopScanning()
    func performSingleScan() async throws
}

protocol BackupScannerDelegate: AnyObject {
    func backupScannerDidUpdateBackups(_ backups: [BackupItem])
    func backupScannerDidUpdateDiskUsage(_ usage: StorageInfo)
    func backupScannerDidDetectLowSpace(_ usage: StorageInfo)
    func backupScannerDidDetectCriticalSpace(_ usage: StorageInfo)
    func backupScannerDidEncounterError(_ error: Error)
}

class BackupScanner: BackupScannerProtocol {
    // Implementation details not shown here
    // Will use TimeMachineService for the actual operations
}
```

### SchedulingService

Manages scheduling of backups according to user preferences.

```swift
protocol SchedulingServiceProtocol {
    func setBackupFrequency(_ frequency: AppPreferences.BackupFrequency)
    func pauseBackups()
    func resumeBackups()
    func isBackupPaused() -> Bool
    func getNextScheduledBackupDate() -> Date?
}

class SchedulingService: SchedulingServiceProtocol {
    // Implementation details not shown here
    // Will use LaunchAgent generation for scheduling
}
```

### StorageMonitor

Monitors disk usage and provides alerts when thresholds are reached.

```swift
protocol StorageMonitorProtocol {
    var delegate: StorageMonitorDelegate? { get set }
    
    func startMonitoring(interval: TimeInterval)
    func stopMonitoring()
    func checkStorageUsage() async throws -> StorageInfo
    func setLowSpaceThreshold(_ percentage: Double)
    func setCriticalSpaceThreshold(_ percentage: Double)
}

protocol StorageMonitorDelegate: AnyObject {
    func storageMonitorDidDetectLowSpace(_ usage: StorageInfo)
    func storageMonitorDidDetectCriticalSpace(_ usage: StorageInfo)
    func storageMonitorDidReturnToNormalSpace(_ usage: StorageInfo)
}

class StorageMonitor: StorageMonitorProtocol {
    // Implementation details not shown here
    // Will use TimeMachineService for disk usage information
}
```

### LaunchAtLoginService

Manages the "Launch at Login" capability.

```swift
protocol LaunchAtLoginServiceProtocol {
    func enableLaunchAtLogin() throws
    func disableLaunchAtLogin() throws
    func isLaunchAtLoginEnabled() -> Bool
}

class LaunchAtLoginService: LaunchAtLoginServiceProtocol {
    // Implementation details not shown here
    // Will use LaunchAgent/LaunchServices APIs
}
```

## 3. Utilities

### ShellCommandRunner

Utility for executing shell commands safely.

```swift
class ShellCommandRunner {
    enum ShellCommandError: Error {
        case executionFailed(command: String, exitCode: Int32, output: String)
        case commandNotFound(command: String)
        case permissionDenied(command: String)
    }
    
    static func run(_ command: String, arguments: [String]) async throws -> String
    static func runWithAdminPrivileges(_ command: String, arguments: [String]) async throws -> String
}
```

### Logger

Centralized logging utility.

```swift
enum LogLevel {
    case debug, info, warning, error, critical
}

class Logger {
    static func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line)
    static func getLogFileURL() -> URL?
}
```

## 4. UI Components

### Main Window

The main application window will use a NavigationSplitView with a sidebar for navigation and a detail view for content.

#### Navigation Sidebar Items:
- Dashboard (overview)
- Backups (list of backups)
- Storage (disk usage)
- Scheduling (backup schedule configuration)
- Advanced (expert features like sparsebundle management)
- Preferences (application settings)

### Dashboard View

```swift
struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    
    var body: some View {
        // Implementation will include:
        // - Last backup status/date
        // - Next scheduled backup time
        // - Disk usage overview bar
        // - Quick action buttons
    }
}
```

### Backup List View

```swift
struct BackupListView: View {
    @StateObject private var viewModel: BackupListViewModel
    
    var body: some View {
        // Implementation will include:
        // - List of backups with dates and sizes
        // - Delete action button for each backup
        // - Sort and filter options
        // - Refresh button
    }
}
```

### Storage Usage View

```swift
struct StorageUsageView: View {
    @StateObject private var viewModel: StorageUsageViewModel
    
    var body: some View {
        // Implementation will include:
        // - Visual representation of storage usage
        // - Total, used, and available space
        // - Warning indicators for low space
        // - Breakdown of space usage by backup (if available)
    }
}
```

### Menu Bar Component

```swift
struct MenuBarView: NSViewRepresentable {
    @ObservedObject var viewModel: MenuBarViewModel
    
    // Implementation details for creating and updating NSStatusItem
    // Will show:
    // - Current backup status
    // - Last backup time
    // - Next backup time
    // - Quick actions (Backup Now, Pause, Open Main Window)
}
```

## 5. ViewModels

Each view will have a corresponding ViewModel that will handle business logic and communication with services.

```swift
class BackupListViewModel: ObservableObject {
    @Published var backups: [BackupItem] = []
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    
    // Dependencies
    private let timeMachineService: TimeMachineServiceProtocol
    private let backupScanner: BackupScannerProtocol
    
    // Methods for loading, deleting backups, etc.
}

class StorageUsageViewModel: ObservableObject {
    @Published var storageInfo: StorageInfo? = nil
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    
    // Dependencies
    private let timeMachineService: TimeMachineServiceProtocol
    private let storageMonitor: StorageMonitorProtocol
    
    // Methods for monitoring storage, etc.
}

class SchedulingViewModel: ObservableObject {
    @Published var frequency: AppPreferences.BackupFrequency = .daily
    @Published var isPaused: Bool = false
    @Published var nextBackupDate: Date? = nil
    
    // Dependencies
    private let schedulingService: SchedulingServiceProtocol
    
    // Methods for controlling scheduling
}

class MenuBarViewModel: ObservableObject {
    @Published var lastBackupDate: Date? = nil
    @Published var nextBackupDate: Date? = nil
    @Published var isBackupInProgress: Bool = false
    @Published var isBackupPaused: Bool = false
    @Published var storageInfo: StorageInfo? = nil
    
    // Dependencies
    private let timeMachineService: TimeMachineServiceProtocol
    private let schedulingService: SchedulingServiceProtocol
    private let storageMonitor: StorageMonitorProtocol
    
    // Methods for controlling the menu bar and handling actions
}
```

## 6. Persistence

The application will use UserDefaults for storing basic preferences and application state.

```swift
class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    // Keys
    private let backupFrequencyKey = "backupFrequency"
    private let backupPausedKey = "backupPaused"
    private let launchAtLoginKey = "launchAtLogin"
    private let showAdvancedOptionsKey = "showAdvancedOptions"
    private let lowSpaceThresholdKey = "lowSpaceThreshold"
    private let criticalSpaceThresholdKey = "criticalSpaceThreshold"
    
    // Methods for getting and setting preferences
    func getAppPreferences() -> AppPreferences
    func saveAppPreferences(_ preferences: AppPreferences)
}
```

## 7. System Integration

### Notifications

The application will use the UserNotification framework to display alerts.

```swift
class NotificationManager {
    static let shared = NotificationManager()
    
    enum NotificationType {
        case backupCompleted
        case backupFailed
        case lowDiskSpace
        case criticalDiskSpace
    }
    
    func requestNotificationPermission()
    func sendNotification(type: NotificationType, info: [String: Any]? = nil)
}
```

### Launch Agent

For the "Launch at Login" functionality, the application will create a Launch Agent plist file.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.app.TimeMachineBackupManager</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Applications/TimeMachineBackupManager.app/Contents/MacOS/TimeMachineBackupManager</string>
        <string>--background</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
```

## 8. Error Handling

The application will use a structured approach to error handling, with specific error types for different categories of errors.

```swift
enum AppError: Error {
    // Time Machine Service Errors
    case backupListingFailed(underlyingError: Error?)
    case backupDeletionFailed(backupId: String, underlyingError: Error?)
    case diskUsageCheckFailed(underlyingError: Error?)
    case sparsebundleInfoFailed(underlyingError: Error?)
    case sparsebundleResizeFailed(newSize: Int64, underlyingError: Error?)
    
    // Permission Errors
    case permissionDenied(operation: String)
    
    // Shell Command Errors
    case commandExecutionFailed(command: String, exitCode: Int32, output: String)
    
    // Scheduling Errors
    case schedulingFailed(frequency: AppPreferences.BackupFrequency, underlyingError: Error?)
    
    // Launch at Login Errors
    case launchAtLoginSetupFailed(underlyingError: Error?)
    
    // UI-related Errors
    case unexpectedState(context: String)
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        // Localized descriptions for each error case
    }
    
    var failureReason: String? {
        // Failure reasons for each error case
    }
    
    var recoverySuggestion: String? {
        // Recovery suggestions for each error case
    }
}
```

## 9. Testing Strategy

### Unit Tests

Each service will have corresponding unit tests to verify its behavior.

```swift
class TimeMachineServiceTests: XCTestCase {
    var service: TimeMachineService!
    var mockShellRunner: MockShellCommandRunner!
    
    override func setUp() {
        mockShellRunner = MockShellCommandRunner()
        service = TimeMachineService(shellRunner: mockShellRunner)
    }
    
    func testListBackups() async throws {
        // Test implementation
    }
    
    func testDeleteBackup() async throws {
        // Test implementation
    }
    
    // More tests for each method
}
```

### UI Tests

Key user flows will have UI tests to ensure they work correctly.

```swift
class BackupManagementUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        app = XCUIApplication()
        app.launch()
    }
    
    func testViewBackupsList() {
        // Test implementation
    }
    
    func testDeleteBackup() {
        // Test implementation
    }
    
    // More tests for user flows
}
```

## 10. Security Considerations

The application will need full disk access to interact with Time Machine backups. It will:

1. Request the necessary permissions using the appropriate entitlements
2. Provide clear guidance to the user on how to grant permissions if needed
3. Securely handle any sensitive information
4. Use the principle of least privilege for all operations

## 11. Internationalization

The application will support internationalization through:

1. Use of localized strings for all user-facing text
2. Appropriate date and number formatters that respect the user's locale
3. Support for right-to-left languages in the UI layout

## 12. Accessibility

The application will ensure accessibility through:

1. Proper labeling of UI elements for VoiceOver
2. Support for keyboard navigation
3. Sufficient color contrast
4. Appropriate text sizing and scaling

## Conclusion

This technical specification provides a comprehensive blueprint for implementing the Time Machine Backup Manager application. It covers data models, service interfaces, UI components, error handling, and other critical aspects of the system. Following these specifications will ensure a structured, maintainable, and user-friendly application. 