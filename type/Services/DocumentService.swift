import Foundation
import Combine
import SwiftUI

// MARK: - Document Service
/// Centralized service for managing screenplay documents
@MainActor
class DocumentService: ObservableObject {
    // MARK: - Published Properties
    @Published var currentDocument: ScreenplayDocument?
    @Published var isDocumentModified = false
    @Published var autoSaveEnabled = true
    @Published var recentFiles: [URL] = []
    
    // MARK: - Private Properties
    private let autoSaveInterval: TimeInterval = 30.0
    private var autoSaveTimer: Timer?
    private let maxRecentFiles = 10
    private let fileManager = FileManager.default
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Initialization
    init() {
        loadRecentFiles()
        startAutoSaveTimer()
    }
    
    deinit {
        stopAutoSaveTimer()
    }
    
    // MARK: - Document Management
    
    /// Create a new document
    func newDocument() {
        currentDocument = ScreenplayDocument(content: "")
        isDocumentModified = false
    }
    
    /// Load document from URL
    func loadDocument(from url: URL) async throws {
        let content = try String(contentsOf: url, encoding: .utf8)
        currentDocument = ScreenplayDocument(content: content, url: url)
        isDocumentModified = false
        addToRecentFiles(url)
    }
    
    /// Save current document
    func saveDocument() async throws {
        guard let document = currentDocument else {
            throw DocumentError.noDocument
        }
        
        if let url = document.url {
            try await saveDocument(to: url)
        } else {
            throw DocumentError.noSaveLocation
        }
    }
    
    /// Save document to specific URL
    func saveDocumentAs() async throws -> URL? {
        guard currentDocument != nil else {
            throw DocumentError.noDocument
        }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.plainText]
        panel.nameFieldStringValue = "Untitled.fountain"
        panel.title = "Save Screenplay"
        panel.message = "Choose a location to save your screenplay"
        
        let response = await panel.beginSheetModal(for: NSApp.keyWindow!)
        
        if response == .OK, let url = panel.url {
            try await saveDocument(to: url)
            return url
        }
        
        return nil
    }
    
    /// Update document content
    func updateDocumentContent(_ content: String) {
        currentDocument?.content = content
        isDocumentModified = true
    }
    
    /// Mark document as modified
    func markDocumentAsModified() {
        isDocumentModified = true
    }
    
    /// Check if document can be saved
    func canSave() -> Bool {
        return currentDocument != nil
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
    
    private func stopAutoSaveTimer() {
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
    
    // MARK: - Recent Files
    
    private func addToRecentFiles(_ url: URL) {
        var recent = recentFiles
        recent.removeAll { $0 == url }
        recent.insert(url, at: 0)
        
        if recent.count > maxRecentFiles {
            recent = Array(recent.prefix(maxRecentFiles))
        }
        
        recentFiles = recent
        saveRecentFiles()
    }
    
    private func loadRecentFiles() {
        if let urls = userDefaults.array(forKey: "recentFiles") as? [String] {
            recentFiles = urls.compactMap { URL(string: $0) }
        }
    }
    
    private func saveRecentFiles() {
        let urls = recentFiles.map { $0.absoluteString }
        userDefaults.set(urls, forKey: "recentFiles")
    }
    
    // MARK: - Private Methods
    
    private func saveDocument(to url: URL) async throws {
        guard let document = currentDocument else {
            throw DocumentError.noDocument
        }
        
        try document.content.write(to: url, atomically: true, encoding: .utf8)
        currentDocument?.url = url
        isDocumentModified = false
        addToRecentFiles(url)
    }
}

// MARK: - Document Error
enum DocumentError: LocalizedError {
    case noDocument
    case noSaveLocation
    case saveFailed
    case loadFailed
    
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
        }
    }
} 