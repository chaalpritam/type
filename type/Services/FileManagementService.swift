//
//  FileManagementService.swift
//  type
//
//  File management logic migrated from ContentView.swift
//

import SwiftUI
import AppKit

// MARK: - File Management Service
@MainActor
class FileManagementService: ObservableObject {
    @Published var fileManager: FileManager
    @Published var keyboardShortcutsManager: KeyboardShortcutsManager
    
    init() {
        let fileManager = FileManager()
        self.fileManager = fileManager
        self.keyboardShortcutsManager = KeyboardShortcutsManager(fileManager: fileManager)
    }
    
    // MARK: - File Management Functions
    
    func newDocument() {
        if fileManager.hasUnsavedChanges() {
            // This would trigger the unsaved changes alert in the UI
            // The actual implementation would be handled by the coordinator
        } else {
            fileManager.newDocument()
        }
    }
    
    func openDocument() async throws {
        do {
            _ = try await fileManager.openDocument()
        } catch {
            await showError("Failed to open document", error: error)
            throw error
        }
    }
    
    func saveDocument() async throws {
        do {
            try await fileManager.saveDocument()
        } catch {
            await showError("Failed to save document", error: error)
            throw error
        }
    }
    
    func saveDocumentAs() async throws {
        do {
            _ = try await fileManager.saveDocumentAs()
        } catch {
            await showError("Failed to save document", error: error)
            throw error
        }
    }
    
    func exportDocument() async {
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
    
    private func showError(_ message: String, error: Error) async {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        
        await alert.beginSheetModal(for: NSApp.keyWindow!)
    }
    
    // MARK: - Synchronous Wrappers for Async File Actions
    func saveDocumentSync() { Task { try? await saveDocument() } }
    func saveDocumentAsSync() { Task { try? await saveDocumentAs() } }
    func openDocumentSync() { Task { try? await openDocument() } }
    func exportDocumentSync() { Task { await exportDocument() } }
    
    // MARK: - Document State
    var canSave: Bool {
        fileManager.canSave()
    }
    
    var isDocumentModified: Bool {
        fileManager.isDocumentModified
    }
    
    var currentDocumentName: String {
        fileManager.currentDocument?.url?.lastPathComponent ?? "Untitled"
    }
    
    var autoSaveEnabled: Bool {
        fileManager.autoSaveEnabled
    }
    
    var hasUnsavedChanges: Bool {
        fileManager.hasUnsavedChanges()
    }
} 