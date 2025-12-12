//
//  typeApp.swift
//  type
//
//  Created by Chaal Pritam on 15/04/25.
//

import SwiftUI
import AppKit


@main
struct typeApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // App delegate for handling app-level events
    @NSApplicationDelegateAdaptor(TypeAppDelegate.self) var appDelegate
    
    var body: some SwiftUI.Scene {
        // Main document window group - supports multiple windows and tabs
        WindowGroup(id: "document") {
            DocumentWindowView(windowId: UUID(), showWelcome: true)
                .frame(minWidth: 1000, minHeight: 700)
                .handlesExternalEvents(preferring: Set(arrayLiteral: "document"), allowing: Set(arrayLiteral: "*"))
                .onAppear {
                    // Enable automatic window tabbing
                    NSWindow.allowsAutomaticWindowTabbing = true
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .handlesExternalEvents(matching: Set(arrayLiteral: "document"))
        .commands {
            // File Menu
            CommandGroup(replacing: .newItem) {
                Button("Open Document...") {
                    openDocument()
                }
                .keyboardShortcut("o", modifiers: .command)
            }
            
            CommandGroup(replacing: .saveItem) {
                Button("Save") {
                    NotificationCenter.default.post(name: .saveDocument, object: nil)
                }
                .keyboardShortcut("s", modifiers: .command)
                
                Button("Save As...") {
                    NotificationCenter.default.post(name: .saveDocumentAs, object: nil)
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Close Tab") {
                    closeCurrentTab()
                }
                .keyboardShortcut("w", modifiers: .command)
            }
            
            CommandGroup(after: .textEditing) {
                Button("Find & Replace") {
                    NotificationCenter.default.post(name: .toggleFindReplace, object: nil)
                }
                .keyboardShortcut("f", modifiers: .command)
                
                Divider()
                
                Button("Toggle Focus Mode") {
                    NotificationCenter.default.post(name: .toggleFocusMode, object: nil)
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])
            }
            
            
            CommandGroup(after: .windowArrangement) {
                Divider()
                
                Button("Toggle Sidebar") {
                    NotificationCenter.default.post(name: .toggleSidebar, object: nil)
                }
                .keyboardShortcut("s", modifiers: [.control, .command])
                
                Button("Toggle Preview") {
                    NotificationCenter.default.post(name: .togglePreview, object: nil)
                }
                .keyboardShortcut("p", modifiers: [.command, .shift])
                
                Button("Toggle Outline") {
                    NotificationCenter.default.post(name: .toggleOutline, object: nil)
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
                
                Divider()
                
                // Show list of open windows
                if !WindowManager.shared.openWindows.isEmpty {
                    ForEach(WindowManager.shared.openWindows) { windowInfo in
                        Button(windowInfo.title) {
                            focusWindow(windowInfo.id)
                        }
                    }
                }
            }
            
            // Settings Menu
            CommandGroup(replacing: .appSettings) {
                Button("Toggle Dark Mode") {
                    isDarkMode.toggle()
                }
                .keyboardShortcut("d", modifiers: [.command, .shift])
            }
            
            CommandGroup(replacing: .help) {
                Button("Welcome to Type") {
                    NotificationCenter.default.post(name: .showWelcome, object: nil)
                }
                
                Divider()
                
                Button("Templates...") {
                    NotificationCenter.default.post(name: .showTemplates, object: nil)
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
                
                Divider()
                
                Menu("Tutorials") {
                    Button("Getting Started") {
                        NotificationCenter.default.post(name: .showWelcome, object: nil)
                    }
                    
                    Divider()
                    
                    Menu("Fountain Syntax") {
                        Button("Scene Headings") {}
                        Button("Characters & Dialogue") {}
                        Button("Action Lines") {}
                        Button("Transitions") {}
                    }
                    
                    Menu("Advanced Features") {
                        Button("Character Database") {}
                        Button("Outline Mode") {}
                        Button("Live Preview") {}
                        Button("Keyboard Shortcuts") {}
                    }
                }
                
                Divider()
                
                Button("Fountain Syntax Reference") {
                    if let url = URL(string: "https://fountain.io/syntax") {
                        NSWorkspace.shared.open(url)
                    }
                }
                
                Button("Type Documentation") {
                    // Open local documentation or online docs
                }
            }
        }
    }
    
    // MARK: - Helper Functions

    /// Open a document in a tab (or new window if none exists)
    private func openDocument() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.message = "Choose a screenplay to open"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                NotificationCenter.default.post(
                    name: .loadDocumentInActiveWindow,
                    object: nil,
                    userInfo: ["url": url]
                )
            }
        }
    }
    
    /// Focus a specific window by ID
    private func focusWindow(_ windowId: UUID) {
        if let window = NSApp.windows.first(where: { 
            $0.identifier?.rawValue == windowId.uuidString 
        }) {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    /// Close the current tab/window
    private func closeCurrentTab() {
        guard let keyWindow = NSApp.keyWindow else { return }
        
        // Simply use performClose which handles tab switching automatically
        keyWindow.performClose(nil)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let openDocument = Notification.Name("openDocument")
    static let saveDocument = Notification.Name("saveDocument")
    static let saveDocumentAs = Notification.Name("saveDocumentAs")
    static let toggleFindReplace = Notification.Name("toggleFindReplace")
    static let toggleFocusMode = Notification.Name("toggleFocusMode")
    static let toggleSidebar = Notification.Name("toggleSidebar")
    static let togglePreview = Notification.Name("togglePreview")
    static let toggleOutline = Notification.Name("toggleOutline")
    static let showWelcome = Notification.Name("showWelcome")
    static let showTemplates = Notification.Name("showTemplates")
    static let showTutorials = Notification.Name("showTutorials")
    static let loadDocumentInActiveWindow = Notification.Name("loadDocumentInActiveWindow")
}

// MARK: - App Delegate
/// App delegate for handling application-level lifecycle events
/// Inspired by Beat's BeatAppDelegate approach
class TypeAppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Application Lifecycle
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        Logger.app.info("Application did finish launching")
        
        // Setup document open/close listeners (like Beat)
        setupDocumentListeners()
        
        // Enable automatic window tabbing
        NSWindow.allowsAutomaticWindowTabbing = true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        Logger.app.info("Application will terminate")
        
        // Cleanup is handled by individual windows/coordinators
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't terminate - show welcome screen instead (like Beat)
        Logger.app.info("Last window closed, but keeping app running")
        
        // Show welcome screen when all windows are closed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if WindowManager.shared.windowCount == 0 {
                NotificationCenter.default.post(name: .showWelcome, object: nil)
            }
        }
        
        return false
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // No visible windows - show welcome or create new document
            Logger.app.info("App reopened with no visible windows")
            NotificationCenter.default.post(name: .showWelcome, object: nil)
        }
        return true
    }
    
    // MARK: - Document Handling
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        Logger.app.info("Open file requested: \(filename)")
        
        let url = URL(fileURLWithPath: filename)
        openDocumentFile(url: url)
        return true
    }
    
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        Logger.app.info("Open files requested: \(filenames.count) files")
        
        for filename in filenames {
            let url = URL(fileURLWithPath: filename)
            openDocumentFile(url: url)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupDocumentListeners() {
        // Listen for document open events - hide welcome
        NotificationCenter.default.addObserver(
            forName: .documentDidOpen,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleDocumentOpened()
        }
        
        // Listen for all documents closed - show welcome
        NotificationCenter.default.addObserver(
            forName: .allDocumentsClosed,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAllDocumentsClosed()
        }
    }
    
    private func handleDocumentOpened() {
        Logger.app.info("Document opened - hiding welcome screen")
        // Welcome screen will be hidden by WindowManager
    }
    
    private func handleAllDocumentsClosed() {
        Logger.app.info("All documents closed - showing welcome screen")
        NotificationCenter.default.post(name: .showWelcome, object: nil)
    }
    
    private func openDocumentFile(url: URL) {
        // Check if there's a current window to use as tab
        NotificationCenter.default.post(
            name: .loadDocumentInActiveWindow,
            object: nil,
            userInfo: ["url": url]
        )
    }
}
