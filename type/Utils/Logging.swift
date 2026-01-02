import Foundation
import os.log

/// Centralized logging utility for the Type app
///
/// Usage:
/// ```swift
/// Logger.general.debug("Something happened")
/// Logger.window.info("Opened window: \(id)")
/// Logger.document.logError("Failed to save", error: error)
/// ```
enum Logger {
    // MARK: - Subsystems & Categories
    /// Base subsystem for all logs from this app
    private static let subsystem = Bundle.main.bundleIdentifier ?? "io.type.app"

    // Core categories
    static let app       = makeLogger(category: "app")
    static let window    = makeLogger(category: "window")
    static let document  = makeLogger(category: "document")
    static let file      = makeLogger(category: "file")
    static let editor    = makeLogger(category: "editor")
    static let outline   = makeLogger(category: "outline")
    static let character = makeLogger(category: "character")

    // Sync categories
    static let sync      = makeLogger(category: "sync")
    static let network   = makeLogger(category: "network")
    static let auth      = makeLogger(category: "auth")

    // Generic logger when you don't care about category
    static let general   = makeLogger(category: "general")

    // MARK: - Factory

    private static func makeLogger(category: String) -> os.Logger {
        return os.Logger(subsystem: subsystem, category: category)
    }
}

// MARK: - Convenience helpers

extension os.Logger {
    /// Log an error with an associated Swift Error
    func logError(_ message: String, error: Error) {
        let desc = error.localizedDescription
        self.error("\(message, privacy: .public): \(desc, privacy: .public)")
    }
    
    /// Log a warning message
    func logWarning(_ message: String) {
        self.warning("⚠️ \(message, privacy: .public)")
    }
    
    /// Log a debug message
    func logDebug(_ message: String) {
        self.debug("\(message, privacy: .public)")
    }
    
    /// Log an info message
    func logInfo(_ message: String) {
        self.info("\(message, privacy: .public)")
    }
}
