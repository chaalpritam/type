import SwiftUI
import Combine
import UniformTypeIdentifiers
import AppKit

// MARK: - Collaboration Coordinator
/// Coordinates all collaboration-related functionality
@MainActor
class CollaborationCoordinator: BaseModuleCoordinator, ModuleCoordinator {
    typealias ModuleView = CollaborationMainView
    
    // MARK: - Published Properties
    @Published var collaborators: [Collaborator] = []
    @Published var comments: [Comment] = []
    @Published var versions: [DocumentVersion] = []
    @Published var showCommentsPanel: Bool = false
    @Published var showVersionHistory: Bool = false
    @Published var showCollaboratorsPanel: Bool = false
    @Published var showSharingDialog: Bool = false
    @Published var isCollaborating: Bool = false
    @Published var currentUser: Collaborator?
    
    // MARK: - Services
    private let collaborationManager: CollaborationManager
    
    // MARK: - Computed Properties
    var activeComments: [Comment] {
        comments
    }
    
    var resolvedComments: [Comment] {
        []
    }
    
    var recentVersions: [DocumentVersion] {
        Array(versions.prefix(10))
    }
    
    // MARK: - Initialization
    override init(documentService: DocumentService) {
        let cm = CollaborationManager(documentId: UUID().uuidString)
        self.collaborationManager = cm
        super.init(documentService: documentService)
        Task { @MainActor in
        setupCollaborationBindings()
        }
    }
    
    // MARK: - ModuleCoordinator Implementation
    
    func createView() -> CollaborationMainView {
        return CollaborationMainView(coordinator: self)
    }
    
    // MARK: - Public Methods
    
    override func updateDocument(_ document: ScreenplayDocument?) {
        Task { @MainActor in
        if let document = document {
            collaborators = collaborationManager.collaborators
            comments = collaborationManager.comments
            versions = collaborationManager.versions
        } else {
            collaborators = []
            comments = []
            versions = []
            }
        }
    }
    
    func startCollaboration() {
        isCollaborating = true
    }
    
    func stopCollaboration() {
        isCollaborating = false
    }
    
    func addComment(_ comment: Comment) {
        comments.append(comment)
        collaborationManager.addComment(text: comment.text, lineNumber: comment.lineNumber, selection: nil)
    }
    
    func updateComment(_ comment: Comment) {
        if let index = comments.firstIndex(where: { $0.id == comment.id }) {
            comments[index] = comment
        }
    }
    
    func resolveComment(_ comment: Comment) {
        updateComment(comment)
    }
    
    func deleteComment(_ comment: Comment) {
        comments.removeAll { $0.id == comment.id }
        collaborationManager.deleteComment(commentId: String(comment.id.hashValue))
    }
    
    func addCollaborator(_ collaborator: Collaborator) {
        collaborators.append(collaborator)
    }
    
    func removeCollaborator(_ collaborator: Collaborator) {
        collaborators.removeAll { $0.id == collaborator.id }
        collaborationManager.removeCollaborator(collaboratorId: String(collaborator.id.hashValue))
    }
    
    func createVersion(_ name: String, description: String = "") {
        guard let document = documentService.currentDocument else { return }
        
        let version = DocumentVersion(
            id: UUID().uuidString,
            versionNumber: versions.count + 1,
            content: document.content,
            description: description,
            author: currentUser ?? Collaborator(id: UUID().uuidString, name: "Unknown", email: "", avatar: nil, role: .viewer, isOnline: false),
            timestamp: Date(),
            changes: []
        )
        
        versions.append(version)
    }
    
    func restoreVersion(_ version: DocumentVersion) {
        // Simplified - implementation needed
    }
    
    func shareDocument() {
        showSharingDialog = true
    }
    
    func toggleCommentsPanel() {
        showCommentsPanel.toggle()
    }
    
    func toggleVersionHistory() {
        showVersionHistory.toggle()
    }
    
    func toggleCollaboratorsPanel() {
        showCollaboratorsPanel.toggle()
    }
    
    // MARK: - Private Methods
    
    private func setupCollaborationBindings() {
        documentService.$currentDocument
            .sink { [weak self] document in
                self?.updateDocument(document)
            }
            .store(in: &cancellables)
        
        collaborationManager.$collaborators
            .sink { [weak self] collaborators in
                self?.collaborators = collaborators
            }
            .store(in: &cancellables)
        
        collaborationManager.$comments
            .sink { [weak self] comments in
                self?.comments = comments
            }
            .store(in: &cancellables)
        
        collaborationManager.$versions
            .sink { [weak self] versions in
                self?.versions = versions
            }
            .store(in: &cancellables)
    }
}

// MARK: - Collaboration Main View
struct CollaborationMainView: View {
    @ObservedObject var coordinator: CollaborationCoordinator
    
    var body: some View {
        VStack {
            Text("Collaboration features coming soon")
                .font(.title)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
