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

## Method 3: Using Automated Build Script

### Quick Build and Install
The repository includes a convenient script that automates the entire build and installation process:

```bash
# Basic build and install
./build_and_install.sh

# Clean build and install
./build_and_install.sh -c

# Build, install, and launch
./build_and_install.sh -l
```

This script will:
1. Check for required prerequisites (Xcode)
2. Build the app in Release configuration
3. Locate the built app in DerivedData
4. Install it to /Applications
5. Verify the installation
6. Optionally launch the app

## Method 4: Creating a DMG Installer

### Why Create a DMG?
A DMG (Disk Image) installer provides a professional, user-friendly way to distribute your app. Users can simply:
1. Download the DMG file
2. Open it
3. Drag the app to the Applications folder

### Creating the DMG
The repository includes a script that creates a distributable DMG installer:

```bash
# Create DMG with default settings
./create_dmg.sh

# Create DMG with clean build
./create_dmg.sh -c

# Create DMG and keep build artifacts for inspection
./create_dmg.sh -k

# Skip building and use existing build
./create_dmg.sh -s
```

### What the Script Does

The `create_dmg.sh` script performs the following steps:

1. **Builds the App**
   - Compiles in Release configuration
   - Creates an archive (.xcarchive)
   - Exports the app bundle

2. **Creates DMG Layout**
   - Copies the app to a staging area
   - Creates an Applications folder symlink
   - Customizes the window appearance (icon size, positioning)

3. **Generates Final DMG**
   - Creates a temporary writable DMG
   - Sets custom window properties using AppleScript
   - Converts to compressed read-only format
   - Verifies DMG integrity

### DMG Output

The script creates a DMG file named: `Type-Installer-{version}.dmg`

For example: `Type-Installer-1.0.0.dmg`

The DMG includes:
- **Type.app** - The application bundle at 150,200 position
- **Applications** - Symlink to /Applications at 450,200 position
- Custom window size (600x400)
- Icon view with 100pt icons

### Testing the DMG

After creation, test the DMG:

```bash
# Open the DMG
open Type-Installer-1.0.0.dmg

# Mount it and test drag-to-Applications
# Then eject and try reinstalling
```

### Distribution

Once you have the DMG, you can:
1. Upload to GitHub Releases
2. Host on your website
3. Share via direct download link
4. Submit to third-party distribution platforms

### DMG Script Options

```bash
-h, --help          Show help message
-c, --clean         Clean all previous builds and DMGs
-k, --keep-build    Keep build directory after DMG creation
-s, --skip-build    Skip building, use existing build
```

### Troubleshooting DMG Creation

**AppleScript Permission Error**
If you get an AppleScript error when running the script:
1. Go to **System Preferences** → **Privacy & Security** → **Automation**
2. Allow Terminal (or your terminal app) to control Finder

**Code Signing Issues**
If the export fails:
- The script will fall back to copying the app directly from the archive
- The app may show security warnings for users
- For distribution, configure proper code signing in Xcode

**DMG Not Mounting**
If the created DMG won't mount:
- Run `./create_dmg.sh -c` to clean and rebuild
- Check the console output for hdiutil errors
- Ensure you have enough disk space

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