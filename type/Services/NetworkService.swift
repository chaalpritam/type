import Foundation
import Security

// MARK: - HTTP Method
enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

// MARK: - Network Error
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case httpError(Int, String)
    case networkUnavailable
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case timeout
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .httpError(let code, let message):
            return "HTTP \(code): \(message)"
        case .networkUnavailable:
            return "Network unavailable. Please check your connection."
        case .unauthorized:
            return "Unauthorized. Please sign in again."
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error. Please try again later."
        case .timeout:
            return "Request timed out"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Network Service
/// Core network service for all API communication
@MainActor
class NetworkService: ObservableObject {
    // MARK: - Properties
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let keychainService = "com.type.auth"

    @Published var isOnline: Bool = true

    // MARK: - Initialization
    init(baseURL: String = "http://localhost:3000") {
        self.baseURL = baseURL

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)

        // Configure JSON decoder for ISO8601 dates
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // Configure JSON encoder for ISO8601 dates
        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        Logger.network.info("NetworkService initialized with baseURL: \(baseURL)")
    }

    // MARK: - Public Methods

    /// Make a generic HTTP request
    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .GET,
        body: (any Encodable)? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        let url = try buildURL(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Add headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        // Add body if present
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        Logger.network.debug("\(method.rawValue) \(endpoint)")

        return try await performRequest(request)
    }

    /// Make an authenticated request (includes JWT token)
    func authenticatedRequest<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .GET,
        body: (any Encodable)? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        guard let token = getJWTToken() else {
            Logger.network.error("No JWT token found for authenticated request")
            throw NetworkError.unauthorized
        }

        var authHeaders = headers ?? [:]
        authHeaders["Authorization"] = "Bearer \(token)"

        return try await request(endpoint, method: method, body: body, headers: authHeaders)
    }

    /// Make a request without expecting a decoded response (for void endpoints)
    func voidRequest(
        _ endpoint: String,
        method: HTTPMethod = .GET,
        body: (any Encodable)? = nil,
        headers: [String: String]? = nil
    ) async throws {
        let url = try buildURL(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        Logger.network.debug("\(method.rawValue) \(endpoint)")

        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }

    /// Make an authenticated void request
    func authenticatedVoidRequest(
        _ endpoint: String,
        method: HTTPMethod = .GET,
        body: (any Encodable)? = nil,
        headers: [String: String]? = nil
    ) async throws {
        guard let token = getJWTToken() else {
            throw NetworkError.unauthorized
        }

        var authHeaders = headers ?? [:]
        authHeaders["Authorization"] = "Bearer \(token)"

        try await voidRequest(endpoint, method: method, body: body, headers: authHeaders)
    }

    // MARK: - Private Methods

    private func buildURL(_ endpoint: String) throws -> URL {
        let urlString = endpoint.hasPrefix("http") ? endpoint : baseURL + endpoint
        guard let url = URL(string: urlString) else {
            Logger.network.error("Invalid URL: \(urlString)")
            throw NetworkError.invalidURL
        }
        return url
    }

    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)

            try validateResponse(response)

            // Log response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                Logger.network.debug("Response: \(responseString)")
            }

            do {
                let decoded = try decoder.decode(T.self, from: data)
                return decoded
            } catch {
                Logger.network.error("Decoding failed: \(error.localizedDescription)")
                throw NetworkError.decodingFailed(error)
            }

        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            Logger.network.error("URLError: \(error.localizedDescription)")
            throw mapURLError(error)
        } catch {
            Logger.network.error("Unknown error: \(error.localizedDescription)")
            throw NetworkError.unknown(error)
        }
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            return
        }

        Logger.network.debug("HTTP Status: \(httpResponse.statusCode)")

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError
        default:
            throw NetworkError.httpError(httpResponse.statusCode, HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
        }
    }

    private func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .networkUnavailable
        case .timedOut:
            return .timeout
        default:
            return .unknown(error)
        }
    }

    // MARK: - Keychain Methods

    /// Store JWT token in Keychain
    func storeJWTToken(_ token: String) {
        let key = "type.jwt.token"
        let data = token.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            Logger.network.info("JWT token stored in Keychain")
        } else {
            Logger.network.error("Failed to store JWT token: \(status)")
        }
    }

    /// Retrieve JWT token from Keychain
    func getJWTToken() -> String? {
        let key = "type.jwt.token"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    /// Delete JWT token from Keychain
    func deleteJWTToken() {
        let key = "type.jwt.token"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
        Logger.network.info("JWT token deleted from Keychain")
    }

    /// Store a generic string in Keychain
    func storeInKeychain(key: String, value: String) {
        let data = value.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    /// Retrieve a generic string from Keychain
    func getFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    /// Delete a generic value from Keychain
    func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Cleanup

    func cleanup() {
        Logger.network.info("NetworkService cleanup")
        session.invalidateAndCancel()
    }
}
