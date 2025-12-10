import Foundation
import Combine
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Document Service
/// Centralized service for managing screenplay documents
/// Implements data caching and safe saving inspired by Beat's approach
@MainActor
class DocumentService: ObservableObject {
    // MARK: - Published Properties
    @Published var currentDocument: ScreenplayDocument?
    @Published var isDocumentModified = false
    @Published var autoSaveEnabled = true
    @Published var recentFiles: [URL] = []
    @Published private(set) var isDocumentLoading = false
    
    // MARK: - Private Properties
    private let autoSaveInterval: TimeInterval = 30.0
    private var autoSaveTimer: Timer?
    private let maxRecentFiles = 10
    private let fileManager = Foundation.FileManager.default
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    /// Data cache for safe saving - stores last successful save data
    /// If saving fails, we can fall back to this cached version
    private var dataCache: Data?
    
    /// Content buffer - keeps text until view is initialized
    private var contentBuffer: String?
    
    /// Flag to prevent operations during cleanup
    private var isCleaningUp = false
    
    // MARK: - Initialization
    init() {
        loadRecentFiles()
        startAutoSaveTimer()
    }
    
    deinit {
        Logger.document.info("DocumentService deinit")
    }
    
    // MARK: - Document Management
    
    /// Create a new document
    func newDocument() {
        Logger.document.info("Creating new document")
        currentDocument = ScreenplayDocument(content: "")
        isDocumentModified = false
    }
    
    /// Load document from URL
    func loadDocument(from url: URL) async throws {
        Logger.document.info("Loading document from URL: \(url.path)")
        let content = try String(contentsOf: url, encoding: .utf8)
        currentDocument = ScreenplayDocument(content: content, url: url)
        isDocumentModified = false
        addToRecentFiles(url)
    }
    
    /// Save current document
    func saveDocument() async throws {
        guard let document = currentDocument else {
            Logger.document.logError("Attempted to save with no current document", error: DocumentError.noDocument)
            throw DocumentError.noDocument
        }
        
        if let url = document.url {
            try await saveDocument(to: url)
        } else {
            Logger.document.logError("Attempted to save without a URL", error: DocumentError.noSaveLocation)
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
    
    /// Safe save method with data caching - inspired by Beat's dataOfType approach
    private func saveDocument(to url: URL) async throws {
        guard !isCleaningUp else {
            Logger.document.warning("Attempted to save during cleanup, ignoring")
            return
        }
        
        guard let document = currentDocument else {
            Logger.document.logError("Attempted to save to URL with no current document", error: DocumentError.noDocument)
            throw DocumentError.noDocument
        }
        
        // Try to save with fallback to cached data
        do {
            let dataToSave = document.content.data(using: .utf8)
            
            guard let data = dataToSave else {
                // If we can't get data from current content, try cache
                if let cachedData = dataCache {
                    Logger.document.warning("Using cached data for save")
                    try cachedData.write(to: url, options: .atomic)
                    return
                }
                throw DocumentError.saveFailed
            }
            
            // Write the data
            try data.write(to: url, options: .atomic)
            
            // On successful save, update the cache
            dataCache = data
            currentDocument?.url = url
            isDocumentModified = false
            addToRecentFiles(url)
            
            Logger.document.info("Document saved successfully to: \(url.lastPathComponent)")
            
        } catch {
            Logger.document.logError("Save failed, attempting fallback", error: error)
            
            // Fallback: try to save cached data
            if let cachedData = dataCache {
                do {
                    try cachedData.write(to: url, options: .atomic)
                    Logger.document.warning("Saved using cached data after primary save failed")
                } catch {
                    Logger.document.logError("Fallback save also failed", error: error)
                    throw DocumentError.saveFailed
                }
            } else {
                throw error
            }
        }
    }
    
    // MARK: - Cleanup
    
    /// Comprehensive cleanup method - must be called before deallocation
    func cleanup() {
        guard !isCleaningUp else {
            Logger.document.info("DocumentService cleanup already in progress")
            return
        }
        
        isCleaningUp = true
        Logger.document.info("DocumentService cleanup started")
        
        // 1. Stop auto-save timer
        stopAutoSaveTimer()
        Logger.document.debug("Auto-save timer stopped")
        
        // 2. Cancel all subscriptions
        cancellables.removeAll()
        Logger.document.debug("Subscriptions cancelled")
        
        // 3. Clear the data cache
        dataCache = nil
        contentBuffer = nil
        Logger.document.debug("Caches cleared")
        
        // 4. Clear current document reference
        currentDocument = nil
        Logger.document.debug("Document reference cleared")
        
        // 5. Save recent files before cleanup
        saveRecentFiles()
        Logger.document.debug("Recent files saved")
        
        Logger.document.info("DocumentService cleanup completed")
    }
    
    
    /// Update content and cache it
    func updateDocumentContentWithCache(_ content: String) {
        guard !isCleaningUp else { return }
        
        currentDocument?.content = content
        isDocumentModified = true
        
        // Cache the content data
        if let data = content.data(using: .utf8) {
            dataCache = data
        }
    }
}

// MARK: - Document Error
enum DocumentError: LocalizedError {
    case noDocument
    case noSaveLocation
    case saveFailed
    case loadFailed
    case cleanupInProgress
    
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
        case .cleanupInProgress:
            return "Operation cancelled - cleanup in progress"
        }
    }
} 