import SwiftUI
import TMBM

struct BackupListView: View {
    @State private var backups: [BackupItem] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @State private var showingDeleteConfirmation: Bool = false
    @State private var selectedBackup: BackupItem? = nil
    
    private let timeMachineService = TimeMachineService()
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading backups...")
            } else if let error = errorMessage {
                VStack {
                    Text("Error loading backups")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(error)
                        .foregroundColor(.secondary)
                    Button("Retry") {
                        loadBackups()
                    }
                    .padding()
                }
            } else if backups.isEmpty {
                Text("No backups found")
                    .font(.headline)
            } else {
                List {
                    ForEach(backups) { backup in
                        BackupItemRow(backup: backup)
                            .contextMenu {
                                Button(action: {
                                    selectedBackup = backup
                                    showingDeleteConfirmation = true
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .alert(isPresented: $showingDeleteConfirmation) {
                    Alert(
                        title: Text("Delete Backup"),
                        message: Text("Are you sure you want to delete this backup? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            if let backup = selectedBackup {
                                deleteBackup(backup)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .navigationTitle("Backups")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    loadBackups()
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            loadBackups()
        }
    }
    
    private func loadBackups() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let loadedBackups = try await withCheckedThrowingContinuation { continuation in
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            let backups = try self.timeMachineService.listBackups()
                            continuation.resume(returning: backups)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                }
                
                await MainActor.run {
                    self.backups = loadedBackups.sorted { $0.date > $1.date }
                    self.isLoading = false
                }
            } catch let error as TimeMachineServiceError {
                await MainActor.run {
                    switch error {
                    case .permissionDenied:
                        self.errorMessage = "Permission denied. Please grant access to Time Machine data in System Settings."
                    case .noBackupsFound:
                        self.errorMessage = "No Time Machine backups found. Make sure Time Machine is configured and has completed at least one backup."
                    case .commandExecutionFailed:
                        self.errorMessage = "Failed to read backup data. Please ensure Time Machine is properly configured."
                    case .fullDiskAccessRequired:
                        self.errorMessage = """
                            Full Disk Access Required

                            To view Time Machine backups, this app needs Full Disk Access permission.

                            1. Open System Settings
                            2. Go to Privacy & Security > Full Disk Access
                            3. Click the + button
                            4. Navigate to Applications
                            5. Select TMBMApp
                            6. Click Open
                            7. Enable the toggle next to TMBMApp

                            After granting access, click Retry below.
                            """
                    default:
                        self.errorMessage = error.description
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func deleteBackup(_ backup: BackupItem) {
        Task {
            do {
                try await withCheckedThrowingContinuation { continuation in
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            try self.timeMachineService.deleteBackup(path: backup.path)
                            continuation.resume()
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                }
                
                await MainActor.run {
                    // Remove the backup from the list
                    if let index = backups.firstIndex(where: { $0.id == backup.id }) {
                        backups.remove(at: index)
                    }
                }
            } catch let error as TimeMachineServiceError {
                await MainActor.run {
                    switch error {
                    case .permissionDenied:
                        self.errorMessage = "Permission denied. Please grant access to delete Time Machine backups."
                    case .backupDeletionFailed:
                        self.errorMessage = "Failed to delete the backup. Please ensure you have the necessary permissions."
                    default:
                        self.errorMessage = error.description
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "An unexpected error occurred while deleting the backup: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct BackupItemRow: View {
    let backup: BackupItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(backup.name)
                .font(.headline)
            HStack {
                Text(backup.formattedDate)
                Spacer()
                Text(backup.formattedSize)
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
} 