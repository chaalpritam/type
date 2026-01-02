import SwiftUI

// MARK: - Login View
struct LoginView: View {
    @ObservedObject var authService: AuthService
    @ObservedObject var oauthCoordinator: OAuthCoordinator

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var isRegisterMode: Bool = false
    @State private var name: String = ""

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)

                Text(isRegisterMode ? "Create Account" : "Sign In")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Sync your screenplays across devices")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 8)

            // Error message
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }

            // Email/Password Form
            VStack(spacing: 16) {
                // Name field (register only)
                if isRegisterMode {
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                }

                // Email field
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)

                // Password field
                HStack {
                    if showPassword {
                        TextField("Password", text: $password)
                            .textContentType(.password)
                    } else {
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                    }

                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(6)

                // Sign in/Register button
                Button(action: handleEmailAuth) {
                    if authService.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(isRegisterMode ? "Create Account" : "Sign In")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(authService.isLoading || !isFormValid)

                // Toggle register/login mode
                Button(action: { isRegisterMode.toggle() }) {
                    Text(isRegisterMode ? "Already have an account? Sign in" : "Don't have an account? Register")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            Divider()
                .padding(.vertical, 8)

            // OAuth Buttons
            VStack(spacing: 12) {
                Text("Or sign in with")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Google Sign In
                Button(action: handleGoogleSignIn) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .foregroundColor(.red)
                        Text("Sign in with Google")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(oauthCoordinator.isAuthenticating)

                // Apple Sign In
                Button(action: handleAppleSignIn) {
                    HStack {
                        Image(systemName: "applelogo")
                        Text("Sign in with Apple")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(oauthCoordinator.isAuthenticating)
            }
        }
        .padding(32)
        .frame(width: 400)
        .onAppear {
            // Pre-fill email if stored
            if let storedEmail = authService.getStoredEmail() {
                email = storedEmail
            }
        }
        .onChange(of: authService.authError) { error in
            errorMessage = error?.localizedDescription
        }
        .onChange(of: oauthCoordinator.errorMessage) { error in
            errorMessage = error
        }
    }

    // MARK: - Private Methods

    private var isFormValid: Bool {
        if isRegisterMode {
            return !email.isEmpty && !password.isEmpty && !name.isEmpty && password.count >= 6
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }

    private func handleEmailAuth() {
        errorMessage = nil

        Task {
            do {
                if isRegisterMode {
                    try await authService.register(email: email, password: password, name: name)
                } else {
                    try await authService.signIn(email: email, password: password)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func handleGoogleSignIn() {
        errorMessage = nil
        Task {
            await oauthCoordinator.signInWithGoogle()
        }
    }

    private func handleAppleSignIn() {
        errorMessage = nil
        Task {
            await oauthCoordinator.signInWithApple()
        }
    }
}
