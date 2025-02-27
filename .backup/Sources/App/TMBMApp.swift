import SwiftUI

@main
struct TMBMApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var menuBarViewModel = MenuBarViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
                .environmentObject(menuBarViewModel)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) { }
            
            CommandMenu("Time Machine") {
                Button("Start Backup") {
                    // Will be implemented later
                }
                .keyboardShortcut("B", modifiers: [.command])
                
                Button("Stop Backup") {
                    // Will be implemented later
                }
                .keyboardShortcut("S", modifiers: [.command])
                
                Divider()
                
                Button("Preferences...") {
                    // Will be implemented later
                }
                .keyboardShortcut(",", modifiers: [.command])
            }
        }
        
        // Menu Bar Extra
        MenuBarExtra("Time Machine Backup Manager", systemImage: "clock.arrow.circlepath") {
            MenuBarView()
                .environmentObject(menuBarViewModel)
        }
        .menuBarExtraStyle(.window)
    }
}

// Placeholder for MenuBarViewModel
class MenuBarViewModel: ObservableObject {
    // Will be implemented later
} 