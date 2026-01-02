import SwiftUI

// MARK: - Sync Status View
struct SyncStatusView: View {
    @ObservedObject var syncCoordinator: SyncCoordinator
    @ObservedObject var authService: AuthService

    @State private var showSyncSettings: Bool = false

    var body: some View {
        Button(action: { showSyncSettings.toggle() }) {
            HStack(spacing: 4) {
                // Sync status icon
                Image(systemName: syncStatusIcon)
                    .foregroundColor(syncStatusColor)
                    .imageScale(.medium)

                // Pending changes indicator
                if syncCoordinator.pendingChanges > 0 {
                    Text("\(syncCoordinator.pendingChanges)")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .help(syncStatusTooltip)
        .sheet(isPresented: $showSyncSettings) {
            SyncSettingsView(
                syncCoordinator: syncCoordinator,
                authService: authService
            )
        }
    }

    // MARK: - Private Computed Properties

    private var syncStatusIcon: String {
        if !authService.isAuthenticated {
            return "cloud.slash"
        }

        switch syncCoordinator.syncStatus {
        case .idle:
            return "cloud"
        case .syncing:
            return "arrow.triangle.2.circlepath"
        case .success:
            return "cloud.fill"
        case .failed:
            return "exclamationmark.cloud"
        case .conflict:
            return "exclamationmark.triangle"
        }
    }

    private var syncStatusColor: Color {
        if !authService.isAuthenticated {
            return .gray
        }

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

    private var syncStatusTooltip: String {
        if !authService.isAuthenticated {
            return "Not signed in - Click to sign in"
        }

        var tooltip = syncCoordinator.syncStatus.description

        if let lastSync = syncCoordinator.lastSyncDate {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            let relativeTime = formatter.localizedString(for: lastSync, relativeTo: Date())
            tooltip += "\nLast sync: \(relativeTime)"
        }

        if syncCoordinator.pendingChanges > 0 {
            tooltip += "\n\(syncCoordinator.pendingChanges) pending change(s)"
        }

        return tooltip
    }
}
