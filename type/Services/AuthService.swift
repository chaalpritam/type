import Foundation
import Combine

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String?
    let image: String?
    let provider: AuthProvider

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email, name, image, provider
    }
}

// MARK: - Auth Provider
enum AuthProvider: String, Codable {
    case credentials
    case google
    case apple
}

// MARK: - Auth Error
enum AuthError: LocalizedError, Equatable {
    case invalidCredentials
    case networkError(Error)
    case invalidResponse
    case tokenExpired
    case notAuthenticated
    case oauthFailed(String)
    case unknown(Error)

    static func == (lhs: AuthError, rhs: AuthError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidCredentials, .invalidCredentials),
             (.invalidResponse, .invalidResponse),
             (.tokenExpired, .tokenExpired),
             (.notAuthenticated, .notAuthenticated):
            return true
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.oauthFailed(let lhsMsg), .oauthFailed(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.unknown(let lhsError), .unknown(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .tokenExpired:
            return "Session expired. Please sign in again."
        case .notAuthenticated:
            return "Not authenticated"
        case .oauthFailed(let message):
            return "OAuth failed: \(message)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Auth Request/Response Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let name: String
}

struct AuthResponse: Codable {
    let success: Bool
    let data: AuthData?
    let error: ErrorDetail?

    struct AuthData: Codable {
        let token: String
        let user: User
        let expiresAt: Date?
    }

    struct ErrorDetail: Codable {
        let code: String
        let message: String
    }
}

// MARK: - Auth Service
/// Authentication service handling login, logout, and session management
@MainActor
class AuthService: ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var authError: AuthError?
    @Published var isLoading: Bool = false

    // MARK: - Private Properties
    private let networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    private let tokenExpirationKey = "type.jwt.expiresAt"

    // MARK: - Initialization
    init(networkService: NetworkService) {
        self.networkService = networkService
        checkExistingSession()
    }

    // MARK: - Public Methods

    /// Check if there's an existing valid session
    func checkExistingSession() {
        guard let token = networkService.getJWTToken() else {
            Logger.auth.info("No existing session found")
            isAuthenticated = false
            return
        }

        // Check token expiration
        if isTokenExpired() {
            Logger.auth.warning("Token expired")
            logout()
            return
        }

        // Try to fetch current user to validate token
        Task {
            do {
                try await fetchCurrentUser()
            } catch {
                Logger.auth.error("Session validation failed: \(error.localizedDescription)")
                logout()
            }
        }
    }

    /// Sign in with email and password
    func signIn(email: String, password: String) async throws {
        isLoading = true
        authError = nil

        defer { isLoading = false }

        do {
            Logger.auth.info("Signing in with email: \(email)")

            let request = LoginRequest(email: email, password: password)
            let response: AuthResponse = try await networkService.request(
                "/api/auth/signin",
                method: .POST,
                body: request
            )

            guard response.success, let data = response.data else {
                let errorMessage = response.error?.message ?? "Sign in failed"
                Logger.auth.error("Sign in failed: \(errorMessage)")
                throw AuthError.invalidCredentials
            }

            // Store token
            networkService.storeJWTToken(data.token)

            // Store expiration
            if let expiresAt = data.expiresAt {
                let expirationTimestamp = expiresAt.timeIntervalSince1970
                networkService.storeInKeychain(
                    key: tokenExpirationKey,
                    value: String(expirationTimestamp)
                )
            }

            // Store user email
            networkService.storeInKeychain(key: "type.user.email", value: email)

            // Update state
            currentUser = data.user
            isAuthenticated = true

            Logger.auth.info("Sign in successful")

        } catch let error as NetworkError {
            Logger.auth.error("Network error during sign in: \(error.localizedDescription)")
            authError = .networkError(error)
            throw error
        } catch {
            Logger.auth.error("Unknown error during sign in: \(error.localizedDescription)")
            authError = .unknown(error)
            throw error
        }
    }

    /// Register a new account
    func register(email: String, password: String, name: String) async throws {
        isLoading = true
        authError = nil

        defer { isLoading = false }

        do {
            Logger.auth.info("Registering new account: \(email)")

            let request = RegisterRequest(email: email, password: password, name: name)
            let response: AuthResponse = try await networkService.request(
                "/api/auth/register",
                method: .POST,
                body: request
            )

            guard response.success, let data = response.data else {
                let errorMessage = response.error?.message ?? "Registration failed"
                Logger.auth.error("Registration failed: \(errorMessage)")
                throw AuthError.invalidResponse
            }

            // Store token
            networkService.storeJWTToken(data.token)

            // Store expiration
            if let expiresAt = data.expiresAt {
                let expirationTimestamp = expiresAt.timeIntervalSince1970
                networkService.storeInKeychain(
                    key: tokenExpirationKey,
                    value: String(expirationTimestamp)
                )
            }

            // Store user email
            networkService.storeInKeychain(key: "type.user.email", value: email)

            // Update state
            currentUser = data.user
            isAuthenticated = true

            Logger.auth.info("Registration successful")

        } catch let error as NetworkError {
            Logger.auth.error("Network error during registration: \(error.localizedDescription)")
            authError = .networkError(error)
            throw error
        } catch {
            Logger.auth.error("Unknown error during registration: \(error.localizedDescription)")
            authError = .unknown(error)
            throw error
        }
    }

    /// Sign in with OAuth (Google or Apple)
    func signInWithOAuth(provider: AuthProvider, token: String) async throws {
        isLoading = true
        authError = nil

        defer { isLoading = false }

        do {
            Logger.auth.info("Signing in with OAuth provider: \(provider.rawValue)")

            // The OAuth flow will be completed by OAuthCoordinator
            // This method receives the final JWT token after OAuth completes

            // Store token
            networkService.storeJWTToken(token)

            // Calculate expiration (7 days from now)
            let expiresAt = Date().addingTimeInterval(7 * 24 * 60 * 60)
            let expirationTimestamp = expiresAt.timeIntervalSince1970
            networkService.storeInKeychain(
                key: tokenExpirationKey,
                value: String(expirationTimestamp)
            )

            // Fetch current user
            try await fetchCurrentUser()

            Logger.auth.info("OAuth sign in successful")

        } catch {
            Logger.auth.error("OAuth sign in failed: \(error.localizedDescription)")
            authError = .oauthFailed(error.localizedDescription)
            throw error
        }
    }

    /// Logout
    func logout() {
        Logger.auth.info("Logging out")

        // Clear token from Keychain
        networkService.deleteJWTToken()
        networkService.deleteFromKeychain(key: tokenExpirationKey)
        networkService.deleteFromKeychain(key: "type.user.email")

        // Clear state
        currentUser = nil
        isAuthenticated = false
        authError = nil

        Logger.auth.info("Logout complete")
    }

    /// Fetch current user profile
    func fetchCurrentUser() async throws {
        Logger.auth.debug("Fetching current user")

        struct UserResponse: Codable {
            let success: Bool
            let data: User?
        }

        let response: UserResponse = try await networkService.authenticatedRequest("/api/auth/me")

        guard response.success, let user = response.data else {
            throw AuthError.invalidResponse
        }

        currentUser = user
        isAuthenticated = true

        Logger.auth.debug("Current user fetched: \(user.email)")
    }

    /// Check if token is expired
    func isTokenExpired() -> Bool {
        guard let expirationString = networkService.getFromKeychain(key: tokenExpirationKey),
              let expirationTimestamp = Double(expirationString) else {
            return true
        }

        let expirationDate = Date(timeIntervalSince1970: expirationTimestamp)
        return Date() >= expirationDate
    }

    /// Get stored email for pre-filling login form
    func getStoredEmail() -> String? {
        return networkService.getFromKeychain(key: "type.user.email")
    }

    // MARK: - Cleanup

    func cleanup() {
        Logger.auth.info("AuthService cleanup")
        cancellables.removeAll()
    }
}
