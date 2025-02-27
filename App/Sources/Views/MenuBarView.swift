import SwiftUI
import TMBM

struct MenuBarView: View {
    @StateObject private var viewModel = MenuBarViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Status Header
            HStack {
                Image(systemName: viewModel.statusImage)
                    .foregroundColor(viewModel.statusColor)
                Text("Time Machine Status")
                    .font(.headline)
            }
            
            Divider()
            
            // Backup Status
            Text(viewModel.backupStatus)
                .foregroundColor(viewModel.statusColor)
            
            if let nextDate = viewModel.nextBackupDate {
                Text("Next backup: \(RelativeDateTimeFormatter().localizedString(for: nextDate, relativeTo: Date()))")
            }
            
            // Storage Info
            if let storage = viewModel.storageInfo {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Storage")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: storage.usagePercentage, total: 100) {
                        Text(storage.formattedUsagePercentage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .tint(storage.usagePercentage >= 90 ? .red :
                          storage.usagePercentage >= 75 ? .yellow : .blue)
                    
                    Text("\(storage.formattedUsedSpace) used of \(storage.formattedTotalSpace)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Actions
            VStack(spacing: 8) {
                if viewModel.isBackupRunning {
                    Button("Stop Backup") {
                        viewModel.stopBackup()
                    }
                    .foregroundColor(.red)
                } else {
                    Button("Start Backup") {
                        viewModel.startBackup()
                    }
                }
                
                Button("Open Backup Manager") {
                    NSApp.activate(ignoringOtherApps: true)
                }
                
                Button("Quit") {
                    NSApp.terminate(nil)
                }
            }
        }
        .padding()
        .frame(width: 280)
        .onAppear {
            viewModel.updateStatus()
        }
    }
} 