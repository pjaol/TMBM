import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var viewModel: MenuBarViewModel
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2)
                Text("Time Machine Backup Manager")
                    .font(.headline)
                Spacer()
            }
            .padding(.bottom, 4)
            
            Divider()
            
            // Status Section
            VStack(alignment: .leading, spacing: 8) {
                Label {
                    Text("Last Backup: Not available")
                } icon: {
                    Image(systemName: "clock")
                }
                
                Label {
                    Text("Next Backup: Not scheduled")
                } icon: {
                    Image(systemName: "calendar")
                }
                
                Label {
                    Text("Status: Idle")
                } icon: {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 10))
                }
            }
            
            Divider()
            
            // Storage Section
            VStack(alignment: .leading, spacing: 8) {
                Label("Storage", systemImage: "externaldrive")
                    .font(.headline)
                
                // Placeholder progress bar
                VStack(alignment: .leading, spacing: 4) {
                    ProgressView(value: 0.3)
                        .progressViewStyle(.linear)
                        .frame(height: 8)
                    
                    HStack {
                        Text("30% used")
                            .font(.caption)
                        Spacer()
                        Text("300 GB free of 1 TB")
                            .font(.caption)
                    }
                }
                .padding(.leading, 24)
            }
            
            Divider()
            
            // Actions Section
            VStack(alignment: .leading, spacing: 8) {
                Button(action: {
                    // Will be implemented later
                }) {
                    Label("Start Backup Now", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    // Will be implemented later
                }) {
                    Label("Pause Backups", systemImage: "pause")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    NSApp.activate(ignoringOtherApps: true)
                    NSApp.windows.first?.makeKeyAndOrderFront(nil)
                }) {
                    Label("Open Backup Manager", systemImage: "macwindow")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            // Footer
            HStack {
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(width: 300)
    }
} 