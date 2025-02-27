import SwiftUI

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
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let loadedBackups = try timeMachineService.listBackups()
                DispatchQueue.main.async {
                    self.backups = loadedBackups
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
    
    private func deleteBackup(_ backup: BackupItem) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try timeMachineService.deleteBackup(path: backup.path)
                DispatchQueue.main.async {
                    // Remove the backup from the list
                    if let index = backups.firstIndex(where: { $0.id == backup.id }) {
                        backups.remove(at: index)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to delete backup: \(error.localizedDescription)"
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