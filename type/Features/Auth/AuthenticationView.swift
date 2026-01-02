import SwiftUI

// MARK: - Authentication View
struct AuthenticationView: View {
    @ObservedObject var authService: AuthService
    @ObservedObject var oauthCoordinator: OAuthCoordinator
    @ObservedObject var syncCoordinator: SyncCoordinator

    var body: some View {
        Group {
            if authService.isAuthenticated, let user = authService.currentUser {
                // Authenticated - show user profile
                VStack(spacing: 20) {
                    // User avatar
                    if let imageURL = user.image, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                    }

                    // User info
                    VStack(spacing: 4) {
                        if let name = user.name {
                            Text(name)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }

                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(providerText(user.provider))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(4)
                    }

                    Divider()
                        .padding(.vertical, 8)

                    // Sync info
                    VStack(spacing: 8) {
                        HStack {
                            Text("Last sync:")
                                .foregroundColor(.secondary)
                            Spacer()
                            if let lastSync = syncCoordinator.lastSyncDate {
                                Text(lastSync, style: .relative)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Never")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .font(.caption)

                        HStack {
                            Text("Pending changes:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(syncCoordinator.pendingChanges)")
                                .foregroundColor(syncCoordinator.pendingChanges > 0 ? .orange : .secondary)
                        }
                        .font(.caption)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(8)

                    // Logout button
                    Button(action: handleLogout) {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(32)
                .frame(width: 400)

            } else {
                // Not authenticated - show login view
                LoginView(authService: authService, oauthCoordinator: oauthCoordinator)
            }
        }
    }

    // MARK: - Private Methods

    private func providerText(_ provider: AuthProvider) -> String {
        switch provider {
        case .credentials:
            return "Email"
        case .google:
            return "Google"
        case .apple:
            return "Apple"
        }
    }

    private func handleLogout() {
        authService.logout()
    }
}
