import SwiftUI
import TMBM
import AppKit
import Charts

struct DiskUsageView: View {
    @StateObject private var timeMachineService = TimeMachineService()
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            // Add some padding at the top
            Spacer()
                .frame(height: 16)
                
            if isLoading {
                ProgressView("Loading disk usage information...")
                    .padding()
            } else if let error = errorMessage {
                VStack {
                    Text("Error loading disk usage")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    Text(error)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Retry") {
                        loadData()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if let info = timeMachineService.storageInfo {
                // Info note
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("Sparsebundle calculations are approximate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Chart section
                VStack(alignment: .leading, spacing: 12) {
                    // Chart with separate bars
                    Chart {
                        // Backup space
                        BarMark(
                            x: .value("Category", "Backups"),
                            y: .value("Size", Double(info.backupSpace))
                        )
                        .foregroundStyle(.green)
                        .annotation(position: .top) {
                            Text(info.formattedBackupSpace)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Free space
                        BarMark(
                            x: .value("Category", "Free"),
                            y: .value("Size", Double(info.availableSpace))
                        )
                        .foregroundStyle(.blue.opacity(0.6))
                        .annotation(position: .top) {
                            Text(info.formattedAvailableSpace)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Only show Other if it's significant
                        let nonBackupSpace = max(0, Double(info.usedSpace) - Double(info.backupSpace))
                        if nonBackupSpace > 0.01 * Double(info.totalSpace) {
                            BarMark(
                                x: .value("Category", "Other"),
                                y: .value("Size", nonBackupSpace)
                            )
                            .foregroundStyle(.orange)
                            .annotation(position: .top) {
                                Text(ByteCountFormatter.string(fromByteCount: Int64(nonBackupSpace), countStyle: .file))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let doubleValue = value.as(Double.self) {
                                    Text(ByteCountFormatter.string(fromByteCount: Int64(doubleValue), countStyle: .file))
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                        }
                    }
                    .chartYScale(domain: 0...(Double(info.totalSpace) * 1.05))
                    .frame(height: 200)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    
                    // Legend and stats in a more compact format
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Storage Breakdown")
                            .font(.headline)
                            .padding(.bottom, 2)
                        
                        // Two columns layout for space information
                        HStack(alignment: .top, spacing: 20) {
                            // Left column
                            VStack(alignment: .leading, spacing: 8) {
                                // Backup space
                                HStack(spacing: 8) {
                                    Rectangle()
                                        .fill(.green)
                                        .frame(width: 12, height: 12)
                                        .cornerRadius(2)
                                    
                                    Text("Backups:")
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                    
                                    Text(info.formattedBackupSpace)
                                        .bold()
                                        .font(.subheadline)
                                }
                                
                                // Free space
                                HStack(spacing: 8) {
                                    Rectangle()
                                        .fill(.blue.opacity(0.6))
                                        .frame(width: 12, height: 12)
                                        .cornerRadius(2)
                                    
                                    Text("Free:")
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                    
                                    Text(info.formattedAvailableSpace)
                                        .bold()
                                        .font(.subheadline)
                                }
                            }
                            
                            // Right column
                            VStack(alignment: .leading, spacing: 8) {
                                // Non-backup space
                                HStack(spacing: 8) {
                                    Rectangle()
                                        .fill(.orange)
                                        .frame(width: 12, height: 12)
                                        .cornerRadius(2)
                                    
                                    Text("Other:")
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                    
                                    let nonBackupSpace = max(0, info.usedSpace - info.backupSpace)
                                    Text("\(ByteCountFormatter.string(fromByteCount: nonBackupSpace, countStyle: .file))")
                                        .bold()
                                        .font(.subheadline)
                                }
                                
                                // Total space
                                HStack(spacing: 8) {
                                    Rectangle()
                                        .fill(.gray.opacity(0.5))
                                        .frame(width: 12, height: 12)
                                        .cornerRadius(2)
                                    
                                    Text("Total:")
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                    
                                    Text(info.formattedTotalSpace)
                                        .bold()
                                        .font(.subheadline)
                                }
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        // Usage percentage
                        HStack(spacing: 8) {
                            Text("Disk Usage:")
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(info.usagePercentage))%")
                                .bold()
                                .foregroundColor(info.usagePercentage > 90 ? .red : .primary)
                            
                            Spacer()
                            
                            // Add a refresh button
                            Button(action: loadData) {
                                Label("Refresh", systemImage: "arrow.clockwise")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .background(Color(.windowBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom, 16)
            } else {
                Text("No disk usage information available")
                    .foregroundColor(.secondary)
                    .padding()
                
                Button("Refresh") {
                    loadData()
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try timeMachineService.getDiskUsage()
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
} 