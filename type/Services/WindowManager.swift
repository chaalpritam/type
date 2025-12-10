import SwiftUI
import Combine

// MARK: - Window Manager
/// Manages multiple document windows and their state
/// Inspired by Beat's approach to showing welcome screen when no documents are open
@MainActor
class WindowManager: ObservableObject {
    // MARK: - Singleton
    static let shared = WindowManager()
    
    // MARK: - Published Properties
    @Published var openWindows: [WindowInfo] = []
    @Published var activeWindowId: UUID?
    @Published private(set) var shouldShowWelcome: Bool = true
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let windowLock = NSLock()
    
    // MARK: - Initialization
    private init() {
        setupNotifications()
        Logger.window.info("WindowManager initialized")
    }
    
    // MARK: - Public Methods
    
    /// Register a new window
    func registerWindow(id: UUID, documentId: UUID, title: String) {
        windowLock.lock()
        defer { windowLock.unlock() }
        
        // Check if already registered
        guard !openWindows.contains(where: { $0.id == id }) else {
            Logger.window.info("Window already registered: \(id.uuidString)")
            return
        }
        
        let windowInfo = WindowInfo(id: id, documentId: documentId, title: title)
        openWindows.append(windowInfo)
        activeWindowId = id
        
        // Hide welcome screen when a document window is opened
        shouldShowWelcome = false
        
        Logger.window.info("Window registered: \(id.uuidString), title: \(title), total: \(self.openWindows.count)")
        
        // Post notification
        NotificationCenter.default.post(name: .documentDidOpen, object: id)
    }
    
    /// Unregister a window
    func unregisterWindow(id: UUID) {
        windowLock.lock()
        defer { windowLock.unlock() }
        
        let previousCount = openWindows.count
        openWindows.removeAll { $0.id == id }
        
        // If the active window was closed, set active to the last window
        if activeWindowId == id {
            activeWindowId = openWindows.last?.id
        }
        
        Logger.window.info("Window unregistered: \(id.uuidString), total: \(self.openWindows.count)")
        
        // Show welcome screen when all documents are closed (like Beat)
        if openWindows.isEmpty && previousCount > 0 {
            shouldShowWelcome = true
            Logger.window.info("All windows closed, showing welcome screen")
            
            // Post notification for welcome screen
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .allDocumentsClosed, object: nil)
                NotificationCenter.default.post(name: .showWelcome, object: nil)
            }
        }
        
        // Post notification
        NotificationCenter.default.post(name: .documentDidClose, object: id)
    }
    
    /// Update window title
    func updateWindowTitle(id: UUID, title: String) {
        windowLock.lock()
        defer { windowLock.unlock() }
        
        if let index = openWindows.firstIndex(where: { $0.id == id }) {
            openWindows[index].title = title
            openWindows[index].lastModified = Date()
            
            // Also update the actual NSWindow title
            updateNSWindowTitle(id: id, title: title)
        }
    }
    
    /// Set active window
    func setActiveWindow(id: UUID) {
        activeWindowId = id
    }
    
    /// Get window info
    func getWindowInfo(id: UUID) -> WindowInfo? {
        windowLock.lock()
        defer { windowLock.unlock() }
        return openWindows.first { $0.id == id }
    }
    
    /// Get all window titles
    func getAllWindowTitles() -> [String] {
        windowLock.lock()
        defer { windowLock.unlock() }
        return openWindows.map { $0.title }
    }
    
    /// Check if a document is already open
    func isDocumentOpen(documentId: UUID) -> Bool {
        windowLock.lock()
        defer { windowLock.unlock() }
        return openWindows.contains { $0.documentId == documentId }
    }
    
    /// Get window for document
    func getWindowForDocument(documentId: UUID) -> WindowInfo? {
        windowLock.lock()
        defer { windowLock.unlock() }
        return openWindows.first { $0.documentId == documentId }
    }
    
    /// Check if there are any open windows
    var hasOpenWindows: Bool {
        windowLock.lock()
        defer { windowLock.unlock() }
        return !openWindows.isEmpty
    }
    
    /// Get the count of open windows
    var windowCount: Int {
        windowLock.lock()
        defer { windowLock.unlock() }
        return openWindows.count
    }
    
    /// Force show welcome screen
    func showWelcomeScreen() {
        shouldShowWelcome = true
        NotificationCenter.default.post(name: .showWelcome, object: nil)
    }
    
    /// Hide welcome screen
    func hideWelcomeScreen() {
        shouldShowWelcome = false
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
    
    private func updateNSWindowTitle(id: UUID, title: String) {
        DispatchQueue.main.async {
            if let window = NSApp.windows.first(where: { 
                $0.identifier?.rawValue == id.uuidString 
            }) {
                window.title = title
            }
        }
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
