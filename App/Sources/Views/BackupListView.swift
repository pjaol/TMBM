import SwiftUI
import TMBM
import os.log

// Create a logger for the BackupListView
private let viewLogger = OSLog(subsystem: "com.thevgergroup.tmbm", category: "BackupListView")

// Helper functions for logging
private func logDebug(_ message: String) {
    os_log("%{public}@", log: viewLogger, type: .debug, message)
}

private func logInfo(_ message: String) {
    os_log("%{public}@", log: viewLogger, type: .info, message)
}

private func logError(_ message: String) {
    os_log("%{public}@", log: viewLogger, type: .error, message)
}

@MainActor
class BackupListViewModel: ObservableObject {
    @Published var backups: [BackupItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var sizeUpdateTasks: [Task<Void, Never>] = []
    
    deinit {
        // Cancel any ongoing tasks when the view model is deallocated
        for task in sizeUpdateTasks {
            task.cancel()
        }
    }
    
    func loadBackups() {
        // Cancel any existing size update tasks
        for task in sizeUpdateTasks {
            task.cancel()
        }
        sizeUpdateTasks.removeAll()
        
        isLoading = true
        errorMessage = nil
        
        // Create a task to load backups
        _ = Task {
            do {
                logInfo("Starting to load backups")
                let service = TimeMachineService()
                let loadedBackups = try await service.listBackups()
                
                // Update the UI on the main thread
                await MainActor.run {
                    logInfo("Loaded \(loadedBackups.count) backups")
                    self.backups = loadedBackups
                    self.isLoading = false
                    
                    // Log each backup for debugging
                    for (index, backup) in loadedBackups.enumerated() {
                        logInfo("Backup \(index): id=\(backup.id), name=\(backup.name), size=\(backup.size)")
                    }
                }
                
                // Set up a task to observe size updates
                let sizeUpdateTask = Task {
                    logInfo("Setting up size update observer")
                    
                    // Debug: Check if BackupSizeManager has any values
                    let initialSizes = BackupSizeManager.shared.backupSizes
                    logInfo("Initial BackupSizeManager sizes: \(initialSizes.count) entries")
                    
                    for await sizeDict in BackupSizeManager.shared.$backupSizes.values {
                        logInfo("Received size update dictionary with \(sizeDict.count) entries")
                        
                        // Process each entry in the dictionary
                        for (backupId, size) in sizeDict {
                            logInfo("Processing size update: \(size) bytes for backup \(backupId)")
                            
                            await MainActor.run {
                                // Find the backup with this ID and update its size
                                if let index = self.backups.firstIndex(where: { $0.id == backupId }) {
                                    logInfo("Updating size for backup at index \(index)")
                                    // Since BackupItem is now a class, we can update it directly
                                    self.backups[index].updateSize(size)
                                    logInfo("Updated backup size: \(self.backups[index].size) bytes")
                                } else {
                                    logInfo("Could not find backup with ID \(backupId)")
                                }
                            }
                        }
                    }
                }
                
                // Store the task so we can cancel it later
                sizeUpdateTasks.append(sizeUpdateTask)
                logInfo("Size update task created and stored")
                
            } catch let error as TimeMachineServiceError {
                logError("TimeMachineService error: \(error)")
                
                // Handle specific error cases
                await MainActor.run {
                    self.isLoading = false
                    switch error {
                    case .noBackupsFound:
                        self.errorMessage = "No Time Machine backups found. Please check if Time Machine is configured."
                    case .diskInfoUnavailable:
                        self.errorMessage = "Could not access Time Machine disk information."
                    case .commandExecutionFailed:
                        self.errorMessage = "Failed to execute Time Machine command."
                    default:
                        self.errorMessage = "Time Machine error: \(error.description)"
                    }
                }
            } catch {
                logError("Unexpected error: \(error)")
                
                // Handle general errors
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func deleteBackup(at indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let backup = backups[index]
        
        logInfo("Deleting backup: \(backup.name) at path: \(backup.path)")
        
        Task {
            do {
                let service = TimeMachineService()
                try await service.deleteBackup(path: backup.path)
                
                await MainActor.run {
                    logInfo("Successfully deleted backup, removing from list")
                    self.backups.remove(at: index)
                }
            } catch {
                logError("Failed to delete backup: \(error)")
                
                await MainActor.run {
                    self.errorMessage = "Failed to delete backup: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct BackupListView: View {
    @StateObject private var viewModel = BackupListViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading backups...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text("Error")
                        .font(.title)
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        viewModel.loadBackups()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.backups.isEmpty {
                VStack {
                    Text("No backups found")
                        .font(.title)
                    Text("Make sure Time Machine is configured and has completed at least one backup.")
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Refresh") {
                        viewModel.loadBackups()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.backups) { backup in
                        BackupItemRow(backup: backup)
                    }
                    .onDelete(perform: viewModel.deleteBackup)
                }
            }
        }
        .navigationTitle("Time Machine Backups")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    viewModel.loadBackups()
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            viewModel.loadBackups()
        }
    }
}

struct BackupItemRow: View {
    @ObservedObject var backup: BackupItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(backup.name)
                .font(.headline)
            HStack {
                Text("Date: \(formattedDate)")
                Spacer()
                Text("Size: \(backup.formattedSize)")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: backup.date)
    }
}

struct BackupListView_Previews: PreviewProvider {
    static var previews: some View {
        BackupListView()
    }
} 