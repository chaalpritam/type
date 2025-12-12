import Foundation
import SwiftUI
import UniformTypeIdentifiers

@MainActor
class FileManager: ObservableObject {
    @Published var currentDocument: ScreenplayDocument?
    @Published var isDocumentModified = false
    @Published var autoSaveEnabled = true
    @Published var recentFiles: [URL] = []
    
    private let autoSaveInterval: TimeInterval = 30.0 // 30 seconds
    private var autoSaveTimer: Timer?
    private let maxRecentFiles = 10
    
    init() {
        Logger.file.info("FileManager init")
        loadRecentFiles()
        startAutoSaveTimer()
    }
    
    deinit {
        // Removed stopAutoSaveTimer() to avoid main actor isolation violation
    }
    
    // MARK: - Document Management
    
    func loadDocument(from url: URL) async throws {
        Logger.file.info("Loading document from URL: \(url.path)")
        let content = try String(contentsOf: url, encoding: .utf8)
        currentDocument = ScreenplayDocument(content: content, url: url)
        isDocumentModified = false
        addToRecentFiles(url)
    }
    
    func saveDocument() async throws {
        guard currentDocument != nil else {
            throw FileError.noDocument
        }
        
        if let url = currentDocument?.url {
            try await saveDocument(to: url)
        } else {
            throw FileError.noSaveLocation
        }
    }
    
    func saveDocumentAs() async throws -> URL? {
        guard currentDocument != nil else {
            throw FileError.noDocument
        }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.plainText]
        panel.nameFieldStringValue = "Untitled.fountain"
        panel.title = "Save Screenplay"
        panel.message = "Choose a location to save your screenplay"
        
        let response: NSApplication.ModalResponse
        if let window = NSApp.keyWindow ?? NSApp.mainWindow {
            response = await panel.beginSheetModal(for: window)
        } else {
            // Fallback when there is no active window (e.g. during app shutdown)
            response = panel.runModal()
        }
        
        if response == .OK, let url = panel.url {
            try await saveDocument(to: url)
            return url
        }
        
        return nil
    }
    
    private func saveDocument(to url: URL) async throws {
        guard let document = currentDocument else {
            throw FileError.noDocument
        }
        
        try document.content.write(to: url, atomically: true, encoding: .utf8)
        currentDocument?.url = url
        isDocumentModified = false
        addToRecentFiles(url)
    }
    
    func openDocument() async throws -> URL? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.plainText]
        panel.allowsMultipleSelection = false
        panel.title = "Open Screenplay"
        panel.message = "Choose a screenplay file to open"
        
        let response: NSApplication.ModalResponse
        if let window = NSApp.keyWindow ?? NSApp.mainWindow {
            response = await panel.beginSheetModal(for: window)
        } else {
            // Fallback when there is no active window (e.g. during app shutdown)
            response = panel.runModal()
        }
        
        if response == .OK, let url = panel.url {
            try await loadDocument(from: url)
            return url
        }
        
        return nil
    }
    
    // MARK: - Auto Save
    
    private func startAutoSaveTimer() {
        guard autoSaveEnabled else { return }
        
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: autoSaveInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.performAutoSave()
            }
        }
    }
    
    func stopAutoSaveTimer() {
        Logger.file.info("Stopping auto-save timer")
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }
    
    private func performAutoSave() async {
        guard autoSaveEnabled,
              let document = currentDocument,
              let url = document.url,
              isDocumentModified else { return }
        
        do {
            try await saveDocument(to: url)
            print("Auto-saved document to \(url.lastPathComponent)")
        } catch {
            print("Auto-save failed: \(error.localizedDescription)")
        }
    }
    
    func toggleAutoSave() {
        autoSaveEnabled.toggle()
        if autoSaveEnabled {
            startAutoSaveTimer()
        } else {
            stopAutoSaveTimer()
        }
    }
    
    // MARK: - Export
    
    func exportToPDF() async throws -> URL? {
        guard let document = currentDocument else {
            throw FileError.noDocument
        }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.pdf]
        panel.nameFieldStringValue = "Screenplay.pdf"
        panel.title = "Export to PDF"
        panel.message = "Choose a location to save the PDF"
        
        let response: NSApplication.ModalResponse
        if let window = NSApp.keyWindow ?? NSApp.mainWindow {
            response = await panel.beginSheetModal(for: window)
        } else {
            // Fallback when there is no active window (e.g. during app shutdown)
            response = panel.runModal()
        }
        
        if response == .OK, let url = panel.url {
            let pdfData = try await generatePDF(from: document.content)
            try pdfData.write(to: url)
            return url
        }
        
        return nil
    }
    
    func exportToFinalDraft() async throws -> URL? {
        guard let document = currentDocument else {
            throw FileError.noDocument
        }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "fdx") ?? UTType.xml]
        panel.nameFieldStringValue = "Screenplay.fdx"
        panel.title = "Export to Final Draft"
        panel.message = "Choose a location to save the Final Draft file"
        
        let response: NSApplication.ModalResponse
        if let window = NSApp.keyWindow ?? NSApp.mainWindow {
            response = await panel.beginSheetModal(for: window)
        } else {
            // Fallback when there is no active window (e.g. during app shutdown)
            response = panel.runModal()
        }
        
        if response == .OK, let url = panel.url {
            let fdxData = try await generateFinalDraftXML(from: document.content)
            try fdxData.write(to: url)
            return url
        }
        
        return nil
    }
    
    private func generatePDF(from content: String) async throws -> Data {
        // This is a simplified PDF generation
        // In a real app, you'd want to use a proper PDF library
        let attributedString = NSAttributedString(string: content)
        let pdfData = try attributedString.data(from: NSRange(location: 0, length: attributedString.length),
                                               documentAttributes: [.documentType: NSAttributedString.DocumentType.plain])
        return pdfData
    }
    
    private func generateFinalDraftXML(from content: String) async throws -> Data {
        // Simplified Final Draft XML generation
        // In a real app, you'd want to implement proper FDX format
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <FinalDraft DocumentType="Screenplay" Template="Screenplay" Version="3">
            <Content>
                <Text>\(content)</Text>
            </Content>
        </FinalDraft>
        """
        return xmlString.data(using: .utf8) ?? Data()
    }
    
    // MARK: - Recent Files
    
    private func addToRecentFiles(_ url: URL) {
        var files = recentFiles
        files.removeAll { $0 == url }
        files.insert(url, at: 0)
        
        if files.count > maxRecentFiles {
            files = Array(files.prefix(maxRecentFiles))
        }
        
        recentFiles = files
        saveRecentFiles()
    }
    
    private func loadRecentFiles() {
        if let data = UserDefaults.standard.data(forKey: "RecentFiles"),
           let urls = try? JSONDecoder().decode([URL].self, from: data) {
            recentFiles = urls.filter { Foundation.FileManager.default.fileExists(atPath: $0.path) }
        }
    }
    
    private func saveRecentFiles() {
        if let data = try? JSONEncoder().encode(recentFiles) {
            UserDefaults.standard.set(data, forKey: "RecentFiles")
        }
    }
    
    func clearRecentFiles() {
        recentFiles.removeAll()
        UserDefaults.standard.removeObject(forKey: "RecentFiles")
    }
    
    // MARK: - Document State
    
    func markDocumentAsModified() {
        isDocumentModified = true
    }
    
    func hasUnsavedChanges() -> Bool {
        return isDocumentModified
    }
    
    func canSave() -> Bool {
        return currentDocument != nil && currentDocument?.url != nil
    }
}

// MARK: - Errors

enum FileError: LocalizedError {
    case noDocument
    case noSaveLocation
    case saveFailed
    case loadFailed
    case exportFailed
    
    var errorDescription: String? {
        switch self {
        case .noDocument:
            return "No document to save"
        case .noSaveLocation:
            return "No save location specified"
        case .saveFailed:
            return "Failed to save document"
        case .loadFailed:
            return "Failed to load document"
        case .exportFailed:
            return "Failed to export document"
        }
    }
} 