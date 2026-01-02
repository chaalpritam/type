import Foundation
import AuthenticationServices

// MARK: - Apple Sign In Service
/// Handles Sign in with Apple authentication flow
@MainActor
class AppleSignInService: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticating: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private var continuation: CheckedContinuation<String, Error>?

    // MARK: - Public Methods

    /// Start Sign in with Apple flow
    func signIn() async throws -> String {
        isAuthenticating = true
        errorMessage = nil

        defer { isAuthenticating = false }

        Logger.auth.info("Starting Sign in with Apple flow")

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            self.continuation = continuation

            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            Logger.auth.error("Invalid Apple ID credential")
            errorMessage = "Invalid credential"
            continuation?.resume(throwing: OAuthError.authorizationFailed("Invalid credential"))
            continuation = nil
            return
        }

        Logger.auth.info("Sign in with Apple succeeded")

        // Extract identity token
        guard let identityTokenData = appleIDCredential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            Logger.auth.error("No identity token from Apple Sign In")
            errorMessage = "No identity token received"
            continuation?.resume(throwing: OAuthError.noAuthorizationCode)
            continuation = nil
            return
        }

        Logger.auth.debug("Apple identity token received")

        // Return the identity token
        // The AuthService will send this to type-web API to exchange for JWT
        continuation?.resume(returning: identityToken)
        continuation = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Logger.auth.error("Sign in with Apple failed: \(error.localizedDescription)")

        errorMessage = error.localizedDescription
        continuation?.resume(throwing: OAuthError.authorizationFailed(error.localizedDescription))
        continuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return NSApplication.shared.windows.first ?? ASPresentationAnchor()
    }
}
