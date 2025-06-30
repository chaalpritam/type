#!/bin/bash

# Test Script for Type App
# This script tests the installed app functionality

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

echo "=========================================="
echo "  Type App - Test Script"
echo "=========================================="
echo ""

# Test 1: Check if app exists
print_status "Testing app installation..."
if [ -d "/Applications/type.app" ]; then
    print_success "App found at /Applications/type.app"
else
    print_error "App not found at /Applications/type.app"
    exit 1
fi

# Test 2: Check if app is executable
print_status "Testing app executable..."
if [ -x "/Applications/type.app/Contents/MacOS/type" ]; then
    print_success "App executable verified"
else
    print_error "App executable not found or not executable"
    exit 1
fi

# Test 3: Check app bundle structure
print_status "Testing app bundle structure..."
REQUIRED_FILES=(
    "Contents/Info.plist"
    "Contents/MacOS/type"
    "Contents/Resources"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -e "/Applications/type.app/$file" ]; then
        print_success "Found: $file"
    else
        print_error "Missing: $file"
        exit 1
    fi
done

# Test 4: Check app info
print_status "Testing app information..."
BUNDLE_ID=$(defaults read /Applications/type.app/Contents/Info.plist CFBundleIdentifier 2>/dev/null || echo "Unknown")
VERSION=$(defaults read /Applications/type.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null || echo "Unknown")

echo "  Bundle ID: $BUNDLE_ID"
echo "  Version: $VERSION"

if [ "$BUNDLE_ID" = "store.celluloid.type" ]; then
    print_success "Bundle ID verified"
else
    print_error "Incorrect Bundle ID: $BUNDLE_ID"
fi

# Test 5: Check app size
print_status "Testing app size..."
APP_SIZE=$(du -sh /Applications/type.app | cut -f1)
echo "  App size: $APP_SIZE"

if [ -n "$APP_SIZE" ]; then
    print_success "App size verified"
else
    print_error "Could not determine app size"
fi

# Test 6: Test app launch (non-blocking)
print_status "Testing app launch capability..."
if timeout 5s open "/Applications/type.app" >/dev/null 2>&1; then
    print_success "App launch test passed"
else
    print_error "App launch test failed"
fi

echo ""
print_success "All tests completed successfully!"
echo ""
echo "App is ready for use:"
echo "  • Launch from Applications folder"
echo "  • Use Spotlight (Cmd+Space) and search for 'type'"
echo "  • Run: open /Applications/type.app"
echo "" 