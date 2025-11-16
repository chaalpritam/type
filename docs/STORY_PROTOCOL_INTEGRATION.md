# Story Protocol Integration Documentation

## Overview

This document describes the Story Protocol integration for the Type screenplay editor application. The integration allows users to protect their screenplays as intellectual property (IP) on the Story Protocol blockchain.

## Features Implemented

### 1. **Network Selection (Mainnet & Testnet)**
- Users can choose between Story Protocol Mainnet and Testnet
- Network selector is available in the toolbar
- Real-time connection status indicator
- Network-specific configuration (RPC URLs, Chain IDs, Explorer links)

### 2. **IP Protection**
- "Protect" button in the toolbar to register screenplay as IP
- Protection dialog with title and author fields
- Automatic content hashing for IP verification
- Transaction tracking with IPFS metadata storage (simulated)
- Protection status indicator with checkmark when protected

### 3. **Protected Assets Management**
- List of all protected screenplays
- View protection details (IP ID, timestamp, network)
- Direct links to blockchain explorer for verification
- Persistent storage of protection records

## Architecture

### Components

#### 1. **StoryProtocolService** (`Services/StoryProtocolService.swift`)
Core service handling all Story Protocol operations:
- **Network Management**: Switch between mainnet and testnet
- **Connection Handling**: Connect/disconnect from Story Protocol network
- **IP Registration**: Protect screenplays as IP assets
- **Asset Tracking**: Manage list of protected assets
- **Status Management**: Track connection and protection status

Key Classes:
```swift
- StoryProtocolNetwork: Network enumeration (mainnet/testnet)
- ConnectionStatus: Connection state tracking
- IPAsset: Protected asset model
- ProtectionStatus: Protection state tracking
- StoryProtocolService: Main service class
```

#### 2. **StoryProtocolCoordinator** (`Features/StoryProtocol/StoryProtocolCoordinator.swift`)
Coordinator managing UI state and business logic:
- Dialog state management
- Document integration
- Protection workflow orchestration

#### 3. **StoryProtocolViews** (`Features/StoryProtocol/StoryProtocolViews.swift`)
UI components:
- **ProtectionDialog**: Main protection interface
- **ConnectionDialog**: Network selection and connection
- **ProtectedAssetsList**: View protected assets
- **NetworkSelectorMenu**: Network switching menu
- **ConnectionStatusIndicator**: Real-time status display

#### 4. **Toolbar Integration**
Enhanced toolbar with Story Protocol controls:
- Network selector dropdown
- Connection status icon
- Protect button with status indicator

## User Interface

### Toolbar Elements

1. **Network Selector** (bottom row, right side)
   - Displays current network (Mainnet/Testnet)
   - Shows connection status with colored icon:
     - Green: Connected
     - Orange: Connecting
     - Red: Error
     - Gray: Disconnected
   - Click to open network selection menu

2. **Protect Button** (next to network selector)
   - Shield icon
   - Label: "Protect"
   - Shows green checkmark when screenplay is protected
   - Click to open protection dialog

### Protection Dialog

**Fields:**
- **Screenplay Title**: Name of the screenplay
- **Author**: Author name
- **Network**: Currently selected network (read-only)
- **Connection Status**: Real-time connection indicator

**Information:**
- Explanation of IP protection
- Benefits of blockchain registration

**Actions:**
- **Cancel**: Close dialog without protection
- **Protect**: Register screenplay as IP

**States:**
- Ready: Normal state
- Processing: During IP registration
- Success: Registration successful (auto-closes)
- Error: Registration failed (shows error message)

### Connection Dialog

**Purpose:** Select and connect to Story Protocol network

**Network Options:**
- **Mainnet**
  - Chain ID: 1516
  - RPC URL: https://rpc.story.foundation
  - For production IP registration
  
- **Testnet**
  - Chain ID: 1513
  - RPC URL: https://testnet.storyrpc.io
  - For testing and development

**Actions:**
- **Cancel**: Close without connecting
- **Connect**: Connect to selected network

## Usage Flow

### Protecting a Screenplay

1. **Write Screenplay**
   - Create or open screenplay in editor

2. **Connect to Network** (first time)
   - Click network selector in toolbar
   - Choose Mainnet or Testnet
   - Wait for connection (orange icon → green icon)

3. **Protect Screenplay**
   - Click "Protect" button in toolbar
   - If not connected, connection dialog appears first
   - Enter screenplay title and author
   - Click "Protect" button
   - Wait for processing (~ 2 seconds simulated)
   - Success confirmation appears
   - Protect button shows green checkmark

4. **Verify Protection**
   - Protect button shows checkmark indicator
   - View protected assets list
   - Click "View on Explorer" to see blockchain record

## Data Models

### IPAsset
```swift
struct IPAsset {
    let id: String                  // Unique identifier
    let name: String                // Screenplay title
    let description: String         // Description with author
    let ipId: String                // Story Protocol IP ID
    let txHash: String              // Transaction hash
    let timestamp: Date             // Protection timestamp
    let network: String             // Network (Mainnet/Testnet)
    let contentHash: String         // Content hash for verification
    let metadataURI: String?        // IPFS metadata URI
    var explorerURL: String         // Blockchain explorer URL
}
```

### Story Protocol Networks

**Mainnet:**
- Chain ID: 1516
- RPC: https://rpc.story.foundation
- Explorer: https://explorer.story.foundation

**Testnet:**
- Chain ID: 1513
- RPC: https://testnet.storyrpc.io
- Explorer: https://testnet.storyscan.xyz

## Implementation Details

### Content Hashing
- Content is hashed to create unique identifier
- Hash is used to check if screenplay already protected
- In production, use SHA-256 cryptographic hash

### Metadata Storage
- Screenplay metadata stored on IPFS
- IPFS URI stored in blockchain transaction
- Metadata includes: title, author, description, timestamp

### Protection Verification
- Each protection generates unique IP ID
- Transaction hash provides blockchain proof
- Explorer links allow public verification

### Persistence
- Protected assets stored in UserDefaults
- Network preference persisted
- Separate storage per network

## Current Limitations & Future Enhancements

### Current Implementation (Simulated)
- Mock blockchain connection (no actual Web3 calls)
- Simulated transaction processing
- Mock IP ID and transaction hash generation
- Local-only asset storage

### Required for Production

1. **Blockchain Integration**
   - Add Web3 library (e.g., Web3.swift)
   - Implement actual RPC calls to Story Protocol
   - Add wallet connection (MetaMask, WalletConnect)
   - Implement transaction signing

2. **IPFS Integration**
   - Add IPFS client library
   - Implement metadata upload to IPFS
   - Generate and store IPFS CIDs

3. **Smart Contract Integration**
   - Connect to Story Protocol IP registration contracts
   - Implement contract method calls
   - Handle gas fees and transactions
   - Add transaction confirmation polling

4. **Security**
   - Implement secure key storage (Keychain)
   - Add transaction validation
   - Implement proper error handling
   - Add retry logic for failed transactions

5. **User Experience**
   - Add wallet setup flow
   - Implement transaction history
   - Add gas price estimation
   - Show transaction progress
   - Add more detailed error messages

6. **Advanced Features**
   - Licensing management
   - Royalty tracking
   - Collaboration rights
   - Version control integration
   - Multi-signature protection

## Testing

### Manual Testing

1. **Network Selection**
   - Switch between mainnet and testnet
   - Verify connection status changes
   - Check network info is correct

2. **Protection Flow**
   - Protect screenplay on testnet
   - Verify protection dialog appears
   - Check success message
   - Verify checkmark appears on Protect button

3. **Asset Management**
   - View protected assets list
   - Check asset details are correct
   - Test explorer link (currently mock)

4. **Persistence**
   - Protect screenplay and restart app
   - Verify protected status persists
   - Check network preference persists

### Automated Testing (TODO)
- Unit tests for StoryProtocolService
- UI tests for protection flow
- Integration tests for coordinators

## API Reference

### StoryProtocolService

```swift
// Connect to network
func connect() async

// Disconnect from network
func disconnect()

// Switch network
func switchNetwork(_ network: StoryProtocolNetwork) async

// Protect screenplay
func protectScreenplay(
    title: String,
    content: String,
    author: String
) async -> Result<IPAsset, Error>

// Check protection status
func checkProtectionStatus(contentHash: String) -> IPAsset?
```

### StoryProtocolCoordinator

```swift
// Show protection dialog
func showProtect()

// Connect to network
func connect()

// Disconnect from network
func disconnect()

// Switch network
func switchNetwork(_ network: StoryProtocolNetwork)

// Protect current screenplay
func protectCurrentScreenplay(
    title: String,
    author: String
) async -> Bool
```

## Configuration

### Network Endpoints

Update network endpoints in `StoryProtocolService.swift`:

```swift
var rpcURL: String {
    switch self {
    case .mainnet:
        return "https://rpc.story.foundation"
    case .testnet:
        return "https://testnet.storyrpc.io"
    }
}
```

### Chain IDs

```swift
var chainId: Int {
    switch self {
    case .mainnet:
        return 1516 // Story Protocol Mainnet
    case .testnet:
        return 1513 // Story Protocol Testnet
    }
}
```

## Troubleshooting

### Connection Issues
- Check network selection
- Verify RPC endpoint availability
- Check internet connection

### Protection Fails
- Ensure screenplay has content
- Check network is connected
- Verify title and author fields filled

### Protected Status Not Showing
- Restart app to reload assets
- Check correct network selected
- Verify protection transaction completed

## Support & Resources

- **Story Protocol Docs**: https://docs.story.foundation
- **Story Protocol GitHub**: https://github.com/storyprotocol
- **Testnet Explorer**: https://testnet.storyscan.xyz
- **Mainnet Explorer**: https://explorer.story.foundation

## Version History

### v1.0.0 (Current)
- Initial Story Protocol integration
- Mainnet and Testnet support
- Basic IP protection flow
- Protected assets tracking
- Toolbar integration
- Connection management

## Contributing

When adding features to Story Protocol integration:

1. Update service layer first (`StoryProtocolService.swift`)
2. Update coordinator for UI state management
3. Add or modify views as needed
4. Update toolbar integration if required
5. Add tests for new functionality
6. Update this documentation

## License

This integration follows the same license as the main Type application.

