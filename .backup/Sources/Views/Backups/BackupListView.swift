import SwiftUI

struct BackupListView: View {
    @StateObject private var viewModel = BackupListViewModel()
    @State private var selectedBackup: BackupItem?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Time Machine Backups")
                    .font(.headline)
                Spacer()
                Button(action: {
                    Task {
                        await viewModel.loadBackups()
                    }
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
            }
            .padding([.horizontal, .top])
            
            // Backup list
            if viewModel.isLoading {
                ProgressView("Loading backups...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Error loading backups")
                        .font(.headline)
                        .padding(.top, 4)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Try Again") {
                        Task {
                            await viewModel.loadBackups()
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.backups.isEmpty {
                VStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No backups found")
                        .font(.headline)
                        .padding(.top, 4)
                    Text("Time Machine hasn't created any backups yet, or the backup disk is not available.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.backups, selection: $selectedBackup) { backup in
                    BackupItemRow(backup: backup)
                        .contextMenu {
                            Button(action: {
                                selectedBackup = backup
                                showDeleteConfirmation = true
                            }) {
                                Label("Delete Backup", systemImage: "trash")
                            }
                        }
                }
                .listStyle(.inset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Delete Backup", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                showDeleteConfirmation = false
            }
            Button("Delete", role: .destructive) {
                if let backup = selectedBackup {
                    Task {
                        await viewModel.deleteBackup(backup)
                    }
                }
                showDeleteConfirmation = false
            }
        } message: {
            if let backup = selectedBackup {
                Text("Are you sure you want to delete the backup from \(backup.formattedDate)? This action cannot be undone.")
            } else {
                Text("Are you sure you want to delete this backup? This action cannot be undone.")
            }
        }
        .onAppear {
            Task {
                await viewModel.loadBackups()
            }
        }
    }
}

struct BackupItemRow: View {
    let backup: BackupItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(backup.formattedDate)
                    .font(.headline)
                
                HStack {
                    Image(systemName: backup.isComplete ? "checkmark.circle.fill" : "clock.arrow.circlepath")
                        .foregroundColor(backup.isComplete ? .green : .orange)
                    
                    Text(backup.isComplete ? "Complete" : "In Progress")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(backup.formattedSize)
                    .font(.headline)
                
                Text(backup.path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
        .padding(.vertical, 4)
    }
}

// Placeholder ViewModel
class BackupListViewModel: ObservableObject {
    @Published var backups: [BackupItem] = []
    @Published var isLoading = false
    @Published var error: Error? = nil
    
    private let timeMachineService = TimeMachineService()
    
    func loadBackups() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            let loadedBackups = try await timeMachineService.listBackups()
            
            await MainActor.run {
                self.backups = loadedBackups
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    func deleteBackup(_ backup: BackupItem) async {
        do {
            try await timeMachineService.deleteBackup(backup.path)
            await loadBackups()
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
}

#Preview {
    BackupListView()
} 