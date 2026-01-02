import SwiftUI

// MARK: - Sync Settings View
struct SyncSettingsView: View {
    @ObservedObject var syncCoordinator: SyncCoordinator
    @ObservedObject var authService: AuthService
    @ObservedObject var oauthCoordinator: OAuthCoordinator

    @Environment(\.dismiss) private var dismiss

    init(syncCoordinator: SyncCoordinator, authService: AuthService) {
        self.syncCoordinator = syncCoordinator
        self.authService = authService
        // OAuth coordinator will be injected later when we create it
        self.oauthCoordinator = OAuthCoordinator(authService: authService)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Sync Settings")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(spacing: 24) {
                    // Authentication Section
                    if authService.isAuthenticated {
                        authenticatedSection
                    } else {
                        authenticationSection
                    }

                    Divider()

                    // Sync Status Section
                    if authService.isAuthenticated {
                        syncStatusSection
                    }
                }
                .padding()
            }
        }
        .frame(width: 500, height: 600)
    }

    // MARK: - Private Views

    private var authenticationSection: some View {
        VStack(spacing: 16) {
            Text("Sign in to sync your screenplays")
                .font(.headline)

            AuthenticationView(
                authService: authService,
                oauthCoordinator: oauthCoordinator,
                syncCoordinator: syncCoordinator
            )
        }
    }

    private var authenticatedSection: some View {
        VStack(spacing: 16) {
            Text("Account")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            AuthenticationView(
                authService: authService,
                oauthCoordinator: oauthCoordinator,
                syncCoordinator: syncCoordinator
            )
        }
    }

    private var syncStatusSection: some View {
        VStack(spacing: 16) {
            Text("Sync Status")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Current status
            HStack {
                Text("Status:")
                    .foregroundColor(.secondary)
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    Text(syncCoordinator.syncStatus.description)
                }
            }

            // Last sync
            HStack {
                Text("Last synced:")
                    .foregroundColor(.secondary)
                Spacer()
                if let lastSync = syncCoordinator.lastSyncDate {
                    Text(lastSync, style: .relative)
                } else {
                    Text("Never")
                        .foregroundColor(.secondary)
                }
            }

            // Pending changes
            HStack {
                Text("Pending changes:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(syncCoordinator.pendingChanges)")
                    .foregroundColor(syncCoordinator.pendingChanges > 0 ? .orange : .secondary)
            }

            // Error message
            if let error = syncCoordinator.syncError {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Error:")
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }

            Divider()

            // Manual sync button
            Button(action: handleManualSync) {
                if syncCoordinator.isSyncing {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(maxWidth: .infinity)
                } else {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Sync Now")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(syncCoordinator.isSyncing)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    private var statusColor: Color {
        switch syncCoordinator.syncStatus {
        case .idle:
            return .gray
        case .syncing:
            return .blue
        case .success:
            return .green
        case .failed:
            return .red
        case .conflict:
            return .orange
        }
    }

    // MARK: - Private Methods

    private func handleManualSync() {
        Task {
            await syncCoordinator.syncNow()
        }
    }
}
