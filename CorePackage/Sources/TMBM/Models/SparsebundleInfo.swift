import Foundation

/// Model for representing Time Machine sparsebundle information
public struct SparsebundleInfo {
    /// Path to the sparsebundle file
    public let path: String
    
    /// Size of the sparsebundle in bytes
    public let size: Int64
    
    /// Size of each band in bytes
    public let bandSize: Int64
    
    /// Name of the volume
    public let volumeName: String
    
    /// Whether the sparsebundle is encrypted
    public let isEncrypted: Bool
    
    /// Formatted size of the sparsebundle
    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    /// Formatted band size
    public var formattedBandSize: String {
        ByteCountFormatter.string(fromByteCount: bandSize, countStyle: .file)
    }
    
    /// Initializes a new instance of SparsebundleInfo
    /// - Parameters:
    ///   - path: Path to the sparsebundle file
    ///   - size: Size of the sparsebundle in bytes
    ///   - bandSize: Size of each band in bytes
    ///   - volumeName: Name of the volume
    ///   - isEncrypted: Whether the sparsebundle is encrypted
    public init(path: String, size: Int64, bandSize: Int64, volumeName: String, isEncrypted: Bool) {
        self.path = path
        self.size = size
        self.bandSize = bandSize
        self.volumeName = volumeName
        self.isEncrypted = isEncrypted
    }
    
    /// A mock sparsebundle info for testing
    public static var mockSparsebundleInfo: SparsebundleInfo {
        SparsebundleInfo(
            path: "/Volumes/Backups/MyMac.sparsebundle",
            size: 1_000_000_000_000, // 1 TB
            bandSize: 8_388_608, // 8 MB
            volumeName: "Time Machine",
            isEncrypted: true
        )
    }
} 