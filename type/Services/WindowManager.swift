import SwiftUI
import Combine

// MARK: - Window Manager
/// Manages multiple document windows and their state
@MainActor
class WindowManager: ObservableObject {
    // MARK: - Singleton
    static let shared = WindowManager()
    
    // MARK: - Published Properties
    @Published var openWindows: [WindowInfo] = []
    @Published var activeWindowId: UUID?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    private init() {
        setupNotifications()
    }
    
    // MARK: - Public Methods
    
    /// Register a new window
    func registerWindow(id: UUID, documentId: UUID, title: String) {
        let windowInfo = WindowInfo(id: id, documentId: documentId, title: title)
        openWindows.append(windowInfo)
        activeWindowId = id
    }
    
    /// Unregister a window
    func unregisterWindow(id: UUID) {
        openWindows.removeAll { $0.id == id }
        
        // If the active window was closed, set active to the last window
        if activeWindowId == id {
            activeWindowId = openWindows.last?.id
        }
    }
    
    /// Update window title
    func updateWindowTitle(id: UUID, title: String) {
        if let index = openWindows.firstIndex(where: { $0.id == id }) {
            openWindows[index].title = title
            openWindows[index].lastModified = Date()
        }
    }
    
    /// Set active window
    func setActiveWindow(id: UUID) {
        activeWindowId = id
    }
    
    /// Get window info
    func getWindowInfo(id: UUID) -> WindowInfo? {
        return openWindows.first { $0.id == id }
    }
    
    /// Get all window titles
    func getAllWindowTitles() -> [String] {
        return openWindows.map { $0.title }
    }
    
    /// Check if a document is already open
    func isDocumentOpen(documentId: UUID) -> Bool {
        return openWindows.contains { $0.documentId == documentId }
    }
    
    /// Get window for document
    func getWindowForDocument(documentId: UUID) -> WindowInfo? {
        return openWindows.first { $0.documentId == documentId }
    }
    
    // MARK: - Private Methods
    
    private func setupNotifications() {
        // Listen for window focus changes
        NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)
            .sink { [weak self] notification in
                if let window = notification.object as? NSWindow,
                   let windowId = window.identifier?.rawValue,
                   let uuid = UUID(uuidString: windowId) {
                    self?.setActiveWindow(id: uuid)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Window Info
/// Information about an open window
struct WindowInfo: Identifiable, Equatable {
    let id: UUID
    let documentId: UUID
    var title: String
    var lastModified: Date
    
    init(id: UUID, documentId: UUID, title: String) {
        self.id = id
        self.documentId = documentId
        self.title = title
        self.lastModified = Date()
    }
}
