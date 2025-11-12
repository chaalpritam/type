# Build Scripts & Development Workflow

This document covers the automated build scripts and development workflow for the Type app.

## Quick Start

```bash
# Build and install the app
./build_and_install.sh -l

# Test the installation
./test_app.sh
```

## Build Scripts Overview

### `build_and_install.sh` - Main Build Script

The primary script that automates the entire build and installation process.

#### Basic Usage
```bash
# Build and install (basic)
./build_and_install.sh

# Build, install, and launch
./build_and_install.sh -l

# Clean build (removes previous builds)
./build_and_install.sh -c

# Clean build, install, and launch
./build_and_install.sh -c -l
```

#### All Options
```bash
./build_and_install.sh [OPTIONS]

Options:
  -h, --help          Show help message
  -c, --clean         Clean previous builds before building
  -l, --launch        Launch the app after installation
  -i, --info          Show app information
  -s, --skip-clean    Skip cleaning previous builds
```

#### Examples
```bash
# Show help
./build_and_install.sh --help

# Show app information
./build_and_install.sh -i

# Clean build and launch
./build_and_install.sh -c -l

# Build without cleaning
./build_and_install.sh -s
```

### `test_app.sh` - Test Script

Verifies that the app is properly installed and functional.

#### Usage
```bash
# Run all tests
./test_app.sh
```

#### What It Tests
- ✅ App installation location (`/Applications/type.app`)
- ✅ Executable permissions
- ✅ Bundle structure (Info.plist, MacOS binary, Resources)
- ✅ App information (Bundle ID, Version)
- ✅ App size verification
- ✅ Launch capability

## Development Workflow

### Daily Development Process

1. **Make your changes** to the code
2. **Build and test immediately:**
   ```bash
   ./build_and_install.sh -l
   ```
3. **Verify everything works:**
   ```bash
   ./test_app.sh
   ```

### When to Use Clean Builds

Use clean builds (`-c` flag) when:
- You've added new dependencies
- You're experiencing strange build issues
- You want to ensure a completely fresh build
- You've made significant architectural changes

```bash
# Clean build and launch
./build_and_install.sh -c -l
```

### Testing Changes

After making any changes:
```bash
# Quick test (build and launch)
./build_and_install.sh -l

# Comprehensive test
./build_and_install.sh -l && ./test_app.sh
```

## Script Features

### Build Script Features

#### Prerequisite Checking
- ✅ Verifies Xcode is installed and accessible
- ✅ Confirms project structure is correct
- ✅ Checks for required files

#### Build Process
- ✅ Uses Release configuration for production builds
- ✅ Handles build errors gracefully
- ✅ Shows detailed build progress

#### Installation
- ✅ Automatically finds built app in DerivedData
- ✅ Removes existing installation if present
- ✅ Installs to `/Applications/type.app`
- ✅ Verifies successful installation

#### Verification
- ✅ Checks app bundle structure
- ✅ Verifies executable permissions
- ✅ Shows app size and information
- ✅ Tests launch capability

### Test Script Features

#### Comprehensive Testing
- ✅ Installation location verification
- ✅ Executable permission checking
- ✅ Bundle structure validation
- ✅ App information verification
- ✅ Launch capability testing

#### Detailed Reporting
- ✅ Colored output for easy reading
- ✅ Specific error messages
- ✅ Success/failure indicators
- ✅ App information display

## Troubleshooting

### Common Build Issues

#### Build Fails
```bash
# Check Xcode installation
xcodebuild -version

# Clean and rebuild
./build_and_install.sh -c

# Check project structure
ls -la type.xcodeproj/
```

#### App Won't Launch
```bash
# Test installation
./test_app.sh

# Check permissions
ls -la /Applications/type.app/Contents/MacOS/

# Try manual launch
open /Applications/type.app
```

#### "App can't be opened" Error
This is usually a Gatekeeper issue:
1. Go to System Preferences → Security & Privacy
2. Click "Open Anyway" for the type app
3. Or run: `sudo xattr -rd com.apple.quarantine /Applications/type.app`

### Script Issues

#### Permission Denied
```bash
# Make scripts executable
chmod +x build_and_install.sh test_app.sh
```

#### Script Not Found
```bash
# Ensure you're in the project directory
pwd
ls -la *.sh
```

#### Build Script Hangs
```bash
# Check if Xcode is running
ps aux | grep Xcode

# Kill any hanging processes
pkill -f xcodebuild
```

## Advanced Usage

### Custom Build Configurations

To build with different configurations, modify the script:
```bash
# Edit build_and_install.sh and change:
xcodebuild -project type.xcodeproj -scheme type -configuration Release build

# To:
xcodebuild -project type.xcodeproj -scheme type -configuration Debug build
```

### Automated Testing

Create a test script that runs after every build:
```bash
#!/bin/bash
# test_after_build.sh

./build_and_install.sh -l
./test_app.sh

# Add your custom tests here
echo "Running custom tests..."
# your_test_commands_here
```

### Continuous Integration

For CI/CD pipelines, use the non-interactive mode:
```bash
# Build without launching
./build_and_install.sh

# Test installation
./test_app.sh

# Exit with test results
exit $?
```

## Script Architecture

### Build Script Structure
```
build_and_install.sh
├── Prerequisite checks
│   ├── Xcode verification
│   └── Project structure check
├── Build process
│   ├── Clean (optional)
│   ├── xcodebuild execution
│   └── Error handling
├── Installation
│   ├── Find built app
│   ├── Remove existing
│   ├── Copy to Applications
│   └── Verify installation
└── Post-installation
    ├── Show app info
    ├── Launch (optional)
    └── Success message
```

### Test Script Structure
```
test_app.sh
├── Installation test
│   ├── App location check
│   └── Directory verification
├── Executable test
│   ├── Permission check
│   └── Binary verification
├── Bundle test
│   ├── Required files check
│   └── Structure validation
├── Information test
│   ├── Bundle ID check
│   ├── Version verification
│   └── Size display
└── Launch test
    ├── Launch capability
    └── Timeout handling
```

## Best Practices

### Development Workflow
1. **Always test after changes** - Use `./build_and_install.sh -l`
2. **Use clean builds for major changes** - Use `-c` flag
3. **Verify with test script** - Run `./test_app.sh` regularly
4. **Check app information** - Use `./build_and_install.sh -i`

### Script Maintenance
1. **Keep scripts executable** - `chmod +x *.sh`
2. **Update paths if needed** - Modify script paths for your setup
3. **Test on clean systems** - Verify scripts work on fresh installations
4. **Document changes** - Update this README when modifying scripts

### Error Handling
1. **Check prerequisites** - Ensure Xcode and project structure
2. **Use clean builds** - When experiencing strange issues
3. **Verify permissions** - Check file and script permissions
4. **Test installation** - Always verify the app works after installation

## Support

For issues with the build scripts:
1. Check the troubleshooting section above
2. Verify your Xcode installation
3. Ensure you're in the correct directory
4. Check script permissions
5. Review the error messages for specific issues

---

**Happy Building!** 🚀 