# Type - Comprehensive Codebase Documentation

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture Overview](#architecture-overview)
3. [Folder Structure](#folder-structure)
4. [Core Modules](#core-modules)
5. [Features Modules](#features-modules)
6. [Services Layer](#services-layer)
7. [Data Models](#data-models)
8. [UI Components](#ui-components)
9. [Key Files Explained](#key-files-explained)
10. [Development Workflow](#development-workflow)
11. [Build and Installation](#build-and-installation)

---

## 🎯 Project Overview

**Type** is a modern, professional screenplay writing application for macOS built with SwiftUI. It features real-time Fountain format parsing, live preview, and a modular architecture designed for extensibility and maintainability.

### Key Features
- **Real-time Fountain Parsing**: Live syntax highlighting and formatting
- **Professional Preview**: A4-style screenplay formatting with proper typography
- **Modular Architecture**: Clean separation of concerns with coordinator pattern
- **Apple Design Philosophy**: Native macOS styling with translucent materials
- **Advanced Editor Features**: Multiple cursors, code folding, auto-completion
- **Collaboration Tools**: Comments, version control, real-time sharing
- **Character Management**: Comprehensive character database and tracking
- **Outline Mode**: Hierarchical document organization
- **File Management**: Auto-save, recent files, export options

---

## 🏗️ Architecture Overview

The application follows a **Modular Coordinator Architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    ModularAppView                         │
│                 (Main App Container)                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  AppCoordinator                           │
│              (Central State Manager)                      │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Editor    │    │ Characters  │    │   Outline   │
│Coordinator  │    │Coordinator  │    │Coordinator  │
└─────────────┘    └─────────────┘    └─────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Editor    │    │ Characters  │    │   Outline   │
│   Views     │    │   Views     │    │   Views     │
└─────────────┘    └─────────────┘    └─────────────┘
```

### Architecture Principles

1. **Single Responsibility**: Each module handles one specific domain
2. **Dependency Injection**: Services are injected into coordinators
3. **Reactive Programming**: Combine framework for state management
4. **Apple Design Guidelines**: Native macOS styling and behavior
5. **Modularity**: Independent modules that can be developed separately

---

## 📁 Folder Structure

```
type/
├── 📁 Core/                          # Core application architecture
│   ├── AppCoordinator.swift          # Main app state coordinator
│   └── ModuleCoordinator.swift       # Base coordinator protocol
│
├── 📁 Data/                          # Data models and structures
│   ├── ScreenplayDocument.swift      # Main document model
│   ├── CharacterModels.swift         # Character data structures
│   ├── OutlineModels.swift           # Outline data structures
│   ├── SceneModels.swift             # Scene data structures
│   └── TimelineModels.swift          # Timeline data structures
│
├── 📁 Features/                      # Feature modules (main functionality)
│   ├── 📁 Editor/                    # Text editor and Fountain parsing
│   ├── 📁 Characters/                # Character management system
│   ├── 📁 Outline/                   # Outline and structure tools
│   ├── 📁 Collaboration/             # Real-time collaboration
│   ├── 📁 File/                      # File management operations
│   ├── 📁 Scenes/                    # Scene organization
│   └── 📁 Timeline/                  # Timeline visualization
│
├── 📁 Services/                      # Backend services and utilities
│   ├── DocumentService.swift         # Document lifecycle management
│   ├── FileManagementService.swift   # File operations
│   ├── SettingsService.swift         # User preferences
│   ├── StatisticsService.swift       # Analytics and metrics
│   └── FileManager.swift             # Low-level file operations
│
├── 📁 UI/                           # User interface components
│   ├── ModularAppView.swift         # Main app container
│   ├── EnhancedAppleComponents.swift # Apple-style UI components
│   └── TemplateSelectorView.swift   # Template selection interface
│
├── 📁 Utils/                        # Utility functions and helpers
│   └── KeyboardShortcutsManager.swift # Keyboard shortcut handling
│
├── 📁 Assets.xcassets/              # App icons and visual assets
├── typeApp.swift                     # App entry point
├── type.entitlements                 # App permissions and capabilities
└── SceneEditViews.swift             # Scene editing interface
```

---

## 🎯 Core Modules

### AppCoordinator.swift
**Location**: `type/Core/AppCoordinator.swift`
**Purpose**: Central coordinator that manages app state and coordinates between modules

**Key Responsibilities**:
- Manages current view state (Editor, Characters, Outline, Collaboration)
- Coordinates between different feature modules
- Handles document changes and updates all coordinators
- Manages full-screen mode and settings

**Key Properties**:
```swift
@Published var currentView: AppView = .editor
@Published var isFullScreen: Bool = false
@Published var showSettings: Bool = false

// Module Coordinators
let editorCoordinator: EditorCoordinator
let characterCoordinator: CharacterCoordinator
let outlineCoordinator: OutlineCoordinator
let collaborationCoordinator: CollaborationCoordinator
let fileCoordinator: FileCoordinator

// Shared Services
let documentService: DocumentService
let settingsService: SettingsService
let fileManagementService: FileManagementService
let statisticsService: StatisticsService
```

### ModuleCoordinator.swift
**Location**: `type/Core/ModuleCoordinator.swift`
**Purpose**: Base protocol for all feature coordinators

**Key Features**:
- Defines common interface for all coordinators
- Provides base functionality for document management
- Ensures consistent behavior across modules

---

## 🚀 Features Modules

### Editor Module
**Location**: `type/Features/Editor/`

**Components**:
- **EditorCoordinator.swift**: Main editor state management
- **FountainTextEditor.swift**: Core text editing functionality
- **EnhancedFountainTextEditor.swift**: Advanced editor features
- **FountainParser.swift**: Real-time Fountain syntax parsing
- **FountainSyntaxHighlighter.swift**: Syntax highlighting
- **ScreenplayPreview.swift**: Live preview rendering
- **AutoCompletionManager.swift**: Smart text completion
- **SmartFormattingManager.swift**: Automatic formatting
- **TextHistoryManager.swift**: Undo/redo functionality
- **FindReplaceView.swift**: Search and replace interface
- **FountainHelpView.swift**: Built-in help system
- **AdvancedEditorFeatures.swift**: Advanced editing capabilities
- **MultipleCursorsTextEditor.swift**: Multi-cursor editing
- **CodeFoldingManager.swift**: Code folding functionality
- **MinimapView.swift**: Document overview
- **SpellCheckTextEditor.swift**: Spell checking
- **FountainTemplate.swift**: Pre-built templates

**Key Features**:
- Real-time Fountain parsing and syntax highlighting
- Live preview with professional formatting
- Auto-completion for character names and scene headings
- Smart formatting (auto-capitalization, spacing)
- Multiple cursors for batch editing
- Code folding for scene and section organization
- Find and replace with regex support
- Spell checking with screenplay-specific dictionaries
- Undo/redo with proper state management
- Template system for different screenplay types

### Characters Module
**Location**: `type/Features/Characters/`

**Components**:
- **CharacterCoordinator.swift**: Character management coordination
- **CharacterDatabase.swift**: Character data storage and retrieval
- **CharacterViews.swift**: Main character interface
- **CharacterDetailViews.swift**: Character detail panels
- **CharacterDetailViews2.swift**: Enhanced character details
- **CharacterEditViews.swift**: Character editing interface

**Key Features**:
- Comprehensive character database
- Character profiles with photos and descriptions
- Character arc tracking
- Relationship mapping
- Dialogue analysis
- Character statistics and metrics
- Character search and filtering
- Character export and import

### Outline Module
**Location**: `type/Features/Outline/`

**Components**:
- **OutlineCoordinator.swift**: Outline management coordination
- **OutlineDatabase.swift**: Outline data storage
- **OutlineViews.swift**: Main outline interface
- **OutlineDetailViews.swift**: Detailed outline views

**Key Features**:
- Hierarchical document organization
- Scene and section management
- Drag-and-drop reordering
- Outline statistics and metrics
- Export outline to various formats
- Outline templates for different story structures

### Collaboration Module
**Location**: `type/Features/Collaboration/`

**Components**:
- **CollaborationCoordinator.swift**: Collaboration state management
- **CollaborationManager.swift**: Real-time collaboration logic
- **CollaborationViews.swift**: Collaboration interface

**Key Features**:
- Real-time collaborative editing
- Comments and annotations
- Version control and history
- User management and permissions
- Document sharing and invites
- Conflict resolution
- Activity tracking

### File Module
**Location**: `type/Features/File/`

**Components**:
- **FileCoordinator.swift**: File operation coordination

**Key Features**:
- File open/save operations
- Auto-save functionality
- Recent files management
- Export to various formats (PDF, FDX, plain text)
- File format validation
- Backup and recovery

### Scenes Module
**Location**: `type/Features/Scenes/`

**Components**:
- **SceneDatabase.swift**: Scene data management
- **SceneViews.swift**: Scene interface
- **SceneDetailViews.swift**: Scene detail panels

**Key Features**:
- Scene organization and management
- Scene metadata tracking
- Scene statistics and analysis
- Scene templates
- Scene export and import

### Timeline Module
**Location**: `type/Features/Timeline/`

**Components**:
- **TimelineDatabase.swift**: Timeline data management
- **TimelineViews.swift**: Timeline visualization

**Key Features**:
- Visual story timeline
- Event tracking and management
- Timeline analysis
- Story structure visualization
- Timeline export

---

## 🔧 Services Layer

### DocumentService.swift
**Location**: `type/Services/DocumentService.swift`
**Purpose**: Centralized document lifecycle management

**Key Features**:
- Document creation, loading, and saving
- Auto-save functionality (every 30 seconds)
- Recent files management
- Document modification tracking
- Error handling and recovery

**Key Methods**:
```swift
func newDocument() -> Void
func loadDocument(from url: URL) async throws
func saveDocument() async throws
func saveDocumentAs() async throws -> URL?
func updateDocumentContent(_ content: String) -> Void
func toggleAutoSave() -> Void
```

### FileManagementService.swift
**Location**: `type/Services/FileManagementService.swift`
**Purpose**: High-level file operations and management

**Key Features**:
- File picker integration
- Export functionality
- File format handling
- Permission management
- Error handling

### SettingsService.swift
**Location**: `type/Services/SettingsService.swift`
**Purpose**: User preferences and settings management

**Key Features**:
- User preferences storage
- Default settings management
- Settings validation
- Settings export/import

### StatisticsService.swift
**Location**: `type/Services/StatisticsService.swift`
**Purpose**: Analytics and document statistics

**Key Features**:
- Word count calculation
- Page count estimation
- Character count tracking
- Writing progress metrics
- Statistics visualization

### FileManager.swift
**Location**: `type/Services/FileManager.swift`
**Purpose**: Low-level file system operations

**Key Features**:
- File system operations
- Directory management
- File permissions
- Error handling

---

## 📊 Data Models

### ScreenplayDocument.swift
**Location**: `type/Data/ScreenplayDocument.swift`
**Purpose**: Main document data structure

**Key Properties**:
```swift
struct ScreenplayDocument: Identifiable, Codable, Equatable {
    let id: UUID
    var content: String
    var url: URL?
    var title: String
    var author: String
    var createdAt: Date
    var updatedAt: Date
    var metadata: DocumentMetadata
}
```

**DocumentMetadata**:
```swift
struct DocumentMetadata: Codable, Equatable {
    var genre: String
    var targetLength: Int
    var status: DocumentStatus
    var tags: [String]
    var notes: String
    var version: String
    var collaborators: [String]
    var lastBackup: Date?
}
```

### CharacterModels.swift
**Location**: `type/Data/CharacterModels.swift`
**Purpose**: Character data structures

**Key Models**:
- Character profiles
- Character relationships
- Character arcs
- Character statistics

### OutlineModels.swift
**Location**: `type/Data/OutlineModels.swift`
**Purpose**: Outline and structure data

**Key Models**:
- Outline hierarchy
- Scene organization
- Section management
- Outline metadata

### SceneModels.swift
**Location**: `type/Data/SceneModels.swift`
**Purpose**: Scene data structures

**Key Models**:
- Scene information
- Scene metadata
- Scene statistics
- Scene relationships

### TimelineModels.swift
**Location**: `type/Data/TimelineModels.swift`
**Purpose**: Timeline data structures

**Key Models**:
- Timeline events
- Story structure
- Timeline metadata
- Event relationships

---

## 🎨 UI Components

### ModularAppView.swift
**Location**: `type/UI/ModularAppView.swift`
**Purpose**: Main app container and layout

**Key Features**:
- Modular content switching
- Enhanced Apple-style toolbar
- Status bar integration
- Full-screen support
- Responsive layout

### EnhancedAppleComponents.swift
**Location**: `type/UI/EnhancedAppleComponents.swift`
**Purpose**: Apple-style UI components

**Key Components**:
- **EnhancedAppleToolbar**: Professional toolbar with all controls
- **EnhancedAppleStatusBar**: Status information display
- **EnhancedAppleToolbarButton**: Consistent button styling
- **AppleDivider**: Subtle dividers
- **AnimationSpeed**: Configurable animation speeds

**Design Philosophy**:
- Light mode only for consistency
- Translucent materials (.ultraThinMaterial)
- Native macOS styling
- Subtle animations and micro-interactions
- Professional button styles
- Consistent spacing (8px grid)

### TemplateSelectorView.swift
**Location**: `type/UI/TemplateSelectorView.swift`
**Purpose**: Template selection interface

**Key Features**:
- Template categories
- Template previews
- Template customization
- Template management

---

## 🔑 Key Files Explained

### typeApp.swift
**Location**: `type/typeApp.swift`
**Purpose**: Application entry point

**Key Features**:
- App initialization
- Main window configuration
- Light mode enforcement
- Modular app view integration

### SceneEditViews.swift
**Location**: `type/SceneEditViews.swift`
**Purpose**: Scene editing interface

**Key Features**:
- Scene editing forms
- Scene metadata management
- Scene validation
- Scene templates

### KeyboardShortcutsManager.swift
**Location**: `type/Utils/KeyboardShortcutsManager.swift`
**Purpose**: Keyboard shortcut handling

**Key Features**:
- Shortcut registration
- Shortcut conflict resolution
- Customizable shortcuts
- Shortcut help system

---

## 🛠️ Development Workflow

### Architecture Patterns Used

1. **Coordinator Pattern**: Each feature has its own coordinator
2. **MVVM Pattern**: ViewModels manage UI state
3. **Service Layer Pattern**: Business logic separated into services
4. **Repository Pattern**: Data access abstracted through repositories
5. **Observer Pattern**: Combine framework for reactive programming

### Code Organization Principles

1. **Single Responsibility**: Each file has one clear purpose
2. **Dependency Injection**: Services injected into coordinators
3. **Protocol-Oriented Programming**: Swift protocols for flexibility
4. **Modular Design**: Independent modules with clear interfaces
5. **Apple Guidelines**: Follows macOS design and development guidelines

### State Management

1. **Combine Framework**: Reactive state management
2. **@Published Properties**: Automatic UI updates
3. **ObservableObject**: SwiftUI integration
4. **Centralized State**: AppCoordinator manages global state
5. **Local State**: Each coordinator manages its own domain

---

## 🚀 Build and Installation

### Prerequisites
- macOS 12.0 or later
- Xcode 14.0 or later
- Swift 5.7 or later

### Build Process
1. Open `type.xcodeproj` in Xcode
2. Select target device (macOS)
3. Build and run (Cmd+R)

### Project Configuration
- **Target**: macOS application
- **Deployment Target**: macOS 12.0
- **Language**: Swift 5.7
- **UI Framework**: SwiftUI
- **Architecture**: Modular coordinator pattern

### Dependencies
- **SwiftUI**: Native UI framework
- **Combine**: Reactive programming
- **Foundation**: Core system functionality
- **UniformTypeIdentifiers**: File type handling

---

## 📈 Performance Considerations

### Memory Management
- Lazy loading for large documents
- Background parsing to prevent UI blocking
- Efficient text processing algorithms
- Proper cleanup in deinit methods

### UI Performance
- SwiftUI optimizations
- Efficient list rendering
- Background processing
- Smooth animations

### File Operations
- Asynchronous file operations
- Progress indicators
- Error handling and recovery
- Auto-save optimization

---

## 🔮 Future Enhancements

### Planned Features
1. **iCloud Sync**: Cross-device document access
2. **Advanced Export**: Professional PDF/FDX export
3. **Multiple Cursors**: Enhanced batch editing
4. **Code Folding**: Advanced document organization
5. **Bookmarks**: Quick navigation system
6. **Split Editor**: Multiple editor panes
7. **Minimap**: Document overview
8. **AI Assistance**: Smart writing suggestions
9. **Voice Dictation**: Speech-to-text support
10. **Industry Integration**: Production software connectivity

### Technical Improvements
1. **Unit Testing**: Comprehensive test coverage
2. **Performance Profiling**: Identify bottlenecks
3. **Code Documentation**: Comprehensive documentation
4. **Error Handling**: Robust error management
5. **Localization**: Multi-language support
6. **Security**: Enhanced data protection

---

## 📚 Additional Resources

### Documentation Files
- `Readme.md`: Main project documentation
- `BUILD_INSTALL.md`: Build and installation guide
- `BUILD_SCRIPTS_README.md`: Build script documentation
- `CHARACTER_DATABASE_README.md`: Character system documentation
- `MODULAR_ARCHITECTURE.md`: Architecture details
- `MODULAR_IMPLEMENTATION_SUMMARY.md`: Implementation summary
- `ADVANCED_EDITOR_FEATURES_SUMMARY.md`: Editor features
- `BEAT_ANALYSIS_AND_IMPROVEMENTS.md`: Analysis improvements
- `IMPROVEMENT_TODO.md`: Development roadmap

### Build Scripts
- `build_and_install.sh`: Automated build and installation
- `test_app.sh`: Application testing
- `test_character_database.sh`: Character system testing
- `test_modular_architecture.sh`: Architecture testing
- `test_outline_mode.sh`: Outline mode testing

---

## 🤝 Contributing

### Development Guidelines
1. Follow Swift style guidelines
2. Use coordinator pattern for new features
3. Implement proper error handling
4. Add unit tests for new functionality
5. Update documentation for changes
6. Follow Apple design guidelines

### Code Review Process
1. Feature branch creation
2. Implementation with tests
3. Documentation updates
4. Code review submission
5. Integration and testing
6. Release preparation

---

This comprehensive documentation provides a complete overview of the Type codebase, its architecture, components, and development workflow. The modular design ensures maintainability and extensibility while following Apple's design and development guidelines. 