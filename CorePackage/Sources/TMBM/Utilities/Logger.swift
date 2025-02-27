import Foundation
import os.log

/// Log levels for the application
public enum LogLevel {
    case debug
    case info
    case warning
    case error
    case critical
    
    /// Maps the log level to the corresponding OSLogType
    var osLogType: OSLogType {
        switch self {
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .default
        case .error:
            return .error
        case .critical:
            return .fault
        }
    }
}

/// Centralized logging utility for the application
public class Logger {
    /// The OSLog instance for system logging
    private static let log = OSLog(subsystem: "com.tmbm.app", category: "TimeMachineBackupManager")
    
    /// Date formatter for log entries
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    /// URL for the log file
    private static var logFileURL: URL? = {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let logsDirectory = documentsDirectory.appendingPathComponent("TMBM/Logs")
        
        // Create logs directory if it doesn't exist
        if !fileManager.fileExists(atPath: logsDirectory.path) {
            do {
                try fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
            } catch {
                os_log("Failed to create logs directory: %@", log: log, type: .error, error.localizedDescription)
                return nil
            }
        }
        
        // Create log file name with current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fileName = "\(dateFormatter.string(from: Date())).log"
        
        return logsDirectory.appendingPathComponent(fileName)
    }()
    
    /// Logs a message with the specified log level
    /// - Parameters:
    ///   - message: The message to log
    ///   - level: The log level
    public static func log(_ message: String, level: LogLevel) {
        // Format the log message
        let timestamp = dateFormatter.string(from: Date())
        let logMessage = "[\(timestamp)] [\(level)] \(message)"
        
        // Log to system log
        os_log("%{public}@", log: log, type: level.osLogType, logMessage)
        
        // Log to file
        logToFile(logMessage)
    }
    
    /// Writes a log message to the log file
    /// - Parameter message: The message to write
    private static func logToFile(_ message: String) {
        guard let logFileURL = logFileURL else {
            os_log("Log file URL is nil", log: log, type: .error)
            return
        }
        
        let fileManager = FileManager.default
        
        // Create file if it doesn't exist
        if !fileManager.fileExists(atPath: logFileURL.path) {
            fileManager.createFile(atPath: logFileURL.path, contents: nil)
        }
        
        // Append message to file
        do {
            let fileHandle = try FileHandle(forWritingTo: logFileURL)
            fileHandle.seekToEndOfFile()
            if let data = "\(message)\n".data(using: .utf8) {
                fileHandle.write(data)
            }
            fileHandle.closeFile()
        } catch {
            os_log("Failed to write to log file: %@", log: log, type: .error, error.localizedDescription)
        }
    }
} 