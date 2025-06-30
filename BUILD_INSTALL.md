# Build and Installation Guide

This guide will help you build and install the "type" macOS app on your Mac.

## Prerequisites

- macOS (tested on macOS 14.0+)
- Xcode 16.1 or later
- Apple Developer account (for code signing)

## Method 1: Using Xcode (Recommended)

### Step 1: Open the Project
```bash
cd /path/to/your/project
open type.xcodeproj
```

### Step 2: Configure Build Settings
1. In Xcode, select the "type" target
2. Make sure "My Mac" is selected as the target device (not iOS simulator)
3. Select "Release" configuration for production build

### Step 3: Build and Run
- Press `Cmd + R` or click the "Play" button to build and run
- The app will launch automatically after successful build

### Step 4: Install Permanently
1. Go to `Product` → `Archive` in Xcode
2. This creates an archive that you can distribute
3. Follow the Organizer prompts to export the app

## Method 2: Using Command Line

### Step 1: Navigate to Project Directory
```bash
cd /path/to/your/project
```

### Step 2: Build the App
```bash
xcodebuild -project type.xcodeproj -scheme type -configuration Release build
```

### Step 3: Locate the Built App
The built app will be located in:
```
~/Library/Developer/Xcode/DerivedData/type-*/Build/Products/Release/type.app
```

### Step 4: Install to Applications
```bash
# Find the exact path
find ~/Library/Developer/Xcode/DerivedData -name "type.app" -type d

# Copy to Applications (replace with actual path from above)
cp -R "/Users/username/Library/Developer/Xcode/DerivedData/type-*/Build/Products/Release/type.app" /Applications/
```

## Verification

### Check Installation
```bash
ls -la /Applications/type.app
```

### Launch the App
You can now launch the app by:
1. **Finder**: Applications → type.app
2. **Spotlight**: Cmd + Space, then type "type"
3. **Terminal**: `open /Applications/type.app`

## Troubleshooting

### Security Warnings
If macOS shows a security warning:
1. Go to **System Preferences** → **Security & Privacy** → **General**
2. Click **"Allow Anyway"** for the type app

### App Won't Launch
Run from terminal to see error messages:
```bash
/Applications/type.app/Contents/MacOS/type
```

### Build Errors
Common issues and solutions:
- **Missing dependencies**: Ensure all Swift packages are resolved
- **Code signing issues**: Check your Apple Developer certificate
- **SDK version**: Make sure you're using a compatible macOS SDK

## App Information

- **Bundle Identifier**: `store.celluloid.type`
- **Minimum Deployment Target**: macOS 14.0
- **Architecture**: ARM64 (Apple Silicon) and x86_64 (Intel)
- **Type**: macOS SwiftUI Application

## Development Notes

- The app is code-signed with your Apple Developer certificate
- Built with Release configuration for optimal performance
- Includes sandbox entitlements for security
- Supports Fountain screenplay format editing

## File Structure

```
type.app/
├── Contents/
│   ├── MacOS/
│   │   └── type (executable)
│   ├── Resources/
│   │   └── Assets.car
│   ├── Info.plist
│   └── PkgInfo
```

## Next Steps

After installation, you can:
1. Launch the app and start using it
2. Create desktop shortcuts
3. Add to Dock for quick access
4. Set up automatic updates (if implemented)

---

**Note**: This app appears to be a Fountain screenplay editor with features like syntax highlighting, auto-completion, and collaboration tools. 