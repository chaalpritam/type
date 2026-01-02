import Foundation
import Combine

// MARK: - Sync Models

/// Request model for syncing screenplay to API
struct SyncScreenplayRequest: Codable {
    let id: String // UUID
    let title: String
    let content: String
    let author: String
    let status: String // "draft" or "finished"
    let version: String
    let genre: String?
    let tags: [String]
    let lastModified: Date

    enum CodingKeys: String, CodingKey {
        case id, title, content, author, status, version, genre, tags
        case lastModified = "macOSLastModified"
    }
}

/// Response model from sync API
struct SyncScreenplayResponse: Codable {
    let success: Bool
    let data: SyncData?
    let error: ErrorDetail?

    struct SyncData: Codable {
        let screenplay: SyncedScreenplay
        let conflict: Bool?
        let conflictMessage: String?
    }

    struct SyncedScreenplay: Codable {
        let id: String
        let title: String
        let content: String
        let updatedAt: Date
        let lastSyncedAt: Date
    }

    struct ErrorDetail: Codable {
        let code: String
        let message: String
    }
}

/// Conflict information
struct SyncConflict: Identifiable, Codable {
    let id: UUID
    let screenplayId: String
    let localTimestamp: Date
    let remoteTimestamp: Date
    let message: String
    let remoteContent: String?

    init(screenplayId: String, localTimestamp: Date, remoteTimestamp: Date, message: String, remoteContent: String? = nil) {
        self.id = UUID()
        self.screenplayId = screenplayId
        self.localTimestamp = localTimestamp
        self.remoteTimestamp = remoteTimestamp
        self.message = message
        self.remoteContent = remoteContent
    }
}

/// Conflict resolution choice
enum ConflictResolution {
    case keepLocal
    case keepRemote
    case manual(String) // Manually merged content
}

/// Sync status
enum SyncStatus {
    case idle
    case syncing
    case success
    case failed(String)
    case conflict

    var description: String {
        switch self {
        case .idle:
            return "Not synced"
        case .syncing:
            return "Syncing..."
        case .success:
            return "Synced"
        case .failed(let message):
            return "Failed: \(message)"
        case .conflict:
            return "Conflict detected"
        }
    }
}

// MARK: - Sync Service
/// Service for syncing screenplay data with the API
@MainActor
class SyncService: ObservableObject {
    // MARK: - Published Properties
    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?
    @Published var syncStatus: SyncStatus = .idle
    @Published var currentConflict: SyncConflict?

    // MARK: - Private Properties
    private let networkService: NetworkService
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(networkService: NetworkService, authService: AuthService) {
        self.networkService = networkService
        self.authService = authService
        Logger.sync.info("SyncService initialized")
    }

    // MARK: - Public Methods

    /// Sync screenplay to the cloud
    func syncScreenplay(_ document: ScreenplayDocument) async throws {
        guard authService.isAuthenticated else {
            Logger.sync.warning("Cannot sync - not authenticated")
            throw SyncError.notAuthenticated
        }

        isSyncing = true
        syncStatus = .syncing

        defer {
            isSyncing = false
        }

        do {
            Logger.sync.info("Syncing screenplay: \(document.id)")

            // Map document status to API format
            let apiStatus = mapDocumentStatusToAPI(document.metadata.status)

            // Create sync request
            let request = SyncScreenplayRequest(
                id: document.id.uuidString,
                title: document.title,
                content: document.content,
                author: document.author,
                status: apiStatus,
                version: document.metadata.version,
                genre: document.metadata.genre.isEmpty ? nil : document.metadata.genre,
                tags: document.metadata.tags,
                lastModified: document.updatedAt
            )

            // Send sync request
            let response: SyncScreenplayResponse = try await networkService.authenticatedRequest(
                "/api/sync/macos/screenplay",
                method: .POST,
                body: request
            )

            guard response.success else {
                let errorMessage = response.error?.message ?? "Sync failed"
                Logger.sync.error("Sync failed: \(errorMessage)")
                syncStatus = .failed(errorMessage)
                throw SyncError.syncFailed(errorMessage)
            }

            // Check for conflict
            if let conflict = response.data?.conflict, conflict == true {
                let conflictMessage = response.data?.conflictMessage ?? "Newer version exists on server"
                Logger.sync.warning("Conflict detected: \(conflictMessage)")

                let syncConflict = SyncConflict(
                    screenplayId: document.id.uuidString,
                    localTimestamp: document.updatedAt,
                    remoteTimestamp: response.data?.screenplay.updatedAt ?? Date(),
                    message: conflictMessage,
                    remoteContent: response.data?.screenplay.content
                )

                currentConflict = syncConflict
                syncStatus = .conflict
                throw SyncError.conflictDetected(syncConflict)
            }

            // Sync successful
            lastSyncDate = Date()
            syncStatus = .success

            Logger.sync.info("Sync successful")

        } catch let error as NetworkError {
            Logger.sync.error("Network error during sync: \(error.localizedDescription)")
            syncStatus = .failed(error.localizedDescription ?? "Network error")
            throw SyncError.networkError(error)
        } catch let error as SyncError {
            throw error
        } catch {
            Logger.sync.error("Unknown error during sync: \(error.localizedDescription)")
            syncStatus = .failed(error.localizedDescription)
            throw SyncError.unknown(error)
        }
    }

    /// Resolve a conflict
    func resolveConflict(
        _ conflict: SyncConflict,
        resolution: ConflictResolution,
        document: ScreenplayDocument
    ) async throws -> ScreenplayDocument {
        let resolutionDescription: String
        switch resolution {
        case .keepLocal:
            resolutionDescription = "keepLocal"
        case .keepRemote:
            resolutionDescription = "keepRemote"
        case .manual:
            resolutionDescription = "manual"
        }
        Logger.sync.info("Resolving conflict with resolution: \(resolutionDescription)")

        var resolvedDocument = document

        switch resolution {
        case .keepLocal:
            // Re-sync with force flag (not implemented in API yet)
            // For now, just re-sync and the newer timestamp will win
            try await syncScreenplay(document)

        case .keepRemote:
            // Update local document with remote content
            if let remoteContent = conflict.remoteContent {
                resolvedDocument.content = remoteContent
                resolvedDocument.updatedAt = conflict.remoteTimestamp
            }

        case .manual(let mergedContent):
            // Use manually merged content
            resolvedDocument.content = mergedContent
            resolvedDocument.updatedAt = Date()
            // Sync the merged version
            try await syncScreenplay(resolvedDocument)
        }

        // Clear current conflict
        currentConflict = nil
        syncStatus = .success

        Logger.sync.info("Conflict resolved")

        return resolvedDocument
    }

    /// Fetch screenplay from cloud
    func fetchScreenplay(id: String) async throws -> SyncScreenplayResponse.SyncedScreenplay {
        guard authService.isAuthenticated else {
            throw SyncError.notAuthenticated
        }

        Logger.sync.info("Fetching screenplay: \(id)")

        struct FetchResponse: Codable {
            let success: Bool
            let data: SyncScreenplayResponse.SyncedScreenplay?
        }

        let response: FetchResponse = try await networkService.authenticatedRequest(
            "/api/screenplays/\(id)",
            method: .GET
        )

        guard response.success, let screenplay = response.data else {
            throw SyncError.syncFailed("Failed to fetch screenplay")
        }

        Logger.sync.info("Screenplay fetched successfully")

        return screenplay
    }

    // MARK: - Private Methods

    /// Map DocumentStatus to API status format
    private func mapDocumentStatusToAPI(_ status: DocumentStatus) -> String {
        switch status {
        case .draft, .inProgress, .review:
            return "draft"
        case .final, .archived:
            return "finished"
        }
    }

    // MARK: - Cleanup

    func cleanup() {
        Logger.sync.info("SyncService cleanup")
        cancellables.removeAll()
    }
}

// MARK: - Sync Error
enum SyncError: LocalizedError {
    case notAuthenticated
    case networkError(Error)
    case syncFailed(String)
    case conflictDetected(SyncConflict)
    case invalidData
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated. Please sign in to sync."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .syncFailed(let message):
            return "Sync failed: \(message)"
        case .conflictDetected(let conflict):
            return conflict.message
        case .invalidData:
            return "Invalid data"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
