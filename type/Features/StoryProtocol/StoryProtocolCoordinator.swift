//
//  StoryProtocolCoordinator.swift
//  type
//
//  Story Protocol coordinator for managing IP protection UI and logic
//

import SwiftUI
import Combine

// MARK: - Story Protocol Coordinator
@MainActor
class StoryProtocolCoordinator: ObservableObject {
    // MARK: - Published Properties
    @Published var showProtectionDialog: Bool = false
    @Published var showNetworkSelector: Bool = false
    @Published var showProtectedAssets: Bool = false
    @Published var showConnectionDialog: Bool = false
    
    // MARK: - Services
    let storyProtocolService: StoryProtocolService
    let documentService: DocumentService
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(storyProtocolService: StoryProtocolService, documentService: DocumentService) {
        self.storyProtocolService = storyProtocolService
        self.documentService = documentService
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// Show the IP protection dialog
    func showProtect() {
        // Check if connected first
        if case .connected = storyProtocolService.connectionStatus {
            showProtectionDialog = true
        } else {
            showConnectionDialog = true
        }
    }
    
    /// Connect to Story Protocol network
    func connect() {
        Task {
            await storyProtocolService.connect()
        }
    }
    
    /// Disconnect from Story Protocol network
    func disconnect() {
        storyProtocolService.disconnect()
    }
    
    /// Switch network
    func switchNetwork(_ network: StoryProtocolNetwork) {
        Task {
            await storyProtocolService.switchNetwork(network)
        }
    }
    
    /// Protect current screenplay
    func protectCurrentScreenplay(title: String, author: String) async -> Bool {
        guard let document = documentService.currentDocument else {
            return false
        }
        
        let result = await storyProtocolService.protectScreenplay(
            title: title,
            content: document.content,
            author: author
        )
        
        switch result {
        case .success:
            showProtectionDialog = false
            return true
        case .failure:
            return false
        }
    }
    
    /// Create the main view
    func createView() -> some View {
        StoryProtocolView(coordinator: self)
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Monitor document changes
        documentService.$currentDocument
            .sink { [weak self] _ in
                self?.updateDocument()
            }
            .store(in: &cancellables)
    }
    
    private func updateDocument() {
        // Check if current document is already protected
        guard let document = documentService.currentDocument else {
            storyProtocolService.protectionStatus = .unprotected
            return
        }
        
        let contentHash = generateContentHash(document.content)
        if let asset = storyProtocolService.checkProtectionStatus(contentHash: contentHash) {
            storyProtocolService.protectionStatus = .protected(asset)
        } else {
            storyProtocolService.protectionStatus = .unprotected
        }
    }
    
    private func generateContentHash(_ content: String) -> String {
        // Simple hash generation (in real implementation, use SHA-256)
        let hash = content.data(using: .utf8)?.base64EncodedString() ?? ""
        return "0x" + String(hash.prefix(64).map { String(format: "%02x", $0.asciiValue ?? 0) }.joined())
    }
    
    // MARK: - Cleanup
    
    /// Cleanup method for proper resource release
    func cleanup() {
        Logger.app.debug("StoryProtocolCoordinator cleanup")
        cancellables.removeAll()
    }
}

