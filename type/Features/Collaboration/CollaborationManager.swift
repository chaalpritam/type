import Foundation
import SwiftUI
import Combine

@MainActor
class CollaborationManager: ObservableObject {
    @Published var collaborators: [Collaborator] = []
    @Published var comments: [Comment] = []
    @Published var versions: [DocumentVersion] = []
    @Published var isSharing: Bool = false
    @Published var currentUser: Collaborator?
    @Published var onlineUsers: [Collaborator] = []
    @Published var pendingInvites: [Invite] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let documentId: String
    
    init(documentId: String) {
        self.documentId = documentId
        setupCurrentUser()
        startCollaborationSession()
    }
    
    deinit {
        // Removed endCollaborationSession() to avoid main actor isolation violation
    }
    
    // MARK: - User Management
    
    private func setupCurrentUser() {
        currentUser = Collaborator(
            id: UUID().uuidString,
            name: NSFullUserName(),
            email: UserDefaults.standard.string(forKey: "UserEmail") ?? "",
            avatar: nil,
            role: .editor,
            isOnline: true
        )
    }
    
    func updateUserProfile(name: String, email: String) {
        currentUser?.name = name
        currentUser?.email = email
        UserDefaults.standard.set(email, forKey: "UserEmail")
        notifyUserUpdate()
    }
    
    // MARK: - Collaboration Session
    
    private func startCollaborationSession() {
        // In a real app, this would connect to a WebSocket or similar
        // For now, we'll simulate real-time updates
        Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateOnlineUsers()
            }
            .store(in: &cancellables)
    }
    
    private func endCollaborationSession() {
        cancellables.removeAll()
    }
    
    private func updateOnlineUsers() {
        // Simulate online users
        onlineUsers = collaborators.filter { $0.isOnline }
    }
    
    private func notifyUserUpdate() {
        // In a real app, this would send updates to other collaborators
        print("User updated: \(currentUser?.name ?? "Unknown")")
    }
    
    // MARK: - Comments
    
    func addComment(text: String, lineNumber: Int, selection: NSRange?) {
        let comment = Comment(
            id: UUID().uuidString,
            text: text,
            author: currentUser!,
            lineNumber: lineNumber,
            selection: selection,
            timestamp: Date(),
            replies: [],
            isResolved: false
        )
        
        comments.append(comment)
        saveComments()
    }
    
    func replyToComment(commentId: String, text: String) {
        guard let commentIndex = comments.firstIndex(where: { $0.id == commentId }) else { return }
        
        let reply = CommentReply(
            id: UUID().uuidString,
            text: text,
            author: currentUser!,
            timestamp: Date()
        )
        
        comments[commentIndex].replies.append(reply)
        saveComments()
    }
    
    func resolveComment(commentId: String) {
        guard let commentIndex = comments.firstIndex(where: { $0.id == commentId }) else { return }
        comments[commentIndex].isResolved = true
        saveComments()
    }
    
    func deleteComment(commentId: String) {
        comments.removeAll { $0.id == commentId }
        saveComments()
    }
    
    private func saveComments() {
        // In a real app, this would save to a backend
        if let data = try? JSONEncoder().encode(comments) {
            UserDefaults.standard.set(data, forKey: "Comments_\(documentId)")
        }
    }
    
    func loadComments() {
        if let data = UserDefaults.standard.data(forKey: "Comments_\(documentId)"),
           let loadedComments = try? JSONDecoder().decode([Comment].self, from: data) {
            comments = loadedComments
        }
    }
    
    // MARK: - Version Control
    
    func createVersion(content: String, description: String) {
        let version = DocumentVersion(
            id: UUID().uuidString,
            versionNumber: versions.count + 1,
            content: content,
            description: description,
            author: currentUser!,
            timestamp: Date(),
            changes: []
        )
        
        versions.append(version)
        saveVersions()
    }
    
    func compareVersions(version1: DocumentVersion, version2: DocumentVersion) -> [DocumentChange] {
        // Simple diff implementation
        let lines1 = version1.content.components(separatedBy: .newlines)
        let lines2 = version2.content.components(separatedBy: .newlines)
        
        var changes: [DocumentChange] = []
        
        for (index, line) in lines1.enumerated() {
            if index < lines2.count && line != lines2[index] {
                changes.append(DocumentChange(
                    type: .modified,
                    lineNumber: index + 1,
                    oldText: line,
                    newText: lines2[index],
                    author: currentUser!,
                    timestamp: Date()
                ))
            }
        }
        
        return changes
    }
    
    func restoreVersion(_ version: DocumentVersion) -> String {
        return version.content
    }
    
    private func saveVersions() {
        if let data = try? JSONEncoder().encode(versions) {
            UserDefaults.standard.set(data, forKey: "Versions_\(documentId)")
        }
    }
    
    func loadVersions() {
        if let data = UserDefaults.standard.data(forKey: "Versions_\(documentId)"),
           let loadedVersions = try? JSONDecoder().decode([DocumentVersion].self, from: data) {
            versions = loadedVersions
        }
    }
    
    // MARK: - Sharing & Invites
    
    func shareDocument(emails: [String], role: CollaboratorRole) {
        for email in emails {
            let invite = Invite(
                id: UUID().uuidString,
                email: email,
                role: role,
                documentId: documentId,
                invitedBy: currentUser!,
                timestamp: Date(),
                status: .pending
            )
            
            pendingInvites.append(invite)
        }
        
        saveInvites()
        isSharing = true
    }
    
    func acceptInvite(inviteId: String) {
        guard let inviteIndex = pendingInvites.firstIndex(where: { $0.id == inviteId }) else { return }
        
        var invite = pendingInvites[inviteIndex]
        invite.status = .accepted
        
        let collaborator = Collaborator(
            id: UUID().uuidString,
            name: invite.email.components(separatedBy: "@").first ?? "User",
            email: invite.email,
            avatar: nil,
            role: invite.role,
            isOnline: true
        )
        
        collaborators.append(collaborator)
        pendingInvites.remove(at: inviteIndex)
        
        saveInvites()
        saveCollaborators()
    }
    
    func declineInvite(inviteId: String) {
        guard let inviteIndex = pendingInvites.firstIndex(where: { $0.id == inviteId }) else { return }
        pendingInvites[inviteIndex].status = .declined
        saveInvites()
    }
    
    func removeCollaborator(collaboratorId: String) {
        collaborators.removeAll { $0.id == collaboratorId }
        saveCollaborators()
    }
    
    private func saveInvites() {
        if let data = try? JSONEncoder().encode(pendingInvites) {
            UserDefaults.standard.set(data, forKey: "Invites_\(documentId)")
        }
    }
    
    private func saveCollaborators() {
        if let data = try? JSONEncoder().encode(collaborators) {
            UserDefaults.standard.set(data, forKey: "Collaborators_\(documentId)")
        }
    }
    
    func loadInvites() {
        if let data = UserDefaults.standard.data(forKey: "Invites_\(documentId)"),
           let loadedInvites = try? JSONDecoder().decode([Invite].self, from: data) {
            pendingInvites = loadedInvites
        }
    }
    
    func loadCollaborators() {
        if let data = UserDefaults.standard.data(forKey: "Collaborators_\(documentId)"),
           let loadedCollaborators = try? JSONDecoder().decode([Collaborator].self, from: data) {
            collaborators = loadedCollaborators
        }
    }
    
    // MARK: - Real-time Updates
    
    func broadcastChange(_ change: DocumentChange) {
        // In a real app, this would send to other collaborators
        print("Broadcasting change: \(change.type) at line \(change.lineNumber)")
    }
    
    func receiveChange(_ change: DocumentChange) {
        // In a real app, this would apply changes from other collaborators
        print("Received change: \(change.type) at line \(change.lineNumber)")
    }
}

// MARK: - Models

struct Collaborator: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
    let avatar: String?
    let role: CollaboratorRole
    var isOnline: Bool
    
    var displayName: String {
        return name.isEmpty ? email : name
    }
}

enum CollaboratorRole: String, Codable, CaseIterable {
    case viewer = "Viewer"
    case commenter = "Commenter"
    case editor = "Editor"
    case owner = "Owner"
    
    var permissions: [Permission] {
        switch self {
        case .viewer:
            return [.read]
        case .commenter:
            return [.read, .comment]
        case .editor:
            return [.read, .comment, .edit]
        case .owner:
            return [.read, .comment, .edit, .share, .delete]
        }
    }
}

enum Permission: String, CaseIterable {
    case read = "Read"
    case comment = "Comment"
    case edit = "Edit"
    case share = "Share"
    case delete = "Delete"
}

struct Comment: Codable, Identifiable {
    let id: String
    let text: String
    let author: Collaborator
    let lineNumber: Int
    let selection: NSRange?
    let timestamp: Date
    var replies: [CommentReply]
    var isResolved: Bool
    
    var isResolvedDisplay: String {
        return isResolved ? "Resolved" : "Open"
    }
}

struct CommentReply: Codable, Identifiable {
    let id: String
    let text: String
    let author: Collaborator
    let timestamp: Date
}

struct DocumentVersion: Codable, Identifiable {
    let id: String
    let versionNumber: Int
    let content: String
    let description: String
    let author: Collaborator
    let timestamp: Date
    let changes: [DocumentChange]
    
    var displayName: String {
        return "v\(versionNumber) - \(description)"
    }
}

struct DocumentChange: Codable, Identifiable {
    var id = UUID().uuidString
    let type: ChangeType
    let lineNumber: Int
    let oldText: String?
    let newText: String?
    let author: Collaborator
    let timestamp: Date
    
    var description: String {
        switch type {
        case .added:
            return "Added line \(lineNumber)"
        case .deleted:
            return "Deleted line \(lineNumber)"
        case .modified:
            return "Modified line \(lineNumber)"
        }
    }
}

enum ChangeType: String, Codable, CaseIterable {
    case added = "Added"
    case deleted = "Deleted"
    case modified = "Modified"
}

struct Invite: Codable, Identifiable {
    let id: String
    let email: String
    let role: CollaboratorRole
    let documentId: String
    let invitedBy: Collaborator
    let timestamp: Date
    var status: InviteStatus
    
    var statusDisplay: String {
        return status.rawValue
    }
}

enum InviteStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case accepted = "Accepted"
    case declined = "Declined"
    case expired = "Expired"
} 