import Foundation
import AuthenticationServices

// MARK: - Google OAuth Service
/// Handles Google OAuth authentication flow
@MainActor
class GoogleOAuthService: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticating: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private var authSession: ASWebAuthenticationSession?
    private var continuation: CheckedContinuation<String, Error>?

    // OAuth configuration
    // Note: These should match your type-web Google OAuth configuration
    private let clientId = "YOUR_GOOGLE_CLIENT_ID" // TODO: Configure from environment
    private let redirectURI = "typeapp://auth/google/callback"
    private let scope = "openid email profile"

    // MARK: - Public Methods

    /// Start Google OAuth flow
    func signIn() async throws -> String {
        isAuthenticating = true
        errorMessage = nil

        defer { isAuthenticating = false }

        Logger.auth.info("Starting Google OAuth flow")

        // Build authorization URL
        guard let authURL = buildAuthorizationURL() else {
            Logger.auth.error("Failed to build Google authorization URL")
            throw OAuthError.invalidURL
        }

        // Start web authentication session
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            self.continuation = continuation

            authSession = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "typeapp"
            ) { [weak self] callbackURL, error in
                self?.handleCallback(callbackURL: callbackURL, error: error)
            }

            authSession?.presentationContextProvider = self
            authSession?.prefersEphemeralWebBrowserSession = false

            if authSession?.start() == false {
                Logger.auth.error("Failed to start Google OAuth session")
                continuation.resume(throwing: OAuthError.sessionFailed)
            }
        }
    }

    // MARK: - Private Methods

    private func buildAuthorizationURL() -> URL? {
        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")

        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "prompt", value: "consent")
        ]

        return components?.url
    }

    private func handleCallback(callbackURL: URL?, error: Error?) {
        if let error = error {
            Logger.auth.error("Google OAuth callback error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            continuation?.resume(throwing: OAuthError.authorizationFailed(error.localizedDescription))
            continuation = nil
            return
        }

        guard let callbackURL = callbackURL else {
            Logger.auth.error("No callback URL received from Google OAuth")
            errorMessage = "No callback URL received"
            continuation?.resume(throwing: OAuthError.noCallback)
            continuation = nil
            return
        }

        Logger.auth.debug("Received Google OAuth callback: \(callbackURL.absoluteString)")

        // Extract authorization code from callback URL
        guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            Logger.auth.error("No authorization code in Google OAuth callback")
            errorMessage = "No authorization code received"
            continuation?.resume(throwing: OAuthError.noAuthorizationCode)
            continuation = nil
            return
        }

        Logger.auth.info("Google OAuth authorization code received")

        // Return the authorization code
        // The AuthService will exchange this for a JWT token with the type-web API
        continuation?.resume(returning: code)
        continuation = nil
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
extension GoogleOAuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return NSApplication.shared.windows.first ?? ASPresentationAnchor()
    }
}

// MARK: - OAuth Error
enum OAuthError: LocalizedError {
    case invalidURL
    case sessionFailed
    case authorizationFailed(String)
    case noCallback
    case noAuthorizationCode
    case tokenExchangeFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid OAuth URL"
        case .sessionFailed:
            return "Failed to start OAuth session"
        case .authorizationFailed(let message):
            return "Authorization failed: \(message)"
        case .noCallback:
            return "No callback received from OAuth provider"
        case .noAuthorizationCode:
            return "No authorization code received"
        case .tokenExchangeFailed(let message):
            return "Token exchange failed: \(message)"
        }
    }
}
