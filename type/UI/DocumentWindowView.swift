import SwiftUI

// Track which windows have been cleaned up (outside of SwiftUI state)
private var cleanedUpWindows = Set<UUID>()
private let cleanupLock = NSLock()

// MARK: - Document Window View
/// Wrapper view for each document window with its own coordinator
struct DocumentWindowView: View {
    // MARK: - Properties
    let windowId: UUID
    let documentURL: URL?
    let showWelcome: Bool
    
    @StateObject private var appCoordinator: AppCoordinator
    @StateObject private var windowManager = WindowManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    
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
                Logger.window.info("Window appeared: \(windowId.uuidString)")
                setupWindow()
            }
            .onDisappear {
                Logger.window.info("Window disappeared: \(windowId.uuidString)")
                // Capture references before view is torn down
                let coordinator = appCoordinator
                let winManager = windowManager
                let winId = windowId
                
                // Defer cleanup to next run loop to avoid threading issues during teardown
                DispatchQueue.main.async {
                    Self.performCleanup(windowId: winId, coordinator: coordinator, windowManager: winManager)
                }
            }
            .onChange(of: appCoordinator.fileManagementService.currentDocumentName) { _, newName in
                updateWindowTitle(newName)
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
        // Register this window with the window manager
        let documentId = appCoordinator.documentService.currentDocument?.id ?? UUID()
        let title = appCoordinator.fileManagementService.currentDocumentName
        windowManager.registerWindow(id: windowId, documentId: documentId, title: title)
        
        // Load document if URL is provided
        if let url = documentURL {
            Task {
                do {
                    try await appCoordinator.documentService.loadDocument(from: url)
                } catch {
                    print("Failed to load document: \(error.localizedDescription)")
                }
            }
        } else {
            // Create new document if no URL
            appCoordinator.documentService.newDocument()
        }
    }
    
    private static func performCleanup(windowId: UUID, coordinator: AppCoordinator, windowManager: WindowManager) {
        // Thread-safe check if already cleaned up
        cleanupLock.lock()
        let alreadyCleaned = cleanedUpWindows.contains(windowId)
        if !alreadyCleaned {
            cleanedUpWindows.insert(windowId)
        }
        cleanupLock.unlock()
        
        guard !alreadyCleaned else {
            Logger.window.info("Cleanup already performed for: \(windowId.uuidString)")
            return
        }
        
        Logger.window.info("Cleanup started for: \(windowId.uuidString)")
        
        // Unregister window
        windowManager.unregisterWindow(id: windowId)
        
        // Cleanup coordinator
        coordinator.cleanup()
        
        Logger.window.info("Cleanup completed for: \(windowId.uuidString)")
    }
    
    private func updateWindowTitle(_ title: String) {
        windowManager.updateWindowTitle(id: windowId, title: title)
        
        // Update the actual window title
        DispatchQueue.main.async {
            if let window = NSApp.windows.first(where: { 
                $0.identifier?.rawValue == windowId.uuidString 
            }) {
                window.title = title
            }
        }
    }
    
    private func loadDocument(url: URL) {
        Task {
            do {
                try await appCoordinator.documentService.loadDocument(from: url)
            } catch {
                print("Failed to load document: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    DocumentWindowView(windowId: UUID())
}
