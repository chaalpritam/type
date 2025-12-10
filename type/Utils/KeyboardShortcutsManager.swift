import Foundation
import SwiftUI
import AppKit

@MainActor
class KeyboardShortcutsManager: ObservableObject {
    private var fileManager: FileManager
    private var textEditor: FountainTextEditor?
    
    private var startMonitor: Any?
    
    init(fileManager: FileManager) {
        self.fileManager = fileManager
        setupKeyboardShortcuts()
    }
    
    deinit {
        if let monitor = startMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    func setTextEditor(_ editor: FountainTextEditor) {
        self.textEditor = editor
    }
    
    private func setupKeyboardShortcuts() {
        // File Operations
        startMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            return self?.handleKeyEvent(event) ?? event
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        let modifiers = event.modifierFlags
        
        // Check for Cmd key combinations
        guard modifiers.contains(.command) else {
            return event
        }
        
        switch event.charactersIgnoringModifiers {
        case "n":
            // Cmd+N: New Document
            Task {
                await self.newDocument()
            }
            return nil
            
        case "o":
            // Cmd+O: Open Document
            Task {
                await self.openDocument()
            }
            return nil
            
        case "s":
            // Cmd+S: Save Document
            if modifiers.contains(.shift) {
                // Cmd+Shift+S: Save As
                Task {
                    await self.saveDocumentAs()
                }
            } else {
                // Cmd+S: Save
                Task {
                    await self.saveDocument()
                }
            }
            return nil
            
        case "w":
            // Cmd+W: Close Document (or window)
            Task {
                await self.closeDocument()
            }
            return nil
            
        case "f":
            // Cmd+F: Find
            Task {
                await self.showFindReplace()
            }
            return nil
            
        case "r":
            // Cmd+R: Replace
            Task {
                await self.showFindReplace(replaceMode: true)
            }
            return nil
            
        case "g":
            // Cmd+G: Find Next
            Task {
                await self.findNext()
            }
            return nil
            
        case "z":
            // Cmd+Z: Undo
            if modifiers.contains(.shift) {
                // Cmd+Shift+Z: Redo
                Task {
                    await self.redo()
                }
            } else {
                // Cmd+Z: Undo
                Task {
                    await self.undo()
                }
            }
            return nil
            
        case "a":
            // Cmd+A: Select All
            Task {
                await self.selectAll()
            }
            return nil
            
        case "c":
            // Cmd+C: Copy
            Task {
                await self.copy()
            }
            return nil
            
        case "v":
            // Cmd+V: Paste
            Task {
                await self.paste()
            }
            return nil
            
        case "x":
            // Cmd+X: Cut
            Task {
                await self.cut()
            }
            return nil
            
        case "b":
            // Cmd+B: Bold
            Task {
                await self.toggleBold()
            }
            return nil
            
        case "i":
            // Cmd+I: Italic
            Task {
                await self.toggleItalic()
            }
            return nil
            
        case "1":
            // Cmd+1: Scene Heading
            Task {
                await self.insertSceneHeading()
            }
            return nil
            
        case "2":
            // Cmd+2: Action
            Task {
                await self.insertAction()
            }
            return nil
            
        case "3":
            // Cmd+3: Character
            Task {
                await self.insertCharacter()
            }
            return nil
            
        case "4":
            // Cmd+4: Dialogue
            Task {
                await self.insertDialogue()
            }
            return nil
            
        case "5":
            // Cmd+5: Parenthetical
            Task {
                await self.insertParenthetical()
            }
            return nil
            
        case "6":
            // Cmd+6: Transition
            Task {
                await self.insertTransition()
            }
            return nil
            
        case "7":
            // Cmd+7: Shot
            Task {
                await self.insertShot()
            }
            return nil
            
        case "8":
            // Cmd+8: Centered
            Task {
                await self.insertCentered()
            }
            return nil
            
        case "9":
            // Cmd+9: Note
            Task {
                await self.insertNote()
            }
            return nil
            
        case "0":
            // Cmd+0: Section
            Task {
                await self.insertSection()
            }
            return nil
            
        case "p":
            // Cmd+P: Print/Export
            Task {
                await self.exportDocument()
            }
            return nil
            
        case "m":
            // Cmd+M: Minimize
            NSApp.keyWindow?.miniaturize(nil)
            return nil
            
        case "h":
            // Cmd+H: Hide
            NSApp.hide(nil)
            return nil
            
        case "q":
            // Cmd+Q: Quit
            NSApp.terminate(nil)
            return nil
            
        case "`":
            // Cmd+`: Toggle Preview
            Task {
                await self.togglePreview()
            }
            return nil
            
        case "t":
            // Cmd+T: Theme toggle disabled - app always stays in light mode
            return nil
            
        default:
            return event
        }
    }
    
    // MARK: - File Operations
    
    private func newDocument() async {
        fileManager.newDocument()
    }
    
    private func openDocument() async {
        do {
            _ = try await fileManager.openDocument()
        } catch {
            await showError("Failed to open document", error: error)
        }
    }
    
    private func saveDocument() async {
        do {
            try await fileManager.saveDocument()
        } catch {
            await showError("Failed to save document", error: error)
        }
    }
    
    private func saveDocumentAs() async {
        do {
            _ = try await fileManager.saveDocumentAs()
        } catch {
            await showError("Failed to save document", error: error)
        }
    }
    
    private func closeDocument() async {
        if fileManager.hasUnsavedChanges() {
            let alert = NSAlert()
            alert.messageText = "Save Changes?"
            alert.informativeText = "Do you want to save the changes to this document?"
            alert.addButton(withTitle: "Save")
            alert.addButton(withTitle: "Don't Save")
            alert.addButton(withTitle: "Cancel")
            alert.alertStyle = .warning
            
            let response = await alert.beginSheetModal(for: NSApp.keyWindow!)
            
            switch response {
            case .alertFirstButtonReturn: // Save
                await saveDocument()
            case .alertSecondButtonReturn: // Don't Save
                fileManager.newDocument()
            case .alertThirdButtonReturn: // Cancel
                return
            default:
                break
            }
        } else {
            fileManager.newDocument()
        }
    }
    
    // MARK: - Find and Replace
    
    private func showFindReplace(replaceMode: Bool = false) async {
        // This would trigger the find/replace panel
        // Implementation depends on your UI structure
        print("Show find/replace panel")
    }
    
    private func findNext() async {
        // Implementation for find next
        print("Find next")
    }
    
    // MARK: - Edit Operations
    
    private func undo() async {
        // TODO: Implement undo through the text editor
        print("Undo")
    }
    
    private func redo() async {
        // TODO: Implement redo through the text editor
        print("Redo")
    }
    
    private func selectAll() async {
        // TODO: Implement select all through the text editor
        print("Select All")
    }
    
    private func copy() async {
        // TODO: Implement copy through the text editor
        print("Copy")
    }
    
    private func paste() async {
        // TODO: Implement paste through the text editor
        print("Paste")
    }
    
    private func cut() async {
        // TODO: Implement cut through the text editor
        print("Cut")
    }
    
    // MARK: - Formatting
    
    private func toggleBold() async {
        // Insert **bold** formatting
        insertText("**")
    }
    
    private func toggleItalic() async {
        // Insert _italic_ formatting
        insertText("_")
    }
    
    // MARK: - Fountain Elements
    
    private func insertSceneHeading() async {
        insertText("INT. LOCATION - DAY\n")
    }
    
    private func insertAction() async {
        insertText("Action description goes here.\n")
    }
    
    private func insertCharacter() async {
        insertText("CHARACTER NAME\n")
    }
    
    private func insertDialogue() async {
        insertText("Character dialogue goes here.\n")
    }
    
    private func insertParenthetical() async {
        insertText("(parenthetical)\n")
    }
    
    private func insertTransition() async {
        insertText("FADE OUT.\n")
    }
    
    private func insertShot() async {
        insertText("SHOT - Description\n")
    }
    
    private func insertCentered() async {
        insertText(">Centered text<\n")
    }
    
    private func insertNote() async {
        insertText("[[Note: This is a note]]\n")
    }
    
    private func insertSection() async {
        insertText("# Section\n")
    }
    
    // MARK: - Utility
    
    private func insertText(_ text: String) {
        // TODO: Implement text insertion through the text editor
        // For now, just mark the document as modified
        fileManager.markDocumentAsModified()
        print("Insert text: \(text)")
    }
    
    private func exportDocument() async {
        let alert = NSAlert()
        alert.messageText = "Export Document"
        alert.informativeText = "Choose export format:"
        alert.addButton(withTitle: "PDF")
        alert.addButton(withTitle: "Final Draft")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .informational
        
        let response = await alert.beginSheetModal(for: NSApp.keyWindow!)
        
        switch response {
        case .alertFirstButtonReturn: // PDF
            do {
                _ = try await fileManager.exportToPDF()
            } catch {
                await showError("Failed to export PDF", error: error)
            }
        case .alertSecondButtonReturn: // Final Draft
            do {
                _ = try await fileManager.exportToFinalDraft()
            } catch {
                await showError("Failed to export Final Draft", error: error)
            }
        default:
            break
        }
    }
    
    private func togglePreview() async {
        // Implementation depends on your UI structure
        print("Toggle preview")
    }
    
    // Theme toggle disabled - app always stays in light mode
    // private func toggleTheme() async {
    //     // Implementation depends on your theme system
    //     print("Toggle theme")
    // }
    
    private func showError(_ message: String, error: Error) async {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        
        await alert.beginSheetModal(for: NSApp.keyWindow!)
    }
}

// MARK: - Touch Bar Support

extension KeyboardShortcutsManager {
    func setupTouchBar() {
        // Touch Bar implementation would go here
        // This requires additional setup in the main app
    }
} 