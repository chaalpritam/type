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
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            TypeStyleAppView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Toggle Dark Mode") {
                    isDarkMode.toggle()
                }
                .keyboardShortcut("d", modifiers: [.command, .shift])
            }
            
            CommandGroup(replacing: .newItem) {
                Button("New Document") {
                    NotificationCenter.default.post(name: .newDocument, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("New from Template...") {
                    NotificationCenter.default.post(name: .showTemplates, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Open Document...") {
                    NotificationCenter.default.post(name: .openDocument, object: nil)
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
}
