import SwiftUI
import TMBM

struct DiskUsageView: View {
    @State private var storageInfo: StorageInfo? = nil
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    
    private let timeMachineService = TimeMachineService()
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading disk usage...")
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                Button("Retry") {
                    loadDiskUsage()
                }
            } else if let info = storageInfo {
                VStack(spacing: 20) {
                    Text("Backup Disk Usage")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ProgressView(value: info.usagePercentage, total: 100) {
                            Text(info.formattedUsagePercentage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .tint(info.usagePercentage >= 90 ? .red :
                              info.usagePercentage >= 75 ? .yellow : .blue)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Used Space")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(info.formattedUsedSpace)
                                    .font(.title2)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Available Space")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(info.formattedAvailableSpace)
                                    .font(.title2)
                            }
                        }
                        
                        Text("Total Space: \(info.formattedTotalSpace)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor))
                    .cornerRadius(8)
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadDiskUsage()
        }
    }
    
    private func loadDiskUsage() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                storageInfo = try timeMachineService.getDiskUsage()
            } catch {
                errorMessage = "Failed to load disk usage: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
} 