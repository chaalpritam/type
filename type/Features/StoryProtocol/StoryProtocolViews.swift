//
//  StoryProtocolViews.swift
//  type
//
//  UI views for Story Protocol integration
//

import SwiftUI

// MARK: - Story Protocol Main View
struct StoryProtocolView: View {
    @ObservedObject var coordinator: StoryProtocolCoordinator
    
    var body: some View {
        VStack {
            Text("Story Protocol Integration")
                .font(.title)
            
            Spacer()
            
            // This view is primarily accessed through dialogs and toolbar
            // Can show protected assets list here if needed
            if coordinator.storyProtocolService.protectedAssets.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    
                    Text("No Protected Screenplays")
                        .font(.headline)
                    
                    Text("Protect your screenplay as IP on Story Protocol blockchain")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                ProtectedAssetsList(coordinator: coordinator)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Network Selector Menu
struct NetworkSelectorMenu: View {
    @ObservedObject var service: StoryProtocolService
    let onNetworkSelected: (StoryProtocolNetwork) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(StoryProtocolNetwork.allCases, id: \.self) { network in
                Button(action: {
                    onNetworkSelected(network)
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(network.rawValue)
                                .font(.system(size: 13, weight: .medium))
                            Text("Chain ID: \(network.chainId)")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if service.selectedNetwork == network {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(service.selectedNetwork == network ? Color(.controlColor) : Color.clear)
                }
                .buttonStyle(.plain)
                
                if network != StoryProtocolNetwork.allCases.last {
                    Divider()
                        .padding(.horizontal, 12)
                }
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .frame(width: 220)
    }
}

// MARK: - Connection Status Indicator
struct ConnectionStatusIndicator: View {
    let status: ConnectionStatus
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: status.icon)
                .font(.system(size: 11))
                .foregroundColor(status.color)
            
            Text(status.displayText)
                .font(.system(size: 11))
                .foregroundColor(status.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(status.color.opacity(0.1))
        )
    }
}

// MARK: - Protection Dialog
struct ProtectionDialog: View {
    @ObservedObject var coordinator: StoryProtocolCoordinator
    @Binding var isPresented: Bool
    
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var isProcessing: Bool = false
    @State private var showSuccess: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                
                Text("Protect Screenplay as IP")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                }
                .buttonStyle(EnhancedAppleButtonStyle())
            }
            
            Divider()
            
            // Network info
            HStack {
                Text("Network:")
                    .font(.system(size: 13, weight: .medium))
                
                Text(coordinator.storyProtocolService.selectedNetwork.rawValue)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                ConnectionStatusIndicator(status: coordinator.storyProtocolService.connectionStatus)
            }
            
            // Form
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Screenplay Title")
                        .font(.system(size: 13, weight: .medium))
                    
                    TextField("Enter title", text: $title)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 13))
                        .padding(8)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(6)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Author")
                        .font(.system(size: 13, weight: .medium))
                    
                    TextField("Enter author name", text: $author)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 13))
                        .padding(8)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(6)
                }
            }
            
            // Info box
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 13))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("What happens when you protect?")
                        .font(.system(size: 12, weight: .medium))
                    
                    Text("Your screenplay will be registered as intellectual property on Story Protocol blockchain. This creates an immutable record of ownership and timestamp.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(12)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
            
            // Error message
            if let errorMessage = errorMessage {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                    
                    Text(errorMessage)
                        .font(.system(size: 11))
                        .foregroundColor(.red)
                }
                .padding(12)
                .background(Color.red.opacity(0.05))
                .cornerRadius(8)
            }
            
            // Success message
            if showSuccess {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                    
                    Text("Successfully protected!")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.green)
                }
                .padding(12)
                .background(Color.green.opacity(0.05))
                .cornerRadius(8)
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: { isPresented = false }) {
                    Text("Cancel")
                        .font(.system(size: 13, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .disabled(isProcessing)
                
                Button(action: protectScreenplay) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .frame(width: 12, height: 12)
                        }
                        Text(isProcessing ? "Protecting..." : "Protect")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.isEmpty || author.isEmpty || isProcessing)
            }
        }
        .padding(24)
        .frame(width: 480)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        .onAppear {
            // Pre-fill with document name if available
            if let documentName = coordinator.documentService.currentDocument?.title {
                title = documentName
            }
        }
    }
    
    private func protectScreenplay() {
        isProcessing = true
        errorMessage = nil
        showSuccess = false
        
        Task {
            let success = await coordinator.protectCurrentScreenplay(title: title, author: author)
            
            await MainActor.run {
                isProcessing = false
                
                if success {
                    showSuccess = true
                    // Close after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isPresented = false
                    }
                } else {
                    errorMessage = "Failed to protect screenplay. Please try again."
                }
            }
        }
    }
}

// MARK: - Connection Dialog
struct ConnectionDialog: View {
    @ObservedObject var coordinator: StoryProtocolCoordinator
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "bolt.circle")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)
                
                Text("Connect to Story Protocol")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                }
                .buttonStyle(EnhancedAppleButtonStyle())
            }
            
            Divider()
            
            // Network selector
            VStack(alignment: .leading, spacing: 12) {
                Text("Select Network")
                    .font(.system(size: 13, weight: .medium))
                
                ForEach(StoryProtocolNetwork.allCases, id: \.self) { network in
                    Button(action: {
                        coordinator.storyProtocolService.selectedNetwork = network
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(network.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                                
                                Text("Chain ID: \(network.chainId)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                
                                Text(network.rpcURL)
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if coordinator.storyProtocolService.selectedNetwork == network {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .font(.system(size: 18))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(coordinator.storyProtocolService.selectedNetwork == network ? Color.blue.opacity(0.1) : Color(.controlBackgroundColor))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Info
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 13))
                    .foregroundColor(.blue)
                
                Text("Use Testnet for testing and development. Use Mainnet for production IP registration.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: { isPresented = false }) {
                    Text("Cancel")
                        .font(.system(size: 13, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                
                Button(action: connect) {
                    Text("Connect")
                        .font(.system(size: 13, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 450)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    private func connect() {
        coordinator.connect()
        
        // Wait a bit for connection then close
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if case .connected = coordinator.storyProtocolService.connectionStatus {
                isPresented = false
                // Now show protection dialog
                coordinator.showProtectionDialog = true
            }
        }
    }
}

// MARK: - Protected Assets List
struct ProtectedAssetsList: View {
    @ObservedObject var coordinator: StoryProtocolCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Protected Screenplays")
                .font(.headline)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(coordinator.storyProtocolService.protectedAssets) { asset in
                        ProtectedAssetRow(asset: asset, coordinator: coordinator)
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Protected Asset Row
struct ProtectedAssetRow: View {
    let asset: IPAsset
    @ObservedObject var coordinator: StoryProtocolCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(.green)
                
                Text(asset.name)
                    .font(.system(size: 14, weight: .semibold))
                
                Spacer()
                
                Text(asset.network)
                    .font(.system(size: 11))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("IP ID:")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(asset.ipId.prefix(20) + "...")
                        .font(.system(size: 11, design: .monospaced))
                }
                
                HStack {
                    Text("Protected:")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(asset.timestamp, style: .date)
                        .font(.system(size: 11))
                }
            }
            
            HStack {
                Button(action: {
                    if let url = URL(string: asset.explorerURL) {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                        Text("View on Explorer")
                    }
                    .font(.system(size: 11))
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
        }
        .padding(12)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }
}

