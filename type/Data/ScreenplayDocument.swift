import Foundation

// MARK: - Screenplay Document
/// Central document model used across all modules
struct ScreenplayDocument: Identifiable, Codable, Equatable {
    let id: UUID
    var content: String
    var url: URL?
    var title: String
    var author: String
    var createdAt: Date
    var updatedAt: Date
    var metadata: DocumentMetadata

    // Sync metadata
    var syncedAt: Date?
    var modifiedSinceSync: Bool = false
    var remoteVersion: String?
    var syncSource: String? // "macos" or "web"

    init(content: String = "", url: URL? = nil, title: String = "Untitled", author: String = "") {
        self.id = UUID()
        self.content = content
        self.url = url
        self.title = title
        self.author = author
        self.createdAt = Date()
        self.updatedAt = Date()
        self.metadata = DocumentMetadata()
        self.syncedAt = nil
        self.modifiedSinceSync = false
        self.remoteVersion = nil
        self.syncSource = "macos"
    }

    mutating func updateContent(_ newContent: String) {
        content = newContent
        updatedAt = Date()
        modifiedSinceSync = true
    }

    mutating func updateMetadata(_ newMetadata: DocumentMetadata) {
        metadata = newMetadata
        updatedAt = Date()
        modifiedSinceSync = true
    }

    mutating func markAsSynced() {
        syncedAt = Date()
        modifiedSinceSync = false
    }
}

// MARK: - Document Metadata
struct DocumentMetadata: Codable, Equatable {
    var genre: String
    var targetLength: Int // in pages
    var status: DocumentStatus
    var tags: [String]
    var notes: String
    var version: String
    var collaborators: [String]
    var lastBackup: Date?
    
    init(genre: String = "", targetLength: Int = 120, status: DocumentStatus = .draft) {
        self.genre = genre
        self.targetLength = targetLength
        self.status = status
        self.tags = []
        self.notes = ""
        self.version = "1.0"
        self.collaborators = []
        self.lastBackup = nil
    }
}

// MARK: - Document Status
enum DocumentStatus: String, CaseIterable, Codable {
    case draft = "Draft"
    case inProgress = "In Progress"
    case review = "Review"
    case final = "Final"
    case archived = "Archived"
    
    var color: String {
        switch self {
        case .draft: return "gray"
        case .inProgress: return "blue"
        case .review: return "orange"
        case .final: return "green"
        case .archived: return "red"
        }
    }
} 