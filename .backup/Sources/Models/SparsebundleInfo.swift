import Foundation

struct SparsebundleInfo {
    let path: String
    let size: Int64
    let bandSize: Int64
    let volumeName: String
    let isEncrypted: Bool
    
    // Computed properties
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    var formattedBandSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bandSize)
    }
    
    // For preview and testing
    static var mockSparsebundleInfo: SparsebundleInfo {
        return SparsebundleInfo(
            path: "/Volumes/NAS/TimeMachine.sparsebundle",
            size: 1_000_000_000_000,  // 1 TB
            bandSize: 8_388_608,      // 8 MB
            volumeName: "Time Machine",
            isEncrypted: true
        )
    }
} 