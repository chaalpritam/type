import SwiftUI
import Combine

// MARK: - App Coordinator
/// Central coordinator that manages app state and coordinates between modules
/// Implements comprehensive cleanup inspired by Beat's Document.m close method
@MainActor
class AppCoordinator: ObservableObject {
    // MARK: - Published Properties
    @Published var currentView: AppView = .editor
    @Published var isFullScreen: Bool = false
    @Published var showSettings: Bool = false
    @Published private(set) var isCleaningUp: Bool = false
    
    // MARK: - Module Coordinators
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
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var hasBeenCleanedUp = false
    private let cleanupLock = NSLock()
    
    // MARK: - Initialization
    init() {
        Logger.app.info("AppCoordinator init")
        // Initialize shared services
        self.documentService = DocumentService()
        self.settingsService = SettingsService()
        self.fileManagementService = FileManagementService()
        self.statisticsService = StatisticsService()
        self.storyProtocolService = StoryProtocolService()
        
        // Initialize module coordinators
        self.editorCoordinator = EditorCoordinator(documentService: documentService)
        self.characterCoordinator = CharacterCoordinator(documentService: documentService)
        self.outlineCoordinator = OutlineCoordinator(documentService: documentService)
        self.collaborationCoordinator = CollaborationCoordinator(documentService: documentService)
        self.fileCoordinator = FileCoordinator(documentService: documentService)
        self.storyProtocolCoordinator = StoryProtocolCoordinator(storyProtocolService: storyProtocolService, documentService: documentService)
        
        setupBindings()
    }
    
    deinit {
        Logger.app.info("AppCoordinator deinit")
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Listen for document changes and update all coordinators
        documentService.$currentDocument
            .sink { [weak self] document in
                self?.handleDocumentChange(document)
            }
            .store(in: &cancellables)
    }
    
    private func handleDocumentChange(_ document: ScreenplayDocument?) {
        // Don't process during cleanup
        guard !isCleaningUp else { return }
        
        // Update all coordinators when document changes
        editorCoordinator.updateDocument(document)
        characterCoordinator.updateDocument(document)
        outlineCoordinator.updateDocument(document)
        collaborationCoordinator.updateDocument(document)
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
        
        // 2. Cleanup file management service (invalidates timers)
        fileManagementService.cleanup()
        Logger.app.debug("FileManagementService cleaned up")
        
        // 3. Cleanup document service (invalidates auto-save timer)
        documentService.cleanup()
        Logger.app.debug("DocumentService cleaned up")
        
        // 4. Cleanup all module coordinators
        editorCoordinator.cleanup()
        characterCoordinator.cleanup()
        outlineCoordinator.cleanup()
        collaborationCoordinator.cleanup()
        fileCoordinator.cleanup()
        storyProtocolCoordinator.cleanup()
        Logger.app.debug("All coordinators cleaned up")
        
        // 5. Cleanup settings and statistics services
        settingsService.cleanup()
        statisticsService.cleanup()
        storyProtocolService.cleanup()
        Logger.app.debug("All services cleaned up")
        
        // 6. Remove any remaining notification observers
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