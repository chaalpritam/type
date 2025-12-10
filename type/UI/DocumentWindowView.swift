import SwiftUI
import AppKit

// MARK: - Document Window View
/// Wrapper view for each document window with its own coordinator
/// Implements proper lifecycle handling inspired by Beat's Document approach
struct DocumentWindowView: View {
    // MARK: - Properties
    let windowId: UUID
    let documentURL: URL?
    let showWelcome: Bool
    
    // AppCoordinator is owned by this view - use StateObject
    @StateObject private var appCoordinator: AppCoordinator
    
    // Access singletons directly - don't wrap in StateObject
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    /// Flag to track if this window has been set up
    @State private var isWindowSetUp = false
    
    /// Flag to track if cleanup has been performed
    @State private var hasPerformedCleanup = false
    
    // MARK: - Initialization
    init(windowId: UUID, documentURL: URL? = nil, showWelcome: Bool = false) {
        self.windowId = windowId
        self.documentURL = documentURL
        self.showWelcome = showWelcome
        
        // Create a new coordinator for this window
        let coordinator = AppCoordinator()
        _appCoordinator = StateObject(wrappedValue: coordinator)
    }
    
    // MARK: - Body
    var body: some View {
        TypeStyleAppView(appCoordinator: appCoordinator, shouldShowWelcome: showWelcome)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onAppear {
                guard !isWindowSetUp else { return }
                isWindowSetUp = true
                Logger.window.info("Window appeared: \(windowId.uuidString)")
                setupWindow()
            }
            .onReceive(NotificationCenter.default.publisher(for: .loadDocumentInActiveWindow)) { notification in
                if let userInfo = notification.userInfo,
                   let url = userInfo["url"] as? URL {
                    loadDocument(url: url)
                }
            }
    }
    
    // MARK: - Private Methods
    
    private func setupWindow() {
        // Register with window manager (access singleton directly)
        let documentId = appCoordinator.documentService.currentDocument?.id ?? UUID()
        let title = appCoordinator.fileManagementService.currentDocumentName
        WindowManager.shared.registerWindow(id: windowId, documentId: documentId, title: title)
        
        // Find and configure the NSWindow
        DispatchQueue.main.async {
            if let nsWindow = NSApp.windows.first(where: { $0.identifier?.rawValue == windowId.uuidString }) {
                // Set up window delegate for proper close handling
                let delegate = SafeWindowDelegate(
                    windowId: windowId,
                    coordinator: appCoordinator
                )
                // Store delegate to prevent deallocation
                objc_setAssociatedObject(nsWindow, &SafeWindowDelegate.associatedKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                nsWindow.delegate = delegate
            }
        }
        
        // Load document if URL is provided
        if let url = documentURL {
            Task {
                do {
                    try await appCoordinator.documentService.loadDocument(from: url)
                    Logger.document.info("Document loaded: \(url.lastPathComponent)")
                    // Update title after load
                    let title = url.lastPathComponent
                    WindowManager.shared.updateWindowTitle(id: windowId, title: title)
                } catch {
                    Logger.document.logError("Failed to load document", error: error)
                }
            }
        } else {
            // Create new document if no URL
            appCoordinator.documentService.newDocument()
        }
    }
    
    private func loadDocument(url: URL) {
        Task {
            do {
                try await appCoordinator.documentService.loadDocument(from: url)
            } catch {
                Logger.document.logError("Failed to load document", error: error)
            }
        }
    }
}

// MARK: - Safe Window Delegate
/// Window delegate that handles cleanup safely before window closes
/// This is the key to preventing crashes - cleanup happens BEFORE SwiftUI teardown
private class SafeWindowDelegate: NSObject, NSWindowDelegate {
    static var associatedKey: UInt8 = 0
    
    private let windowId: UUID
    private weak var coordinator: AppCoordinator?
    private var hasHandledClose = false
    private let closeLock = NSLock()
    
    init(windowId: UUID, coordinator: AppCoordinator) {
        self.windowId = windowId
        self.coordinator = coordinator
        super.init()
        let id = windowId
        Logger.window.info("SafeWindowDelegate created for: \(id.uuidString)")
    }
    
    deinit {
        let id = self.windowId
        Logger.window.info("SafeWindowDelegate deallocated for: \(id.uuidString)")
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        let id = self.windowId
        Logger.window.info("windowShouldClose for: \(id.uuidString)")
        
        // TODO: Check for unsaved changes here
        // if hasUnsavedChanges { show alert and return false }
        
        return true
    }
    
    func windowWillClose(_ notification: Notification) {
        let id = self.windowId
        
        closeLock.lock()
        guard !hasHandledClose else {
            closeLock.unlock()
            Logger.window.info("windowWillClose already handled for: \(id.uuidString)")
            return
        }
        hasHandledClose = true
        closeLock.unlock()
        
        Logger.window.info("=== windowWillClose cleanup starting for: \(id.uuidString) ===")
        
        // CRITICAL: Cleanup coordinator BEFORE SwiftUI tears down the view
        // This prevents crashes from accessing deallocated objects
        coordinator?.cleanup()
        Logger.window.debug("Coordinator cleanup done")
        
        // Unregister from window manager
        WindowManager.shared.unregisterWindow(id: id)
        Logger.window.debug("Window unregistered from WindowManager")
        
        Logger.window.info("=== windowWillClose cleanup completed for: \(id.uuidString) ===")
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        let id = self.windowId
        WindowManager.shared.setActiveWindow(id: id)
    }
}

// MARK: - Preview
#Preview {
    DocumentWindowView(windowId: UUID())
}
