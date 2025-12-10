import SwiftUI
import Combine

// MARK: - App Coordinator
/// Central coordinator that manages app state and coordinates between modules
@MainActor
class AppCoordinator: ObservableObject {
    // MARK: - Published Properties
    @Published var currentView: AppView = .editor
    @Published var isFullScreen: Bool = false
    @Published var showSettings: Bool = false
    
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
    
    // MARK: - Initialization
    init() {
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
        // Update all coordinators when document changes
        editorCoordinator.updateDocument(document)
        characterCoordinator.updateDocument(document)
        outlineCoordinator.updateDocument(document)
        collaborationCoordinator.updateDocument(document)
    }
    func cleanup() {
        fileManagementService.cleanup()
        cancellables.removeAll()
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