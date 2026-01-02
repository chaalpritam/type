import SwiftUI
import Combine

// MARK: - App Coordinator
/// Central coordinator that manages app state and coordinates between modules
/// Implements Document-Based MVC Architecture inspired by Beat's approach
///
/// The architecture follows Beat's pattern where:
/// - DocumentViewController is the central controller (like BeatDocumentViewController)
/// - Module coordinators act as helpers that work with the document delegate
/// - Views register with the document controller for updates (registered views pattern)
@MainActor
class AppCoordinator: ObservableObject {
    // MARK: - Published Properties
    @Published var currentView: AppView = .editor
    @Published var isFullScreen: Bool = false
    @Published var showSettings: Bool = false
    @Published private(set) var isCleaningUp: Bool = false
    
    // MARK: - Document Controller (Central Hub - Beat Pattern)
    /// The main document controller - like Beat's BeatDocumentViewController
    /// This is the central hub that manages document state and coordinates updates
    let documentController: DocumentViewController
    
    // MARK: - Module Coordinators (Work with DocumentController)
    let editorCoordinator: EditorCoordinator
    let characterCoordinator: CharacterCoordinator
    let outlineCoordinator: OutlineCoordinator
    let collaborationCoordinator: CollaborationCoordinator
    let fileCoordinator: FileCoordinator
    let storyProtocolCoordinator: StoryProtocolCoordinator
    
    // MARK: - Shared Services
    let documentService: DocumentService
    let settingsService: SettingsService
    let fileManagementService: FileManagementService
    let statisticsService: StatisticsService
    let storyProtocolService: StoryProtocolService

    // MARK: - Sync Services
    let networkService: NetworkService
    let authService: AuthService
    let syncService: SyncService
    let syncCoordinator: SyncCoordinator
    let oauthCoordinator: OAuthCoordinator

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var hasBeenCleanedUp = false
    private let cleanupLock = NSLock()
    
    // MARK: - Initialization
    init() {
        Logger.app.info("AppCoordinator init - Document-Based MVC Architecture")

        // Initialize the central document controller (like Beat)
        self.documentController = DocumentViewController()

        // Initialize shared services
        self.documentService = DocumentService()
        self.settingsService = SettingsService()
        self.fileManagementService = FileManagementService()
        self.statisticsService = StatisticsService()
        self.storyProtocolService = StoryProtocolService()

        // Initialize sync services
        self.networkService = NetworkService()
        self.authService = AuthService(networkService: networkService)
        self.syncService = SyncService(networkService: networkService, authService: authService)
        self.syncCoordinator = SyncCoordinator(
            syncService: syncService,
            documentService: documentService,
            authService: authService
        )
        self.oauthCoordinator = OAuthCoordinator(authService: authService)

        // Initialize module coordinators - they work with the document controller
        self.editorCoordinator = EditorCoordinator(documentService: documentService)
        self.characterCoordinator = CharacterCoordinator(documentService: documentService)
        self.outlineCoordinator = OutlineCoordinator(documentService: documentService)
        self.collaborationCoordinator = CollaborationCoordinator(documentService: documentService)
        self.fileCoordinator = FileCoordinator(documentService: documentService)
        self.storyProtocolCoordinator = StoryProtocolCoordinator(storyProtocolService: storyProtocolService, documentService: documentService)

        setupBindings()
        setupDocumentControllerBindings()
        setupSyncBindings()
    }
    
    deinit {
        Logger.app.info("AppCoordinator deinit")
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Listen for document changes from DocumentService and update coordinators
        documentService.$currentDocument
            .sink { [weak self] document in
                self?.handleDocumentChange(document)
            }
            .store(in: &cancellables)
    }
    
    /// Setup bindings between DocumentController and coordinators
    /// This implements Beat's pattern where the document controller is the central hub
    private func setupDocumentControllerBindings() {
        // Sync DocumentController text with DocumentService
        documentController.$text
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] newText in
                guard let self = self, !self.isCleaningUp else { return }
                self.documentService.updateDocumentContent(newText)
            }
            .store(in: &cancellables)
        
        // Sync DocumentController statistics with editor coordinator
        documentController.$wordCount
            .sink { [weak self] count in
                self?.editorCoordinator.wordCount = count
            }
            .store(in: &cancellables)
        
        documentController.$pageCount
            .sink { [weak self] count in
                self?.editorCoordinator.pageCount = count
            }
            .store(in: &cancellables)
        
        documentController.$characterCount
            .sink { [weak self] count in
                self?.editorCoordinator.characterCount = count
            }
            .store(in: &cancellables)
        
        // Sync preview state
        documentController.$showPreview
            .sink { [weak self] show in
                self?.editorCoordinator.showPreview = show
            }
            .store(in: &cancellables)
        
        // Sync undo/redo state
        documentController.$canUndo
            .sink { [weak self] canUndo in
                self?.editorCoordinator.canUndo = canUndo
            }
            .store(in: &cancellables)
        
        documentController.$canRedo
            .sink { [weak self] canRedo in
                self?.editorCoordinator.canRedo = canRedo
            }
            .store(in: &cancellables)
    }

    /// Setup sync bindings for auto-sync on document save
    private func setupSyncBindings() {
        // Auto-sync when document is saved (isDocumentModified changes from true to false)
        documentService.$isDocumentModified
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] isModified in
                guard let self = self, !self.isCleaningUp else { return }

                // When isDocumentModified becomes false, the document was saved
                if !isModified {
                    Task {
                        await self.syncCoordinator.handleAutoSync()
                    }
                }
            }
            .store(in: &cancellables)

        Logger.app.debug("Sync bindings setup complete")
    }

    private func handleDocumentChange(_ document: ScreenplayDocument?) {
        // Don't process during cleanup
        guard !isCleaningUp else { return }
        
        // Update DocumentController when document changes
        if let document = document {
            documentController.loadDocumentString(document.content)
            if let url = document.url {
                documentController.fileURL = url
            }
        }
        
        // Update all coordinators when document changes
        editorCoordinator.updateDocument(document)
        characterCoordinator.updateDocument(document)
        outlineCoordinator.updateDocument(document)
        collaborationCoordinator.updateDocument(document)
    }
    
    // MARK: - Document Operations (Delegate to DocumentController)
    
    /// Update document text - goes through DocumentController
    func updateText(_ newText: String) {
        documentController.updateText(newText)
    }
    
    /// Get current text from DocumentController
    var currentText: String {
        documentController.text
    }
    
    /// Get outline from DocumentController
    var outline: [OutlineScene] {
        documentController.outline
    }
    
    /// Load document from URL
    func loadDocument(from url: URL) throws {
        try documentController.loadDocument(from: url)
    }
    
    /// Save document to URL
    func saveDocument(to url: URL) throws {
        try documentController.saveDocument(to: url)
    }
    
    // MARK: - View Registration (Beat Pattern)
    
    /// Register a view for updates - delegated to DocumentController
    func registerEditorView(_ view: EditorView) {
        documentController.registerEditorView(view)
    }
    
    func unregisterEditorView(_ view: EditorView) {
        documentController.unregisterEditorView(view)
    }
    
    func registerOutlineView(_ view: SceneOutlineView) {
        documentController.registerOutlineView(view)
    }
    
    func unregisterOutlineView(_ view: SceneOutlineView) {
        documentController.unregisterOutlineView(view)
    }
    
    func registerSelectionObserver(_ observer: SelectionObserver) {
        documentController.registerSelectionObserver(observer)
    }
    
    func unregisterSelectionObserver(_ observer: SelectionObserver) {
        documentController.unregisterSelectionObserver(observer)
    }
    
    /// Comprehensive cleanup method inspired by Beat's Document.m close method
    /// This method ensures all resources are properly released to prevent crashes
    func cleanup() {
        // Thread-safe check to prevent double cleanup
        cleanupLock.lock()
        if hasBeenCleanedUp {
            cleanupLock.unlock()
            Logger.app.info("AppCoordinator cleanup already performed, skipping")
            return
        }
        hasBeenCleanedUp = true
        isCleaningUp = true
        cleanupLock.unlock()
        
        Logger.app.info("AppCoordinator cleanup started")
        
        // 1. Cancel all Combine subscriptions FIRST (like Beat's observer removal)
        cancellables.removeAll()
        Logger.app.debug("Cancelled all subscriptions")
        
        // 2. Cleanup the central document controller (like Beat's unloadViews)
        documentController.cleanup()
        Logger.app.debug("DocumentController cleaned up")
        
        // 3. Cleanup file management service (invalidates timers)
        fileManagementService.cleanup()
        Logger.app.debug("FileManagementService cleaned up")
        
        // 4. Cleanup document service (invalidates auto-save timer)
        documentService.cleanup()
        Logger.app.debug("DocumentService cleaned up")
        
        // 5. Cleanup all module coordinators
        editorCoordinator.cleanup()
        characterCoordinator.cleanup()
        outlineCoordinator.cleanup()
        collaborationCoordinator.cleanup()
        fileCoordinator.cleanup()
        storyProtocolCoordinator.cleanup()
        Logger.app.debug("All coordinators cleaned up")
        
        // 6. Cleanup settings and statistics services
        settingsService.cleanup()
        statisticsService.cleanup()
        storyProtocolService.cleanup()
        Logger.app.debug("All services cleaned up")

        // 7. Cleanup sync services
        syncCoordinator.cleanup()
        syncService.cleanup()
        authService.cleanup()
        networkService.cleanup()
        Logger.app.debug("Sync services cleaned up")

        // 8. Remove any remaining notification observers
        NotificationCenter.default.removeObserver(self)
        Logger.app.debug("Removed notification observers")

        isCleaningUp = false
        Logger.app.info("AppCoordinator cleanup completed")
    }
}

// MARK: - App View Enum
enum AppView: String, CaseIterable {
    case editor = "Editor"
    case characters = "Characters"
    case outline = "Outline"
    case collaboration = "Collaboration"
    
    var icon: String {
        switch self {
        case .editor: return "doc.text"
        case .characters: return "person.2"
        case .outline: return "list.bullet"
        case .collaboration: return "person.3"
        }
    }
} 