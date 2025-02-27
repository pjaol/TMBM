import Foundation
import os.log

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
    
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        case .critical: return .fault
        }
    }
}

class Logger {
    private static let osLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.app.TimeMachineBackupManager", category: "TMBM")
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    private static var logFileURL: URL? = {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let logsDirectory = documentsDirectory.appendingPathComponent("Logs")
        
        do {
            try FileManager.default.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: Date())
            
            return logsDirectory.appendingPathComponent("tmbm-\(dateString).log")
        } catch {
            os_log("Failed to create logs directory: %@", log: osLog, type: .error, error.localizedDescription)
            return nil
        }
    }()
    
    /// Log a message with the specified level
    /// - Parameters:
    ///   - message: The message to log
    ///   - level: The log level
    ///   - file: The file where the log was called from
    ///   - function: The function where the log was called from
    ///   - line: The line number where the log was called from
    static func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "[\(level.rawValue)] [\(fileName):\(line) \(function)] \(message)"
        
        // Log to system log
        os_log("%{public}@", log: osLog, type: level.osLogType, logMessage)
        
        // Log to file
        logToFile(logMessage)
    }
    
    /// Get the URL of the current log file
    /// - Returns: The URL of the log file, or nil if it couldn't be created
    static func getLogFileURL() -> URL? {
        return logFileURL
    }
    
    // MARK: - Private Methods
    
    private static func logToFile(_ message: String) {
        guard let logFileURL = logFileURL else { return }
        
        let timestamp = dateFormatter.string(from: Date())
        let logEntry = "\(timestamp) \(message)\n"
        
        do {
            let fileHandle = try FileHandle(forWritingTo: logFileURL)
            fileHandle.seekToEndOfFile()
            if let data = logEntry.data(using: .utf8) {
                fileHandle.write(data)
            }
            fileHandle.closeFile()
        } catch {
            // File doesn't exist, create it
            if (error as NSError).domain == NSCocoaErrorDomain && (error as NSError).code == NSFileNoSuchFileError {
                try? logEntry.data(using: .utf8)?.write(to: logFileURL, options: .atomic)
            } else {
                os_log("Failed to write to log file: %@", log: osLog, type: .error, error.localizedDescription)
            }
        }
    }
} 