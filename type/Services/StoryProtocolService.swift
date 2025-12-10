//
//  StoryProtocolService.swift
//  type
//
//  Story Protocol integration service for IP protection
//

import SwiftUI
import Combine
import Foundation

// MARK: - Story Protocol Network
enum StoryProtocolNetwork: String, CaseIterable {
    case mainnet = "Story Protocol Mainnet"
    case testnet = "Story Protocol Testnet"
    
    var rpcURL: String {
        switch self {
        case .mainnet:
            return "https://rpc.story.foundation"
        case .testnet:
            return "https://testnet.storyrpc.io"
        }
    }
    
    var explorerURL: String {
        switch self {
        case .mainnet:
            return "https://explorer.story.foundation"
        case .testnet:
            return "https://testnet.storyscan.xyz"
        }
    }
    
    var chainId: Int {
        switch self {
        case .mainnet:
            return 1516 // Story Protocol Mainnet Chain ID
        case .testnet:
            return 1513 // Story Protocol Testnet Chain ID
        }
    }
}

// MARK: - Connection Status
enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
    case error(String)
    
    var icon: String {
        switch self {
        case .disconnected:
            return "bolt.slash"
        case .connecting:
            return "bolt.horizontal.circle"
        case .connected:
            return "bolt.fill"
        case .error:
            return "exclamationmark.triangle"
        }
    }
    
    var color: Color {
        switch self {
        case .disconnected:
            return .secondary
        case .connecting:
            return .orange
        case .connected:
            return .green
        case .error:
            return .red
        }
    }
    
    var displayText: String {
        switch self {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        case .error(let message):
            return "Error: \(message)"
        }
    }
}

// MARK: - IP Asset
struct IPAsset: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let ipId: String
    let txHash: String
    let timestamp: Date
    let network: String
    let contentHash: String
    let metadataURI: String?
    
    var explorerURL: String {
        if network == StoryProtocolNetwork.mainnet.rawValue {
            return "\(StoryProtocolNetwork.mainnet.explorerURL)/tx/\(txHash)"
        } else {
            return "\(StoryProtocolNetwork.testnet.explorerURL)/tx/\(txHash)"
        }
    }
}

// MARK: - Protection Status
enum ProtectionStatus {
    case unprotected
    case processing
    case protected(IPAsset)
    case failed(String)
    
    var isProtected: Bool {
        if case .protected = self {
            return true
        }
        return false
    }
    
    var displayText: String {
        switch self {
        case .unprotected:
            return "Not Protected"
        case .processing:
            return "Processing..."
        case .protected(let asset):
            return "Protected - IP ID: \(asset.ipId.prefix(10))..."
        case .failed(let error):
            return "Failed: \(error)"
        }
    }
}

// MARK: - Story Protocol Service
@MainActor
class StoryProtocolService: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedNetwork: StoryProtocolNetwork = .testnet
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var protectionStatus: ProtectionStatus = .unprotected
    @Published var walletAddress: String?
    @Published var protectedAssets: [IPAsset] = []
    @Published var isProcessing: Bool = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    
    // UserDefaults Keys
    private let networkKey = "StoryProtocol.SelectedNetwork"
    private let walletAddressKey = "StoryProtocol.WalletAddress"
    private let protectedAssetsKey = "StoryProtocol.ProtectedAssets"
    
    // MARK: - Initialization
    init() {
        loadPersistedData()
        setupNetworkObserver()
    }
    
    // MARK: - Public Methods
    
    /// Connect to the selected Story Protocol network
    func connect() async {
        connectionStatus = .connecting
        
        do {
            // Simulate network connection with delay
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            // In a real implementation, you would:
            // 1. Initialize Web3 provider with the RPC URL
            // 2. Check network connectivity
            // 3. Verify chain ID
            // 4. Get wallet connection if available
            
            connectionStatus = .connected
            
            // Load protected assets for this network
            loadProtectedAssets()
        } catch {
            connectionStatus = .error("Failed to connect: \(error.localizedDescription)")
        }
    }
    
    /// Disconnect from the current network
    func disconnect() {
        connectionStatus = .disconnected
        walletAddress = nil
    }
    
    /// Switch to a different network
    func switchNetwork(_ network: StoryProtocolNetwork) async {
        selectedNetwork = network
        userDefaults.set(network.rawValue, forKey: networkKey)
        
        if case .connected = connectionStatus {
            await connect()
        }
    }
    
    /// Protect screenplay content as IP on Story Protocol
    func protectScreenplay(title: String, content: String, author: String) async -> Result<IPAsset, Error> {
        isProcessing = true
        protectionStatus = .processing
        
        defer {
            isProcessing = false
        }
        
        do {
            // Ensure we're connected
            guard case .connected = connectionStatus else {
                throw StoryProtocolError.notConnected
            }
            
            // Simulate IP registration process
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            // In a real implementation, you would:
            // 1. Create metadata JSON with screenplay details
            // 2. Upload metadata to IPFS
            // 3. Calculate content hash
            // 4. Call Story Protocol smart contract to register IP
            // 5. Wait for transaction confirmation
            // 6. Get IP ID from the transaction
            
            let ipAsset = IPAsset(
                id: UUID().uuidString,
                name: title,
                description: "Screenplay by \(author)",
                ipId: generateMockIPID(),
                txHash: generateMockTxHash(),
                timestamp: Date(),
                network: selectedNetwork.rawValue,
                contentHash: generateContentHash(content),
                metadataURI: "ipfs://QmExample\(Int.random(in: 1000...9999))"
            )
            
            // Save the protected asset
            protectedAssets.append(ipAsset)
            saveProtectedAssets()
            
            protectionStatus = .protected(ipAsset)
            
            return .success(ipAsset)
        } catch {
            protectionStatus = .failed(error.localizedDescription)
            return .failure(error)
        }
    }
    
    /// Get protection status for current document
    func checkProtectionStatus(contentHash: String) -> IPAsset? {
        return protectedAssets.first { $0.contentHash == contentHash }
    }
    
    /// Remove a protected asset (for testing/development)
    func removeProtectedAsset(_ asset: IPAsset) {
        protectedAssets.removeAll { $0.id == asset.id }
        saveProtectedAssets()
        
        if case .protected(let currentAsset) = protectionStatus, currentAsset.id == asset.id {
            protectionStatus = .unprotected
        }
    }
    
    // MARK: - Private Methods
    
    private func setupNetworkObserver() {
        $selectedNetwork
            .sink { [weak self] _ in
                self?.disconnect()
            }
            .store(in: &cancellables)
    }
    
    private func loadPersistedData() {
        // Load selected network
        if let networkRaw = userDefaults.string(forKey: networkKey),
           let network = StoryProtocolNetwork(rawValue: networkRaw) {
            selectedNetwork = network
        }
        
        // Load wallet address
        walletAddress = userDefaults.string(forKey: walletAddressKey)
        
        // Load protected assets
        loadProtectedAssets()
    }
    
    private func loadProtectedAssets() {
        if let data = userDefaults.data(forKey: protectedAssetsKey),
           let assets = try? JSONDecoder().decode([IPAsset].self, from: data) {
            protectedAssets = assets.filter { $0.network == selectedNetwork.rawValue }
        }
    }
    
    private func saveProtectedAssets() {
        // Load all assets first
        var allAssets: [IPAsset] = []
        if let data = userDefaults.data(forKey: protectedAssetsKey),
           let assets = try? JSONDecoder().decode([IPAsset].self, from: data) {
            allAssets = assets
        }
        
        // Remove old assets for current network and add new ones
        allAssets.removeAll { $0.network == selectedNetwork.rawValue }
        allAssets.append(contentsOf: protectedAssets)
        
        // Save
        if let data = try? JSONEncoder().encode(allAssets) {
            userDefaults.set(data, forKey: protectedAssetsKey)
        }
    }
    
    private func generateContentHash(_ content: String) -> String {
        // In real implementation, use SHA-256 or similar
        let hash = content.data(using: .utf8)?.base64EncodedString() ?? ""
        return "0x" + String(hash.prefix(64).map { String(format: "%02x", $0.asciiValue ?? 0) }.joined())
    }
    
    private func generateMockIPID() -> String {
        return "0x" + (0..<40).map { _ in String(format: "%x", Int.random(in: 0...15)) }.joined()
    }
    
    private func generateMockTxHash() -> String {
        return "0x" + (0..<64).map { _ in String(format: "%x", Int.random(in: 0...15)) }.joined()
    }
    
    // MARK: - Cleanup
    
    /// Cleanup method for proper resource release
    func cleanup() {
        Logger.app.debug("StoryProtocolService cleanup")
        cancellables.removeAll()
        disconnect()
    }
}

// MARK: - Story Protocol Error
enum StoryProtocolError: LocalizedError {
    case notConnected
    case invalidNetwork
    case walletNotConnected
    case transactionFailed(String)
    case metadataUploadFailed
    
    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "Not connected to Story Protocol network"
        case .invalidNetwork:
            return "Invalid network selected"
        case .walletNotConnected:
            return "Wallet not connected"
        case .transactionFailed(let reason):
            return "Transaction failed: \(reason)"
        case .metadataUploadFailed:
            return "Failed to upload metadata"
        }
    }
}

