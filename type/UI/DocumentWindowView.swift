import SwiftUI

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
                setupWindow()
            }
            .onDisappear {
                cleanupWindow()
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
        
        // Set window identifier for tracking
        if let window = NSApp.keyWindow {
            window.identifier = NSUserInterfaceItemIdentifier(windowId.uuidString)
        }
    }
    
    private func cleanupWindow() {
        // Unregister window when it closes
        windowManager.unregisterWindow(id: windowId)
        
        // Cleanup services (timers, monitors)
        appCoordinator.cleanup()
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
