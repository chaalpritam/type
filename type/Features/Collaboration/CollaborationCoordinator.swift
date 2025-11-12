import SwiftUI
import Combine

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
    
    // MARK: - ModuleCoordinator Implementation
    
    func createView() -> CollaborationMainView {
        return CollaborationMainView(coordinator: self)
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

// MARK: - Collaboration Main View
struct CollaborationMainView: View {
    @ObservedObject var coordinator: CollaborationCoordinator
    
    var body: some View {
        HStack(spacing: 0) {
            // Main collaboration dashboard
            VStack(spacing: 0) {
                // Collaboration toolbar
                CollaborationToolbarView(coordinator: coordinator)
                
                // Collaboration content
                CollaborationDashboardView(coordinator: coordinator)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Side panels
            VStack(spacing: 0) {
                if coordinator.showCommentsPanel {
                    CommentsPanel(
                        collaborationManager: coordinator.collaborationManager,
                        isVisible: $coordinator.showCommentsPanel
                    )
                    .frame(width: 350)
                    .transition(.move(edge: .trailing))
                }
                
                if coordinator.showVersionHistory {
                    VersionHistory(
                        collaborationManager: coordinator.collaborationManager,
                        isVisible: $coordinator.showVersionHistory
                    )
                    .frame(width: 350)
                    .transition(.move(edge: .trailing))
                }
                
                if coordinator.showCollaboratorsPanel {
                    CollaboratorsPanel(
                        collaborationManager: coordinator.collaborationManager,
                        isVisible: $coordinator.showCollaboratorsPanel
                    )
                    .frame(width: 300)
                    .transition(.move(edge: .trailing))
                }
            }
        }
        .sheet(isPresented: $coordinator.showSharingDialog) {
            SharingDialog(coordinator: coordinator)
        }
    }
}

// MARK: - Collaboration Toolbar View
struct CollaborationToolbarView: View {
    @ObservedObject var coordinator: CollaborationCoordinator
    
    var body: some View {
        HStack(spacing: 12) {
            // Collaboration controls
            HStack(spacing: 8) {
                Button(coordinator.isCollaborating ? "Stop Collaboration" : "Start Collaboration") {
                    if coordinator.isCollaborating {
                        coordinator.stopCollaboration()
                    } else {
                        coordinator.startCollaboration()
                    }
                }
                .buttonStyle(.borderedProminent)
                .background(coordinator.isCollaborating ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                
                Button("Share") {
                    coordinator.shareDocument()
                }
                .buttonStyle(.bordered)
            }
            
            Divider()
            
            // Panel toggles
            HStack(spacing: 8) {
                Button("Comments") {
                    coordinator.toggleCommentsPanel()
                }
                .background(coordinator.showCommentsPanel ? Color.blue.opacity(0.2) : Color.clear)
                
                Button("Versions") {
                    coordinator.toggleVersionHistory()
                }
                .background(coordinator.showVersionHistory ? Color.blue.opacity(0.2) : Color.clear)
                
                Button("Collaborators") {
                    coordinator.toggleCollaboratorsPanel()
                }
                .background(coordinator.showCollaboratorsPanel ? Color.blue.opacity(0.2) : Color.clear)
            }
            
            Spacer()
            
            // Statistics
            HStack(spacing: 16) {
                Text("Collaborators: \(coordinator.collaborators.count)")
                    .font(.caption)
                Text("Comments: \(coordinator.comments.count)")
                    .font(.caption)
                Text("Versions: \(coordinator.versions.count)")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .border(Color(.systemGray4), width: 0.5)
    }
}

// MARK: - Collaboration Dashboard View
struct CollaborationDashboardView: View {
    @ObservedObject var coordinator: CollaborationCoordinator
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Collaboration status
                CollaborationStatusCard(coordinator: coordinator)
                
                // Recent activity
                RecentActivityCard(coordinator: coordinator)
                
                // Quick actions
                QuickActionsCard(coordinator: coordinator)
            }
            .padding()
        }
    }
}

// MARK: - Collaboration Status Card
struct CollaborationStatusCard: View {
    @ObservedObject var coordinator: CollaborationCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Collaboration Status")
                .font(.headline)
            
            HStack {
                Circle()
                    .fill(coordinator.isCollaborating ? Color.green : Color.gray)
                    .frame(width: 12, height: 12)
                
                Text(coordinator.isCollaborating ? "Active" : "Inactive")
                    .font(.subheadline)
                    .foregroundColor(coordinator.isCollaborating ? .green : .secondary)
            }
            
            if coordinator.isCollaborating {
                Text("\(coordinator.collaborators.count) collaborators online")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Recent Activity Card
struct RecentActivityCard: View {
    @ObservedObject var coordinator: CollaborationCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
            
            if coordinator.comments.isEmpty && coordinator.versions.isEmpty {
                Text("No recent activity")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(coordinator.comments.prefix(3), id: \.id) { comment in
                        HStack {
                            Text("• Comment on line \(comment.lineNumber ?? 0)")
                                .font(.caption)
                            Spacer()
                            Text(comment.createdAt, style: .relative)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
} 