#!/bin/bash

# Build and Install Script for Type App
# This script builds the app and installs it to Applications for testing

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
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
    
    # Remove derived data for this project
    DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
    PROJECT_DERIVED_DATA=$(find "$DERIVED_DATA_PATH" -name "*type*" -type d 2>/dev/null | head -n 1)
    
    if [ -n "$PROJECT_DERIVED_DATA" ]; then
        rm -rf "$PROJECT_DERIVED_DATA"
        print_success "Cleaned derived data: $(basename "$PROJECT_DERIVED_DATA")"
    else
        print_warning "No previous derived data found to clean"
    fi
}

# Function to build the app
build_app() {
    print_status "Building app with Release configuration..."
    
    # Build the app
    if xcodebuild -project type.xcodeproj -scheme type -configuration Release build; then
        print_success "Build completed successfully!"
    else
        print_error "Build failed!"
        exit 1
    fi
}

# Function to find the built app
find_built_app() {
    print_status "Locating built app..."
    
    # Find the built app in derived data
    DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
    BUILT_APP=$(find "$DERIVED_DATA_PATH" -name "type.app" -type d 2>/dev/null | head -n 1)
    
    if [ -z "$BUILT_APP" ]; then
        print_error "Could not find built app in DerivedData"
        exit 1
    fi
    
    print_success "Found built app: $BUILT_APP"
    echo "$BUILT_APP"
}

# Function to install the app
install_app() {
    local source_app="$1"
    local target_app="/Applications/type.app"
    
    print_status "Installing app to Applications..."
    
    # Remove existing app if it exists
    if [ -d "$target_app" ]; then
        print_warning "Removing existing app installation..."
        rm -rf "$target_app"
    fi
    
    # Copy the new app
    if cp -R "$source_app" "$target_app"; then
        print_success "App installed successfully to $target_app"
    else
        print_error "Failed to install app"
        exit 1
    fi
}

# Function to verify installation
verify_installation() {
    local target_app="/Applications/type.app"
    
    print_status "Verifying installation..."
    
    if [ -d "$target_app" ]; then
        print_success "App verified at: $target_app"
        
        # Check app size
        APP_SIZE=$(du -sh "$target_app" | cut -f1)
        print_status "App size: $APP_SIZE"
        
        # Check if app is executable
        if [ -x "$target_app/Contents/MacOS/type" ]; then
            print_success "App executable verified"
        else
            print_warning "App executable not found or not executable"
        fi
    else
        print_error "App not found at expected location"
        exit 1
    fi
}

# Function to launch the app
launch_app() {
    print_status "Launching app..."
    
    if open "/Applications/type.app"; then
        print_success "App launched successfully!"
    else
        print_error "Failed to launch app"
        exit 1
    fi
}

# Function to show app info
show_app_info() {
    print_status "App Information:"
    echo "  Name: type"
    echo "  Location: /Applications/type.app"
    echo "  Bundle ID: store.celluloid.type"
    echo "  Version: $(defaults read /Applications/type.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo "Unknown")"
    echo "  Build: $(defaults read /Applications/type.app/Contents/Info.plist CFBundleVersion 2>/dev/null || echo "Unknown")"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -c, --clean         Clean previous builds before building"
    echo "  -l, --launch        Launch the app after installation"
    echo "  -i, --info          Show app information"
    echo "  -s, --skip-clean    Skip cleaning previous builds"
    echo ""
    echo "Examples:"
    echo "  $0                  Build and install app"
    echo "  $0 -c              Clean, build, and install app"
    echo "  $0 -l              Build, install, and launch app"
    echo "  $0 -c -l           Clean, build, install, and launch app"
}

# Main script
main() {
    local clean_build_flag=false
    local launch_app_flag=false
    local show_info_flag=false
    local skip_clean_flag=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -c|--clean)
                clean_build_flag=true
                shift
                ;;
            -l|--launch)
                launch_app_flag=true
                shift
                ;;
            -i|--info)
                show_info_flag=true
                shift
                ;;
            -s|--skip-clean)
                skip_clean_flag=true
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
    echo "  Type App - Build and Install Script"
    echo "=========================================="
    echo ""
    
    # Check prerequisites
    check_xcode
    check_directory
    
    # Show app info if requested
    if [ "$show_info_flag" = true ]; then
        show_app_info
        exit 0
    fi
    
    # Clean build if requested
    if [ "$clean_build_flag" = true ] && [ "$skip_clean_flag" = false ]; then
        clean_build
    fi
    
    # Build the app
    build_app
    
    # Find and install the app
    BUILT_APP=$(find_built_app)
    install_app "$BUILT_APP"
    
    # Verify installation
    verify_installation
    
    # Show app info
    show_app_info
    
    # Launch app if requested
    if [ "$launch_app_flag" = true ]; then
        launch_app
    fi
    
    echo ""
    print_success "Build and installation completed successfully!"
    echo ""
    echo "You can now:"
    echo "  • Launch the app from Applications"
    echo "  • Run: open /Applications/type.app"
    echo "  • Use Spotlight (Cmd+Space) and search for 'type'"
    echo ""
    echo "To build and launch in one command:"
    echo "  ./build_and_install.sh -l"
    echo ""
}

# Run main function with all arguments
main "$@" 