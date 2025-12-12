import SwiftUI
import AppKit

// MARK: - Document Window View
/// Wrapper view for each document window with its own coordinator
/// Implements proper lifecycle handling inspired by Beat's Document approach
struct DocumentWindowView: View {
    // MARK: - Properties
    let windowId: UUID
    let documentURL: URL?
    
    // AppCoordinator is owned by this view - use StateObject
    @StateObject private var appCoordinator: AppCoordinator
    
    // Access singletons directly - don't wrap in StateObject
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    /// Flag to track if this window has been set up
    @State private var isWindowSetUp = false
    
    /// Flag to track if cleanup has been performed
    @State private var hasPerformedCleanup = false
    
    // MARK: - Initialization
    init(windowId: UUID, documentURL: URL? = nil) {
        self.windowId = windowId
        self.documentURL = documentURL
        
        // Create a new coordinator for this window
        let coordinator = AppCoordinator()
        _appCoordinator = StateObject(wrappedValue: coordinator)
    }
    
    // MARK: - Body
    var body: some View {
        TypeStyleAppView(appCoordinator: appCoordinator)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onAppear {
                guard !isWindowSetUp else { return }
                isWindowSetUp = true
                Logger.window.info("Window appeared: \(windowId.uuidString)")
                setupWindow()
            }
            .onDisappear {
                // Safety net in case window delegate never attached
                performCleanupIfNeeded(reason: "onDisappear")
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
            // SwiftUI WindowGroup windows may not have an identifier; set it if missing
            if let nsWindow = NSApp.windows.first(where: { $0.identifier?.rawValue == windowId.uuidString }) ?? NSApp.keyWindow {
                if nsWindow.identifier == nil {
                    nsWindow.identifier = NSUserInterfaceItemIdentifier(windowId.uuidString)
                }
                // Set up window delegate for proper close handling
                let delegate = SafeWindowDelegate(
                    windowId: windowId,
                    coordinator: appCoordinator,
                    cleanupHandler: {
                        performCleanupIfNeeded(reason: "windowWillClose")
                    }
                )
                // Store delegate to prevent deallocation
                objc_setAssociatedObject(nsWindow, &SafeWindowDelegate.associatedKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                nsWindow.delegate = delegate
            } else {
                // If we still cannot find the window, perform cleanup to avoid leaks
                Logger.window.error("Unable to locate NSWindow for id: \(windowId.uuidString)")
                performCleanupIfNeeded(reason: "missingWindowDuringSetup")
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
    
    /// Shared cleanup to avoid leaking observers/timers even if delegate isn't attached
    private func performCleanupIfNeeded(reason: String) {
        guard !hasPerformedCleanup else {
            Logger.window.info("Cleanup already performed for \(windowId.uuidString) via \(reason)")
            return
        }
        hasPerformedCleanup = true
        
        Logger.window.info("=== cleanup starting for: \(windowId.uuidString) (\(reason)) ===")
        appCoordinator.cleanup()
        WindowManager.shared.unregisterWindow(id: windowId)
        Logger.window.info("=== cleanup completed for: \(windowId.uuidString) (\(reason)) ===")
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
    private let cleanupHandler: () -> Void
    
    init(windowId: UUID, coordinator: AppCoordinator, cleanupHandler: @escaping () -> Void) {
        self.windowId = windowId
        self.coordinator = coordinator
        self.cleanupHandler = cleanupHandler
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
        
        // Delegate to shared cleanup handler to avoid leaks or double work
        cleanupHandler()

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
