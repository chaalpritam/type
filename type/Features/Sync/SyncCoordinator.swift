import Foundation
import Combine
import SwiftUI

// MARK: - Sync Coordinator
/// Orchestrates sync operations between the app and API
@MainActor
class SyncCoordinator: ObservableObject {
    // MARK: - Published Properties
    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?
    @Published var syncStatus: SyncStatus = .idle
    @Published var pendingChanges: Int = 0
    @Published var currentConflict: SyncConflict?
    @Published var showConflictSheet: Bool = false
    @Published var syncError: String?

    // MARK: - Private Properties
    private let syncService: SyncService
    private let documentService: DocumentService
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()

    // Auto-sync configuration
    private var autoSyncEnabled: Bool = true
    private var autoSyncDebounce: TimeInterval = 2.0

    // MARK: - Initialization
    init(syncService: SyncService, documentService: DocumentService, authService: AuthService) {
        self.syncService = syncService
        self.documentService = documentService
        self.authService = authService

        Logger.sync.info("SyncCoordinator initialized")

        setupBindings()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // Subscribe to sync service status
        syncService.$syncStatus
            .assign(to: &$syncStatus)

        syncService.$isSyncing
            .assign(to: &$isSyncing)

        syncService.$lastSyncDate
            .assign(to: &$lastSyncDate)

        syncService.$currentConflict
            .sink { [weak self] conflict in
                self?.handleConflictDetected(conflict)
            }
            .store(in: &cancellables)

        // Calculate pending changes
        documentService.$currentDocument
            .sink { [weak self] document in
                self?.updatePendingChanges(document)
            }
            .store(in: &cancellables)

        Logger.sync.debug("SyncCoordinator bindings setup complete")
    }

    private func handleConflictDetected(_ conflict: SyncConflict?) {
        guard let conflict = conflict else { return }

        currentConflict = conflict
        showConflictSheet = true

        Logger.sync.warning("Conflict detected, showing resolution UI")
    }

    private func updatePendingChanges(_ document: ScreenplayDocument?) {
        if let document = document, document.modifiedSinceSync {
            pendingChanges = 1
        } else {
            pendingChanges = 0
        }
    }

    // MARK: - Public Methods

    /// Manually trigger sync
    func syncNow() async {
        guard let document = documentService.currentDocument else {
            Logger.sync.warning("Cannot sync - no current document")
            syncError = "No document to sync"
            return
        }

        guard authService.isAuthenticated else {
            Logger.sync.warning("Cannot sync - not authenticated")
            syncError = "Please sign in to sync"
            return
        }

        do {
            Logger.sync.info("Manual sync triggered")
            try await syncService.syncScreenplay(document)

            // Mark document as synced
            documentService.markDocumentAsSynced()

            syncError = nil
            Logger.sync.info("Manual sync completed successfully")

        } catch let error as SyncError {
            handleSyncError(error)
        } catch {
            Logger.sync.error("Unknown sync error: \(error.localizedDescription)")
            syncError = error.localizedDescription
        }
    }

    /// Auto-sync triggered after document save
    func handleAutoSync() async {
        guard autoSyncEnabled else {
            Logger.sync.debug("Auto-sync disabled, skipping")
            return
        }

        guard let document = documentService.currentDocument else {
            return
        }

        guard authService.isAuthenticated else {
            Logger.sync.debug("Not authenticated, skipping auto-sync")
            return
        }

        guard document.modifiedSinceSync else {
            Logger.sync.debug("No pending changes, skipping auto-sync")
            return
        }

        do {
            Logger.sync.info("Auto-sync triggered")
            try await syncService.syncScreenplay(document)

            // Mark document as synced
            documentService.markDocumentAsSynced()

            syncError = nil
            Logger.sync.info("Auto-sync completed successfully")

        } catch let error as SyncError {
            handleSyncError(error)
        } catch {
            Logger.sync.error("Auto-sync error: \(error.localizedDescription)")
            syncError = error.localizedDescription
        }
    }

    /// Resolve a sync conflict
    func resolveConflict(resolution: ConflictResolution) async {
        guard let conflict = currentConflict else {
            Logger.sync.warning("No conflict to resolve")
            return
        }

        guard let document = documentService.currentDocument else {
            Logger.sync.error("No current document for conflict resolution")
            return
        }

        do {
            Logger.sync.info("Resolving conflict")
            let resolvedDocument = try await syncService.resolveConflict(
                conflict,
                resolution: resolution,
                document: document
            )

            // Update document service with resolved document
            documentService.currentDocument = resolvedDocument
            documentService.markDocumentAsSynced()

            // Clear conflict state
            currentConflict = nil
            showConflictSheet = false
            syncError = nil

            Logger.sync.info("Conflict resolved successfully")

        } catch {
            Logger.sync.error("Error resolving conflict: \(error.localizedDescription)")
            syncError = "Failed to resolve conflict: \(error.localizedDescription)"
        }
    }

    /// Dismiss conflict sheet without resolving
    func dismissConflict() {
        showConflictSheet = false
        Logger.sync.info("Conflict sheet dismissed")
    }

    /// Toggle auto-sync
    func toggleAutoSync() {
        autoSyncEnabled.toggle()
        Logger.sync.info("Auto-sync \(self.autoSyncEnabled ? "enabled" : "disabled")")
    }

    // MARK: - Error Handling

    private func handleSyncError(_ error: SyncError) {
        switch error {
        case .notAuthenticated:
            syncError = "Please sign in to sync"
            Logger.sync.warning("Sync failed - not authenticated")

        case .networkError(let networkError):
            syncError = "Network error: \(networkError.localizedDescription)"
            Logger.sync.error("Sync failed - network error: \(networkError)")

        case .syncFailed(let message):
            syncError = "Sync failed: \(message)"
            Logger.sync.error("Sync failed: \(message)")

        case .conflictDetected(let conflict):
            // Conflict is handled by the binding to syncService.$currentConflict
            Logger.sync.info("Conflict detected: \(conflict.message)")

        case .invalidData:
            syncError = "Invalid data"
            Logger.sync.error("Sync failed - invalid data")

        case .unknown(let unknownError):
            syncError = "Unknown error: \(unknownError.localizedDescription)"
            Logger.sync.error("Unknown sync error: \(unknownError)")
        }
    }

    // MARK: - Cleanup

    func cleanup() {
        Logger.sync.info("SyncCoordinator cleanup")
        cancellables.removeAll()
    }
}
