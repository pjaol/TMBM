import SwiftUI

// This file serves as the entry point for the application
// The @main attribute is removed from TMBMApp.swift and we manually call the main app here
import AppKit

// Import ContentView from TMBMApp.swift
// Note: In a real app, you would typically have ContentView in its own file

// Create a strong reference to the app delegate to prevent it from being deallocated
let appDelegate = AppDelegate()
NSApplication.shared.delegate = appDelegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)

// App Delegate to handle application lifecycle
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the SwiftUI view that provides the window contents
        let contentView = ContentView()
        
        // Create the window and set the content view
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window?.center()
        window?.setFrameAutosaveName("Main Window")
        window?.contentView = NSHostingView(rootView: contentView)
        window?.makeKeyAndOrderFront(nil)
        
        // Setup menu bar extra
        setupMenuBarExtra()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up resources if needed
    }
    
    private func setupMenuBarExtra() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "clock.arrow.circlepath", accessibilityDescription: "TMBM")
            button.action = #selector(toggleMenuBarPopover(_:))
        }
    }
    
    @objc private func toggleMenuBarPopover(_ sender: AnyObject?) {
        // This would normally show a popover with MenuBarView
        // For now, just activate the main window
        NSApp.activate(ignoringOtherApps: true)
    }
} 