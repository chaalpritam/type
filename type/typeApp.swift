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
    @AppStorage("useModernUI") private var useModernUI = true
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            if useModernUI {
                TypeStyleAppView()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            } else {
                ModularAppView()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Toggle Dark Mode") {
                    isDarkMode.toggle()
                }
                .keyboardShortcut("d", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Use Modern UI") {
                    useModernUI = true
                }
                .disabled(useModernUI)
                
                Button("Use Classic UI") {
                    useModernUI = false
                }
                .disabled(!useModernUI)
            }
            
            CommandGroup(replacing: .newItem) {
                Button("New Document") {
                    NotificationCenter.default.post(name: .newDocument, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
                
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
}
