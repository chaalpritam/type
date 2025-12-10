//
//  typeApp.swift
//  type
//
//  Created by Chaal Pritam on 15/04/25.
//

import SwiftUI

@main
struct typeApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @StateObject private var windowManager = WindowManager.shared
    
    var body: some SwiftUI.Scene {
        // Main document window group - supports multiple windows
        WindowGroup(id: "document") {
            DocumentWindowView(windowId: UUID())
                .frame(minWidth: 1000, minHeight: 700)
                .handlesExternalEvents(preferring: Set(arrayLiteral: "document"), allowing: Set(arrayLiteral: "*"))
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .handlesExternalEvents(matching: Set(arrayLiteral: "document"))
        .commands {
            // File Menu
            CommandGroup(replacing: .newItem) {
                Button("New Document") {
                    openNewWindow()
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("New Window") {
                    openNewWindow()
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                
                Button("New from Template...") {
                    NotificationCenter.default.post(name: .showTemplates, object: nil)
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
                
                Divider()
                
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
                if !windowManager.openWindows.isEmpty {
                    ForEach(windowManager.openWindows) { windowInfo in
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
    
    /// Open a new window with a blank document
    private func openNewWindow() {
        // Use NSWorkspace to open a new window
        if let url = URL(string: "type://new") {
            NSWorkspace.shared.open(url)
        }
        
        // Alternative: Create new window programmatically
        DispatchQueue.main.async {
            let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            
            let windowId = UUID()
            newWindow.identifier = NSUserInterfaceItemIdentifier(windowId.uuidString)
            newWindow.contentView = NSHostingView(
                rootView: DocumentWindowView(windowId: windowId)
                    .frame(minWidth: 1000, minHeight: 700)
            )
            newWindow.title = "Untitled"
            newWindow.center()
            newWindow.makeKeyAndOrderFront(nil)
        }
    }
    
    /// Open a document in a new window
    private func openDocument() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.message = "Choose a screenplay to open"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                // Open in new window
                self.openDocumentInNewWindow(url: url)
            }
        }
    }
    
    /// Open a specific document URL in a new window
    private func openDocumentInNewWindow(url: URL) {
        DispatchQueue.main.async {
            let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            
            let windowId = UUID()
            newWindow.identifier = NSUserInterfaceItemIdentifier(windowId.uuidString)
            newWindow.contentView = NSHostingView(
                rootView: DocumentWindowView(windowId: windowId, documentURL: url)
                    .frame(minWidth: 1000, minHeight: 700)
            )
            newWindow.title = url.lastPathComponent
            newWindow.center()
            newWindow.makeKeyAndOrderFront(nil)
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
}

// MARK: - Notification Names
extension Notification.Name {
    static let newDocument = Notification.Name("newDocument")
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
