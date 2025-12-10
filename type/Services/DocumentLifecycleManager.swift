//
//  DocumentLifecycleManager.swift
//  type
//
//  Simplified document lifecycle management
//  Main cleanup is now handled by SafeWindowDelegate in DocumentWindowView.swift
//

import SwiftUI
import AppKit
import Combine

// MARK: - Document Lifecycle Manager
/// Simplified manager - most cleanup is now handled by SafeWindowDelegate
@MainActor
final class DocumentLifecycleManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = DocumentLifecycleManager()
    
    // MARK: - Published Properties
    @Published private(set) var isDocumentLoading: Bool = false
    
    // MARK: - Initialization
    private init() {
        Logger.document.info("DocumentLifecycleManager initialized")
    }
    
    // MARK: - Public Methods
    
    /// Set document loading state
    func setDocumentLoading(_ loading: Bool) {
        isDocumentLoading = loading
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let documentDidOpen = Notification.Name("documentDidOpen")
    static let documentDidClose = Notification.Name("documentDidClose")
    static let allDocumentsClosed = Notification.Name("allDocumentsClosed")
    static let windowWillClose = Notification.Name("windowWillClose")
}
