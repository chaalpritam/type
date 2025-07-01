import SwiftUI
import Combine
import Data.ScreenplayDocument
import Services.DocumentService
import Core.ModuleCoordinator
import Features.Collaboration.CollaborationManager

// MARK: - Collaboration Coordinator
/// Coordinates all collaboration-related functionality
@MainActor
class CollaborationCoordinator: BaseModuleCoordinator {
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
        comments.filter { $0.status == .active }
    }
    
    var resolvedComments: [Comment] {
        comments.filter { $0.status == .resolved }
    }
    
    var recentVersions: [DocumentVersion] {
        Array(versions.prefix(10))
    }
    
    // MARK: - Initialization
    override init(documentService: DocumentService) {
        let documentId = documentService.currentDocument?.id?.uuidString ?? UUID().uuidString
        self.collaborationManager = CollaborationManager(documentId: documentId)
        super.init(documentService: documentService)
        setupCollaborationBindings()
    }
    
    // MARK: - Public Methods
    
    override func updateDocument(_ document: ScreenplayDocument?) {
        if let document = document {
            // Update collaboration manager with new document
            collaborationManager.updateDocument(document)
            
            // Update local state
            collaborators = collaborationManager.collaborators
            comments = collaborationManager.comments
            versions = collaborationManager.versions
        } else {
            collaborators = []
            comments = []
            versions = []
        }
    }
    
    func startCollaboration() {
        isCollaborating = true
        collaborationManager.startCollaboration()
    }
    
    func stopCollaboration() {
        isCollaborating = false
        collaborationManager.stopCollaboration()
    }
    
    func addComment(_ comment: Comment) {
        collaborationManager.addComment(comment)
        comments = collaborationManager.comments
    }
    
    func updateComment(_ comment: Comment) {
        collaborationManager.updateComment(comment)
        comments = collaborationManager.comments
    }
    
    func resolveComment(_ comment: Comment) {
        var updatedComment = comment
        updatedComment.status = .resolved
        updatedComment.resolvedAt = Date()
        updateComment(updatedComment)
    }
    
    func deleteComment(_ comment: Comment) {
        collaborationManager.deleteComment(comment)
        comments = collaborationManager.comments
    }
    
    func addCollaborator(_ collaborator: Collaborator) {
        collaborationManager.addCollaborator(collaborator)
        collaborators = collaborationManager.collaborators
    }
    
    func removeCollaborator(_ collaborator: Collaborator) {
        collaborationManager.removeCollaborator(collaborator)
        collaborators = collaborationManager.collaborators
    }
    
    func createVersion(_ name: String, description: String = "") {
        guard let document = documentService.currentDocument else { return }
        
        let version = DocumentVersion(
            id: UUID(),
            name: name,
            description: description,
            content: document.content,
            createdAt: Date(),
            createdBy: currentUser?.id ?? UUID()
        )
        
        collaborationManager.addVersion(version)
        versions = collaborationManager.versions
    }
    
    func restoreVersion(_ version: DocumentVersion) {
        documentService.updateDocumentContent(version.content)
        collaborationManager.setCurrentVersion(version)
    }
    
    func shareDocument() {
        showSharingDialog = true
    }
    
    func exportComments() async throws -> URL? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.json]
        panel.nameFieldStringValue = "Comments.json"
        panel.title = "Export Comments"
        panel.message = "Choose a location to save the comments data"
        
        let response = await panel.beginSheetModal(for: NSApp.keyWindow!)
        
        if response == .OK, let url = panel.url {
            let data = try JSONEncoder().encode(comments)
            try data.write(to: url)
            return url
        }
        
        return nil
    }
    
    func importComments() async throws -> URL? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.json]
        panel.allowsMultipleSelection = false
        panel.title = "Import Comments"
        panel.message = "Choose a comments data file to import"
        
        let response = await panel.beginSheetModal(for: NSApp.keyWindow!)
        
        if response == .OK, let url = panel.url {
            let data = try Data(contentsOf: url)
            let importedComments = try JSONDecoder().decode([Comment].self, from: data)
            
            // Add to existing comments
            for comment in importedComments {
                addComment(comment)
            }
            
            return url
        }
        
        return nil
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
        // Listen for document changes
        documentService.$currentDocument
            .sink { [weak self] document in
                self?.updateDocument(document)
            }
            .store(in: &cancellables)
        
        // Listen for collaboration manager changes
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

// MARK: - Collaborator Model
struct Collaborator: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var email: String
    var role: CollaboratorRole
    var permissions: [CollaborationPermission]
    var joinedAt: Date
    var lastActive: Date
    
    init(name: String, email: String, role: CollaboratorRole = .viewer) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.role = role
        self.permissions = role.defaultPermissions
        self.joinedAt = Date()
        self.lastActive = Date()
    }
}

// MARK: - Comment Model
struct Comment: Identifiable, Codable, Hashable {
    let id: UUID
    var content: String
    var author: UUID
    var lineNumber: Int?
    var scene: String?
    var status: CommentStatus
    var createdAt: Date
    var updatedAt: Date
    var resolvedAt: Date?
    var replies: [CommentReply]
    
    init(content: String, author: UUID, lineNumber: Int? = nil, scene: String? = nil) {
        self.id = UUID()
        self.content = content
        self.author = author
        self.lineNumber = lineNumber
        self.scene = scene
        self.status = .active
        self.createdAt = Date()
        self.updatedAt = Date()
        self.replies = []
    }
}

// MARK: - Document Version Model
struct DocumentVersion: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var content: String
    var createdAt: Date
    var createdBy: UUID
    
    init(id: UUID, name: String, description: String, content: String, createdAt: Date, createdBy: UUID) {
        self.id = id
        self.name = name
        self.description = description
        self.content = content
        self.createdAt = createdAt
        self.createdBy = createdBy
    }
}

// MARK: - Comment Reply Model
struct CommentReply: Identifiable, Codable, Hashable {
    let id: UUID
    var content: String
    var author: UUID
    var createdAt: Date
    
    init(content: String, author: UUID) {
        self.id = UUID()
        self.content = content
        self.author = author
        self.createdAt = Date()
    }
}

// MARK: - Enums
enum CollaboratorRole: String, CaseIterable, Codable {
    case owner = "Owner"
    case editor = "Editor"
    case viewer = "Viewer"
    case commenter = "Commenter"
    
    var defaultPermissions: [CollaborationPermission] {
        switch self {
        case .owner:
            return CollaborationPermission.allCases
        case .editor:
            return [.edit, .comment, .view]
        case .viewer:
            return [.view]
        case .commenter:
            return [.comment, .view]
        }
    }
}

enum CollaborationPermission: String, CaseIterable, Codable {
    case edit = "Edit"
    case comment = "Comment"
    case view = "View"
    case share = "Share"
    case manage = "Manage"
}

enum CommentStatus: String, CaseIterable, Codable {
    case active = "Active"
    case resolved = "Resolved"
    case archived = "Archived"
} 