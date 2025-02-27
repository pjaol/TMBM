import SwiftUI

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
                VStack {
                    Text("Error loading disk usage")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(error)
                        .foregroundColor(.secondary)
                    Button("Retry") {
                        loadDiskUsage()
                    }
                    .padding()
                }
            } else if let info = storageInfo {
                VStack(spacing: 20) {
                    Text("Time Machine Backup Disk")
                        .font(.headline)
                    
                    HStack {
                        Text("Total Space:")
                        Spacer()
                        Text(info.formattedTotalSpace)
                            .bold()
                    }
                    
                    HStack {
                        Text("Used Space:")
                        Spacer()
                        Text(info.formattedUsedSpace)
                            .bold()
                    }
                    
                    HStack {
                        Text("Available Space:")
                        Spacer()
                        Text(info.formattedAvailableSpace)
                            .bold()
                    }
                    
                    // Usage bar
                    VStack(alignment: .leading) {
                        Text("Disk Usage: \(Int(info.usagePercentage))%")
                            .font(.subheadline)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: geometry.size.width, height: 20)
                                    .opacity(0.3)
                                    .foregroundColor(.gray)
                                
                                Rectangle()
                                    .frame(width: min(CGFloat(info.usagePercentage) / 100.0 * geometry.size.width, geometry.size.width), height: 20)
                                    .foregroundColor(usageColor(percentage: info.usagePercentage))
                            }
                            .cornerRadius(10)
                        }
                        .frame(height: 20)
                    }
                    
                    if info.usagePercentage > 80 {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Disk space is running low. Consider deleting old backups.")
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
            } else {
                Text("No disk usage information available")
                    .font(.headline)
            }
        }
        .navigationTitle("Disk Usage")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    loadDiskUsage()
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            loadDiskUsage()
        }
    }
    
    private func loadDiskUsage() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let info = try timeMachineService.getDiskUsage()
                DispatchQueue.main.async {
                    self.storageInfo = info
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
    
    private func usageColor(percentage: Double) -> Color {
        switch percentage {
        case 0..<50:
            return .green
        case 50..<80:
            return .yellow
        default:
            return .red
        }
    }
} 