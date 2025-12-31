//
//  ErrorHandling.swift
//  type
//
//  User-friendly error handling with recovery suggestions
//

import Foundation
import SwiftUI
import AppKit

// MARK: - App Error
enum AppError: LocalizedError {
    // File operations
    case fileNotFound(path: String)
    case fileReadError(path: String, reason: String)
    case fileWriteError(path: String, reason: String)
    case filePermissionDenied(path: String)
    case fileTooLarge(size: Int64, maxSize: Int64)

    // Document operations
    case documentCorrupted(reason: String)
    case documentEmpty
    case invalidFormat(format: String)
    case parsingError(line: Int, reason: String)

    // Export operations
    case exportFailed(format: String, reason: String)
    case exportCancelled

    // Collaboration errors
    case syncFailed(reason: String)
    case connectionLost
    case conflictDetected

    // Story Protocol errors
    case blockchainConnectionFailed
    case walletNotConnected
    case transactionFailed(reason: String)

    // General errors
    case unknown(Error)
    case operationCancelled
    case networkError(reason: String)

    var errorDescription: String? {
        switch self {
        // File operations
        case .fileNotFound(let path):
            return "File Not Found"
        case .fileReadError(let path, _):
            return "Cannot Read File"
        case .fileWriteError(let path, _):
            return "Cannot Save File"
        case .filePermissionDenied:
            return "Permission Denied"
        case .fileTooLarge(let size, let maxSize):
            return "File Too Large"

        // Document operations
        case .documentCorrupted:
            return "Document Corrupted"
        case .documentEmpty:
            return "Document Empty"
        case .invalidFormat:
            return "Invalid Format"
        case .parsingError:
            return "Parsing Error"

        // Export operations
        case .exportFailed(let format, _):
            return "\(format) Export Failed"
        case .exportCancelled:
            return "Export Cancelled"

        // Collaboration errors
        case .syncFailed:
            return "Sync Failed"
        case .connectionLost:
            return "Connection Lost"
        case .conflictDetected:
            return "Conflict Detected"

        // Story Protocol errors
        case .blockchainConnectionFailed:
            return "Blockchain Connection Failed"
        case .walletNotConnected:
            return "Wallet Not Connected"
        case .transactionFailed:
            return "Transaction Failed"

        // General errors
        case .unknown:
            return "Unexpected Error"
        case .operationCancelled:
            return "Operation Cancelled"
        case .networkError:
            return "Network Error"
        }
    }

    var failureReason: String? {
        switch self {
        // File operations
        case .fileNotFound(let path):
            return "The file '\(URL(fileURLWithPath: path).lastPathComponent)' could not be found at the expected location."
        case .fileReadError(_, let reason):
            return reason
        case .fileWriteError(_, let reason):
            return reason
        case .filePermissionDenied(let path):
            return "You don't have permission to access '\(URL(fileURLWithPath: path).lastPathComponent)'."
        case .fileTooLarge(let size, let maxSize):
            return "The file size (\(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))) exceeds the maximum allowed size (\(ByteCountFormatter.string(fromByteCount: maxSize, countStyle: .file)))."

        // Document operations
        case .documentCorrupted(let reason):
            return reason
        case .documentEmpty:
            return "The document contains no content."
        case .invalidFormat(let format):
            return "The file format '\(format)' is not supported or the file is corrupted."
        case .parsingError(let line, let reason):
            return "Error at line \(line): \(reason)"

        // Export operations
        case .exportFailed(_, let reason):
            return reason
        case .exportCancelled:
            return "The export operation was cancelled by the user."

        // Collaboration errors
        case .syncFailed(let reason):
            return reason
        case .connectionLost:
            return "The connection to the collaboration server was lost."
        case .conflictDetected:
            return "Changes made by another user conflict with your changes."

        // Story Protocol errors
        case .blockchainConnectionFailed:
            return "Could not connect to the blockchain network."
        case .walletNotConnected:
            return "Please connect your wallet before registering IP."
        case .transactionFailed(let reason):
            return reason

        // General errors
        case .unknown(let error):
            return error.localizedDescription
        case .operationCancelled:
            return "The operation was cancelled."
        case .networkError(let reason):
            return reason
        }
    }

    var recoverySuggestion: String? {
        switch self {
        // File operations
        case .fileNotFound:
            return "Make sure the file exists and hasn't been moved or deleted. Try opening it again using File > Open."
        case .fileReadError:
            return "Check that the file isn't corrupted and that you have permission to read it. Try copying it to a different location."
        case .fileWriteError:
            return "Make sure you have enough disk space and permission to save at this location. Try saving to a different folder."
        case .filePermissionDenied:
            return "Check the file permissions in Finder, or try saving a copy to a different location."
        case .fileTooLarge:
            return "Try splitting the document into multiple files or removing unnecessary content."

        // Document operations
        case .documentCorrupted:
            return "Try opening a backup or an earlier version of the file. If this persists, you may need to manually recover the content."
        case .documentEmpty:
            return "Start writing to create content in your screenplay."
        case .invalidFormat:
            return "Make sure you're opening a valid Fountain (.fountain) file. Try creating a new document and copying the content."
        case .parsingError:
            return "Check the syntax at the indicated line and make sure it follows Fountain formatting rules."

        // Export operations
        case .exportFailed:
            return "Try exporting again or choose a different format. Make sure you have write permissions for the destination folder."
        case .exportCancelled:
            return nil

        // Collaboration errors
        case .syncFailed:
            return "Check your internet connection and try syncing again. Your local changes are saved."
        case .connectionLost:
            return "Reconnect to continue collaborating. Your local changes are preserved."
        case .conflictDetected:
            return "Review both versions and manually merge the changes, or keep your version and discard remote changes."

        // Story Protocol errors
        case .blockchainConnectionFailed:
            return "Check your internet connection and make sure you've selected the correct network."
        case .walletNotConnected:
            return "Click 'Connect Wallet' and approve the connection in your wallet app."
        case .transactionFailed:
            return "Make sure you have enough funds for gas fees and try again."

        // General errors
        case .unknown:
            return "Try the operation again. If the problem persists, restart the application."
        case .operationCancelled:
            return nil
        case .networkError:
            return "Check your internet connection and try again."
        }
    }
}

// MARK: - Error Alert Manager
class ErrorAlertManager: ObservableObject {
    @Published var currentError: AppError?
    @Published var showError = false

    func show(_ error: AppError) {
        currentError = error
        showError = true
    }

    func show(_ error: Error) {
        if let appError = error as? AppError {
            show(appError)
        } else {
            show(.unknown(error))
        }
    }

    func dismiss() {
        showError = false
        currentError = nil
    }
}

// MARK: - Error Alert View
struct ErrorAlertView: View {
    @ObservedObject var manager: ErrorAlertManager
    var onRetry: (() -> Void)?
    var onDismiss: (() -> Void)?

    var body: some View {
        EmptyView()
            .alert(
                manager.currentError?.errorDescription ?? "Error",
                isPresented: $manager.showError,
                presenting: manager.currentError
            ) { error in
                // Retry button if retry action is provided
                if let onRetry = onRetry, error.canRetry {
                    Button("Retry") {
                        manager.dismiss()
                        onRetry()
                    }
                }

                // Always show OK button
                Button("OK") {
                    manager.dismiss()
                    onDismiss?()
                }

                // Show help for certain errors
                if error.hasHelp {
                    Button("Help") {
                        showHelp(for: error)
                        manager.dismiss()
                    }
                }
            } message: { error in
                VStack(alignment: .leading, spacing: 8) {
                    if let reason = error.failureReason {
                        Text(reason)
                    }

                    if let suggestion = error.recoverySuggestion {
                        Text("\n\(suggestion)")
                            .font(.callout)
                    }
                }
            }
    }

    private func showHelp(for error: AppError) {
        // Open help documentation for the specific error
        let helpURL: String
        switch error {
        case .parsingError:
            helpURL = "https://fountain.io/syntax"
        case .exportFailed:
            helpURL = "https://docs.typeapp.com/export"
        case .blockchainConnectionFailed, .walletNotConnected, .transactionFailed:
            helpURL = "https://docs.storyprotocol.xyz"
        default:
            helpURL = "https://docs.typeapp.com/troubleshooting"
        }

        if let url = URL(string: helpURL) {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - App Error Extensions
extension AppError {
    var canRetry: Bool {
        switch self {
        case .fileReadError, .fileWriteError, .exportFailed, .syncFailed, .connectionLost, .blockchainConnectionFailed, .transactionFailed, .networkError:
            return true
        default:
            return false
        }
    }

    var hasHelp: Bool {
        switch self {
        case .parsingError, .exportFailed, .blockchainConnectionFailed, .walletNotConnected, .transactionFailed, .documentCorrupted:
            return true
        default:
            return false
        }
    }
}

// MARK: - Error Banner View (Non-blocking)
struct ErrorBannerView: View {
    let error: AppError
    let onDismiss: () -> Void
    let onRetry: (() -> Void)?

    @State private var isVisible = true

    var body: some View {
        if isVisible {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text(error.errorDescription ?? "Error")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    if let reason = error.failureReason {
                        Text(reason)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                if let onRetry = onRetry, error.canRetry {
                    Button("Retry") {
                        onRetry()
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .overlay(
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 4),
                alignment: .leading
            )
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private func dismiss() {
        withAnimation {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Toast Notification (Success/Info)
struct ToastView: View {
    enum ToastType {
        case success
        case info
        case warning

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            }
        }

        var color: Color {
            switch self {
            case .success: return .green
            case .info: return .blue
            case .warning: return .orange
            }
        }
    }

    let type: ToastType
    let message: String
    let onDismiss: () -> Void

    @State private var isVisible = true

    var body: some View {
        if isVisible {
            HStack(spacing: 12) {
                Image(systemName: type.icon)
                    .foregroundColor(type.color)

                Text(message)
                    .font(.subheadline)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(type.color.opacity(0.1))
            .overlay(
                Rectangle()
                    .fill(type.color)
                    .frame(width: 4),
                alignment: .leading
            )
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                // Auto-dismiss after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    dismiss()
                }
            }
        }
    }

    private func dismiss() {
        withAnimation {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Toast Manager
class ToastManager: ObservableObject {
    @Published var currentToast: (type: ToastView.ToastType, message: String)?

    func show(_ type: ToastView.ToastType, message: String) {
        currentToast = (type, message)
    }

    func success(_ message: String) {
        show(.success, message: message)
    }

    func info(_ message: String) {
        show(.info, message: message)
    }

    func warning(_ message: String) {
        show(.warning, message: message)
    }

    func dismiss() {
        currentToast = nil
    }
}
