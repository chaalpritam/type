#!/bin/bash

# Create DMG Installer for Type App
# This script builds the app and packages it into a distributable DMG file

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="type"
BUNDLE_NAME="Type.app"
DMG_NAME="Type-Installer"
VOLUME_NAME="Type Installer"
BUILD_DIR="build"
DMG_TEMP_DIR="dmg_temp"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if Xcode is installed
check_xcode() {
    if ! command_exists xcodebuild; then
        print_error "Xcode is not installed or not in PATH"
        print_error "Please install Xcode from the App Store"
        exit 1
    fi

    print_success "Xcode found: $(xcodebuild -version | head -n 1)"
}

# Function to check if we're in the right directory
check_directory() {
    if [ ! -f "type.xcodeproj/project.pbxproj" ]; then
        print_error "This script must be run from the project root directory"
        print_error "Please navigate to the directory containing type.xcodeproj"
        exit 1
    fi

    print_success "Project directory confirmed"
}

# Function to clean previous builds
clean_build() {
    print_status "Cleaning previous builds..."

    # Remove build directory
    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
        print_success "Removed previous build directory"
    fi

    # Remove DMG temp directory
    if [ -d "$DMG_TEMP_DIR" ]; then
        rm -rf "$DMG_TEMP_DIR"
        print_success "Removed previous DMG temp directory"
    fi

    # Remove old DMG files
    if ls ${DMG_NAME}*.dmg 1> /dev/null 2>&1; then
        rm -f ${DMG_NAME}*.dmg
        print_success "Removed previous DMG files"
    fi
}

# Function to build the app
build_app() {
    print_status "Building app with Release configuration..."

    # Create build directory
    mkdir -p "$BUILD_DIR"

    # Build the app with archive
    if xcodebuild \
        -project type.xcodeproj \
        -scheme type \
        -configuration Release \
        -derivedDataPath "$BUILD_DIR/DerivedData" \
        -archivePath "$BUILD_DIR/${APP_NAME}.xcarchive" \
        archive; then
        print_success "Build completed successfully!"
    else
        print_error "Build failed!"
        exit 1
    fi

    # Export the app from archive
    print_status "Exporting app from archive..."

    # Create export options plist
    cat > "$BUILD_DIR/ExportOptions.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>mac-application</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

    if xcodebuild \
        -exportArchive \
        -archivePath "$BUILD_DIR/${APP_NAME}.xcarchive" \
        -exportPath "$BUILD_DIR/Export" \
        -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist"; then
        print_success "Export completed successfully!"
    else
        print_warning "Export with signing failed, trying without signing..."

        # Fallback: Copy app directly from archive
        ARCHIVE_APP="$BUILD_DIR/${APP_NAME}.xcarchive/Products/Applications/${APP_NAME}.app"
        if [ -d "$ARCHIVE_APP" ]; then
            mkdir -p "$BUILD_DIR/Export"
            cp -R "$ARCHIVE_APP" "$BUILD_DIR/Export/"
            print_success "Copied app from archive"
        else
            print_error "Could not find app in archive"
            exit 1
        fi
    fi
}

# Function to get app version
get_app_version() {
    local app_path="$BUILD_DIR/Export/${APP_NAME}.app"

    if [ -d "$app_path" ]; then
        VERSION=$(defaults read "$app_path/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "1.0.0")
        BUILD=$(defaults read "$app_path/Contents/Info.plist" CFBundleVersion 2>/dev/null || echo "1")
        echo "${VERSION}"
    else
        echo "1.0.0"
    fi
}

# Function to create DMG
create_dmg() {
    print_status "Creating DMG installer..."

    local app_path="$BUILD_DIR/Export/${APP_NAME}.app"

    # Verify app exists
    if [ ! -d "$app_path" ]; then
        print_error "App not found at: $app_path"
        exit 1
    fi

    # Get app version for DMG name
    local version=$(get_app_version)
    local dmg_filename="${DMG_NAME}-${version}.dmg"

    print_status "Creating DMG: $dmg_filename"

    # Create temporary directory for DMG contents
    mkdir -p "$DMG_TEMP_DIR"

    # Copy app to temp directory
    print_status "Copying app to DMG staging area..."
    cp -R "$app_path" "$DMG_TEMP_DIR/$BUNDLE_NAME"

    # Create a symbolic link to Applications folder
    print_status "Creating Applications symlink..."
    ln -s /Applications "$DMG_TEMP_DIR/Applications"

    # Create the DMG
    print_status "Building DMG file..."

    # Remove existing DMG if it exists
    if [ -f "$dmg_filename" ]; then
        rm -f "$dmg_filename"
    fi

    # Create a temporary writable DMG
    local temp_dmg="temp_${dmg_filename}"

    hdiutil create \
        -volname "$VOLUME_NAME" \
        -srcfolder "$DMG_TEMP_DIR" \
        -ov \
        -format UDRW \
        "$temp_dmg"

    print_success "Temporary DMG created"

    # Mount the temporary DMG
    print_status "Mounting DMG for customization..."
    local mount_point=$(hdiutil attach -readwrite -noverify -noautoopen "$temp_dmg" | grep "/Volumes/" | awk -F'\t' '{print $3}')

    if [ -z "$mount_point" ]; then
        print_error "Failed to mount DMG"
        exit 1
    fi

    print_success "DMG mounted at: $mount_point"

    # Set custom icon positions and window size using AppleScript
    print_status "Customizing DMG window..."

    osascript <<EOF
tell application "Finder"
    tell disk "$VOLUME_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 700, 500}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 100
        set position of item "$BUNDLE_NAME" of container window to {150, 200}
        set position of item "Applications" of container window to {450, 200}
        update without registering applications
        delay 2
    end tell
end tell
EOF

    print_success "DMG window customized"

    # Unmount the DMG
    print_status "Unmounting DMG..."
    hdiutil detach "$mount_point"

    # Convert to compressed read-only DMG
    print_status "Compressing DMG..."
    hdiutil convert "$temp_dmg" \
        -format UDZO \
        -imagekey zlib-level=9 \
        -o "$dmg_filename"

    # Clean up temporary DMG
    rm -f "$temp_dmg"

    print_success "DMG created: $dmg_filename"

    # Show DMG size
    local dmg_size=$(du -sh "$dmg_filename" | cut -f1)
    print_status "DMG size: $dmg_size"
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up temporary files..."

    if [ -d "$DMG_TEMP_DIR" ]; then
        rm -rf "$DMG_TEMP_DIR"
        print_success "Removed DMG temp directory"
    fi

    # Optionally keep or remove build directory
    if [ "$KEEP_BUILD" = false ]; then
        if [ -d "$BUILD_DIR" ]; then
            rm -rf "$BUILD_DIR"
            print_success "Removed build directory"
        fi
    else
        print_status "Keeping build directory for inspection"
    fi
}

# Function to verify DMG
verify_dmg() {
    local version=$(get_app_version)
    local dmg_filename="${DMG_NAME}-${version}.dmg"

    print_status "Verifying DMG..."

    if [ ! -f "$dmg_filename" ]; then
        print_error "DMG file not found: $dmg_filename"
        exit 1
    fi

    # Verify DMG integrity
    if hdiutil verify "$dmg_filename"; then
        print_success "DMG verification passed"
    else
        print_error "DMG verification failed"
        exit 1
    fi

    # Show final DMG info
    print_success "DMG created successfully!"
    echo ""
    echo "DMG Information:"
    echo "  File: $dmg_filename"
    echo "  Size: $(du -sh "$dmg_filename" | cut -f1)"
    echo "  Location: $(pwd)/$dmg_filename"
    echo ""
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -c, --clean         Clean all previous builds and DMGs before creating"
    echo "  -k, --keep-build    Keep build directory after DMG creation"
    echo "  -s, --skip-build    Skip building, use existing build (requires prior build)"
    echo ""
    echo "Examples:"
    echo "  $0                  Create DMG with fresh build"
    echo "  $0 -c              Clean everything and create DMG"
    echo "  $0 -k              Create DMG and keep build files"
    echo "  $0 -s              Create DMG from existing build"
}

# Main script
main() {
    local clean_flag=false
    local skip_build=false
    KEEP_BUILD=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -c|--clean)
                clean_flag=true
                shift
                ;;
            -k|--keep-build)
                KEEP_BUILD=true
                shift
                ;;
            -s|--skip-build)
                skip_build=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Show script header
    echo "=========================================="
    echo "  Type App - DMG Installer Creator"
    echo "=========================================="
    echo ""

    # Check prerequisites
    check_xcode
    check_directory

    # Clean if requested
    if [ "$clean_flag" = true ]; then
        clean_build
    fi

    # Build the app unless skipped
    if [ "$skip_build" = false ]; then
        build_app
    else
        print_status "Skipping build, using existing build..."

        if [ ! -d "$BUILD_DIR/Export/${APP_NAME}.app" ]; then
            print_error "No existing build found. Please build first or remove -s flag."
            exit 1
        fi
    fi

    # Create DMG
    create_dmg

    # Verify DMG
    verify_dmg

    # Cleanup
    cleanup

    echo ""
    print_success "DMG installer creation completed successfully!"
    echo ""
    echo "You can now:"
    echo "  • Distribute the DMG file to users"
    echo "  • Test the installer by opening the DMG"
    echo "  • Upload to your website or GitHub releases"
    echo ""
    echo "To test the DMG:"
    local version=$(get_app_version)
    echo "  open ${DMG_NAME}-${version}.dmg"
    echo ""
}

# Run main function with all arguments
main "$@"
