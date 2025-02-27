import SwiftUI
import AppKit
import TMBM

@main
@available(macOS 13.0, *)
struct TMBMApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var menuBarViewModel = MenuBarViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Window") {
                    openNewWindow()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        
        MenuBarExtra {
            MenuBarView()
        } label: {
            Image(systemName: menuBarViewModel.statusImage)
            Text("TMBM")
        }
        .menuBarExtraStyle(.window)
    }
}

func openNewWindow() {
    NSApp.setActivationPolicy(.regular)
    
    let contentView = ContentView()
    let controller = NSHostingController(rootView: contentView)
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
        styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
        backing: .buffered,
        defer: false
    )
    window.title = "Time Machine Backup Manager"
    window.contentViewController = controller
    window.center()
    window.makeKeyAndOrderFront(nil)
    
    // Set window delegate to handle closing
    if let appDelegate = NSApp.delegate as? AppDelegate {
        window.delegate = appDelegate
    }
    
    NSApp.activate(ignoringOtherApps: true)
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Start as an accessory app (menu bar only)
        NSApp.setActivationPolicy(.accessory)
        
        // Store reference to the main window
        if let window = NSApp.windows.first {
            mainWindow = window
            window.setFrameAutosaveName("Main Window")
            
            // Handle window close
            window.delegate = self
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't quit when the last window is closed
        NSApp.setActivationPolicy(.accessory)
        return false
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        // Switch back to accessory mode when window is closed
        NSApp.setActivationPolicy(.accessory)
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: BackupListView()) {
                    Label("Backups", systemImage: "clock.arrow.circlepath")
                }
                
                NavigationLink(destination: DiskUsageView()) {
                    Label("Disk Usage", systemImage: "externaldrive.fill")
                }
                
                NavigationLink(destination: SchedulingView()) {
                    Label("Scheduling", systemImage: "calendar")
                }
                
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200)
            
            Text("Select an option from the sidebar")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Time Machine Backup Manager")
        .frame(minWidth: 800, minHeight: 600)
    }
}
