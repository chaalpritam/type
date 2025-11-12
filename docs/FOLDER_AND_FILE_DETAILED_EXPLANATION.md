# Type - Detailed Folder and File Explanation

## 📁 Complete File Structure Analysis

This document provides a detailed explanation of every folder and file in the Type codebase, including their purposes, relationships, and key functionality.

---

## 🏠 Root Directory

### Main Project Files

#### `typeApp.swift`
**Location**: `type/typeApp.swift`
**Purpose**: Application entry point and main app configuration
**Key Features**:
- `@main` struct that initializes the SwiftUI app
- Configures the main window with `ModularAppView`
- Enforces light mode for consistent appearance
- Sets up the app's initial state

**Code Structure**:
```swift
@main
struct typeApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            ModularAppView()
                .preferredColorScheme(.light)
        }
    }
}
```

#### `type.entitlements`
**Location**: `type/type.entitlements`
**Purpose**: App permissions and capabilities configuration
**Key Features**:
- Defines app sandbox permissions
- Configures file access capabilities
- Sets up network permissions for collaboration
- Defines app security requirements

#### `SceneEditViews.swift`
**Location**: `type/SceneEditViews.swift`
**Purpose**: Scene editing interface components
**Key Features**:
- Scene editing forms and validation
- Scene metadata management
- Scene template integration
- Scene relationship mapping

---

## 🎯 Core Directory

### `Core/AppCoordinator.swift`
**Purpose**: Central coordinator managing app state and module coordination
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

**Key Methods**:
- `setupBindings()`: Sets up Combine subscriptions
- `handleDocumentChange()`: Updates all coordinators when document changes
- `init()`: Initializes all coordinators and services

### `Core/ModuleCoordinator.swift`
**Purpose**: Base protocol for all feature coordinators
**Key Features**:
- Defines common interface for all coordinators
- Provides base functionality for document management
- Ensures consistent behavior across modules

**Protocol Definition**:
```swift
protocol ModuleCoordinator: ObservableObject {
    associatedtype ModuleView: View
    func createView() -> ModuleView
    func updateDocument(_ document: ScreenplayDocument?)
}
```

---

## 📊 Data Directory

### `Data/ScreenplayDocument.swift`
**Purpose**: Main document data structure and metadata
**Key Models**:

**ScreenplayDocument**:
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

**DocumentStatus**:
```swift
enum DocumentStatus: String, CaseIterable, Codable {
    case draft = "Draft"
    case inProgress = "In Progress"
    case review = "Review"
    case final = "Final"
    case archived = "Archived"
}
```

### `Data/CharacterModels.swift`
**Purpose**: Character data structures and relationships
**Key Models**:
- Character profiles with photos and descriptions
- Character relationships and arcs
- Character statistics and metrics
- Character dialogue analysis

### `Data/OutlineModels.swift`
**Purpose**: Outline and structure data models
**Key Models**:
- Outline hierarchy and organization
- Scene and section management
- Outline metadata and statistics
- Story structure templates

### `Data/SceneModels.swift`
**Purpose**: Scene data structures and metadata
**Key Models**:
- Scene information and metadata
- Scene statistics and analysis
- Scene relationships and connections
- Scene templates and formatting

### `Data/TimelineModels.swift`
**Purpose**: Timeline data structures and events
**Key Models**:
- Timeline events and milestones
- Story structure visualization
- Timeline metadata and analysis
- Event relationships and dependencies

---

## 🚀 Features Directory

## Editor Module (`Features/Editor/`)

### `EditorCoordinator.swift`
**Purpose**: Main editor state management and coordination
**Key Features**:
- Manages editor state (text, preview, help, etc.)
- Coordinates between editor components
- Handles text updates and parsing
- Manages undo/redo functionality

**Key Properties**:
```swift
@Published var text: String = ""
@Published var showPreview: Bool = true
@Published var showHelp: Bool = false
@Published var wordCount: Int = 0
@Published var pageCount: Int = 0
@Published var canUndo: Bool = false
@Published var canRedo: Bool = false
```

**Key Methods**:
- `updateText()`: Updates text and triggers parsing
- `performUndo()`: Handles undo operations
- `performRedo()`: Handles redo operations
- `togglePreview()`: Shows/hides preview
- `selectTemplate()`: Applies screenplay templates

### `FountainTextEditor.swift`
**Purpose**: Core text editing functionality
**Key Features**:
- Basic text editing with Fountain syntax
- Real-time text processing
- Cursor management
- Text selection handling

### `EnhancedFountainTextEditor.swift`
**Purpose**: Advanced text editing features
**Key Features**:
- Multiple cursors support
- Advanced text manipulation
- Enhanced keyboard shortcuts
- Custom text processing

### `FountainParser.swift`
**Purpose**: Real-time Fountain syntax parsing
**Key Features**:
- Parses Fountain format elements
- Generates structured document data
- Handles syntax validation
- Provides parsing statistics

**Key Elements Parsed**:
- Scene headings (`INT. LOCATION - TIME`)
- Character names (`CHARACTER NAME`)
- Dialogue and parentheticals
- Transitions (`FADE OUT`, `CUT TO:`)
- Sections and notes
- Title page metadata

### `FountainSyntaxHighlighter.swift`
**Purpose**: Syntax highlighting for Fountain elements
**Key Features**:
- Color-coded Fountain elements
- Real-time highlighting updates
- Customizable color schemes
- Syntax error highlighting

### `ScreenplayPreview.swift`
**Purpose**: Live preview rendering
**Key Features**:
- Professional screenplay formatting
- A4-style layout
- Real-time preview updates
- Export-ready formatting

### `AutoCompletionManager.swift`
**Purpose**: Smart text completion
**Key Features**:
- Character name suggestions
- Scene heading templates
- Transition suggestions
- Context-aware completions

### `SmartFormattingManager.swift`
**Purpose**: Automatic text formatting
**Key Features**:
- Auto-capitalization of character names
- Proper spacing and indentation
- Automatic formatting rules
- Custom formatting options

### `TextHistoryManager.swift`
**Purpose**: Undo/redo functionality
**Key Features**:
- Text history tracking
- Undo/redo operations
- State management
- History limits and cleanup

### `FindReplaceView.swift`
**Purpose**: Search and replace interface
**Key Features**:
- Find and replace functionality
- Regex support
- Case-sensitive options
- Replace all functionality

### `FountainHelpView.swift`
**Purpose**: Built-in help system
**Key Features**:
- Fountain syntax guide
- Interactive examples
- Quick reference
- Context-sensitive help

### `AdvancedEditorFeatures.swift`
**Purpose**: Advanced editing capabilities
**Key Features**:
- Focus mode
- Typewriter mode
- Advanced text manipulation
- Custom editor modes

### `MultipleCursorsTextEditor.swift`
**Purpose**: Multi-cursor editing
**Key Features**:
- Multiple cursor support
- Batch editing operations
- Cursor synchronization
- Advanced cursor management

### `CodeFoldingManager.swift`
**Purpose**: Code folding functionality
**Key Features**:
- Scene and section folding
- Collapsible regions
- Folding indicators
- Custom folding rules

### `MinimapView.swift`
**Purpose**: Document overview
**Key Features**:
- Document structure visualization
- Quick navigation
- Overview of document layout
- Scroll position indicator

### `SpellCheckTextEditor.swift`
**Purpose**: Spell checking functionality
**Key Features**:
- Real-time spell checking
- Screenplay-specific dictionaries
- Custom word lists
- Spell check suggestions

### `FountainTemplate.swift`
**Purpose**: Pre-built screenplay templates
**Key Features**:
- Template categories (TV, Film, Short)
- Template customization
- Template management
- Template export/import

## Characters Module (`Features/Characters/`)

### `CharacterCoordinator.swift`
**Purpose**: Character management coordination
**Key Features**:
- Character database management
- Character state coordination
- Character UI coordination
- Character data synchronization

### `CharacterDatabase.swift`
**Purpose**: Character data storage and retrieval
**Key Features**:
- Character CRUD operations
- Character search and filtering
- Character statistics
- Character export/import

### `CharacterViews.swift`
**Purpose**: Main character interface
**Key Features**:
- Character list view
- Character grid view
- Character search interface
- Character navigation

### `CharacterDetailViews.swift`
**Purpose**: Character detail panels
**Key Features**:
- Character profile display
- Character information editing
- Character photo management
- Character metadata display

### `CharacterDetailViews2.swift`
**Purpose**: Enhanced character details
**Key Features**:
- Advanced character information
- Character relationship mapping
- Character arc visualization
- Character statistics display

### `CharacterEditViews.swift`
**Purpose**: Character editing interface
**Key Features**:
- Character creation forms
- Character editing forms
- Character validation
- Character template integration

## Outline Module (`Features/Outline/`)

### `OutlineCoordinator.swift`
**Purpose**: Outline management coordination
**Key Features**:
- Outline state management
- Outline UI coordination
- Outline data synchronization
- Outline navigation

### `OutlineDatabase.swift`
**Purpose**: Outline data storage
**Key Features**:
- Outline CRUD operations
- Outline hierarchy management
- Outline search and filtering
- Outline export/import

### `OutlineViews.swift`
**Purpose**: Main outline interface
**Key Features**:
- Outline tree view
- Outline list view
- Outline navigation
- Outline search

### `OutlineDetailViews.swift`
**Purpose**: Detailed outline views
**Key Features**:
- Outline detail display
- Outline editing interface
- Outline metadata
- Outline statistics

## Collaboration Module (`Features/Collaboration/`)

### `CollaborationCoordinator.swift`
**Purpose**: Collaboration state management
**Key Features**:
- Collaboration state coordination
- User management
- Real-time collaboration
- Collaboration UI coordination

### `CollaborationManager.swift`
**Purpose**: Real-time collaboration logic
**Key Features**:
- Real-time editing
- Conflict resolution
- User presence
- Document synchronization

### `CollaborationViews.swift`
**Purpose**: Collaboration interface
**Key Features**:
- Comments interface
- Version history
- User management
- Sharing interface

## File Module (`Features/File/`)

### `FileCoordinator.swift`
**Purpose**: File operation coordination
**Key Features**:
- File operation management
- File UI coordination
- File state management
- File error handling

## Scenes Module (`Features/Scenes/`)

### `SceneDatabase.swift`
**Purpose**: Scene data management
**Key Features**:
- Scene CRUD operations
- Scene organization
- Scene metadata
- Scene statistics

### `SceneViews.swift`
**Purpose**: Scene interface
**Key Features**:
- Scene list view
- Scene grid view
- Scene navigation
- Scene search

### `SceneDetailViews.swift`
**Purpose**: Scene detail panels
**Key Features**:
- Scene detail display
- Scene editing interface
- Scene metadata
- Scene statistics

## Timeline Module (`Features/Timeline/`)

### `TimelineDatabase.swift`
**Purpose**: Timeline data management
**Key Features**:
- Timeline CRUD operations
- Event management
- Timeline organization
- Timeline metadata

### `TimelineViews.swift`
**Purpose**: Timeline visualization
**Key Features**:
- Timeline display
- Event visualization
- Timeline navigation
- Timeline interaction

---

## 🔧 Services Directory

### `Services/DocumentService.swift`
**Purpose**: Centralized document lifecycle management
**Key Features**:
- Document creation, loading, and saving
- Auto-save functionality (every 30 seconds)
- Recent files management
- Document modification tracking

**Key Methods**:
```swift
func newDocument() -> Void
func loadDocument(from url: URL) async throws
func saveDocument() async throws
func saveDocumentAs() async throws -> URL?
func updateDocumentContent(_ content: String) -> Void
func toggleAutoSave() -> Void
```

**Error Handling**:
```swift
enum DocumentError: LocalizedError {
    case noDocument
    case noSaveLocation
    case saveFailed
    case loadFailed
}
```

### `Services/FileManagementService.swift`
**Purpose**: High-level file operations and management
**Key Features**:
- File picker integration
- Export functionality
- File format handling
- Permission management

### `Services/SettingsService.swift`
**Purpose**: User preferences and settings management
**Key Features**:
- User preferences storage
- Default settings management
- Settings validation
- Settings export/import

### `Services/StatisticsService.swift`
**Purpose**: Analytics and document statistics
**Key Features**:
- Word count calculation
- Page count estimation
- Character count tracking
- Writing progress metrics

### `Services/FileManager.swift`
**Purpose**: Low-level file system operations
**Key Features**:
- File system operations
- Directory management
- File permissions
- Error handling

---

## 🎨 UI Directory

### `UI/ModularAppView.swift`
**Purpose**: Main app container and layout
**Key Features**:
- Modular content switching
- Enhanced Apple-style toolbar
- Status bar integration
- Full-screen support

**Key Components**:
- `ModularAppView`: Main app container
- `ModularToolbar`: Professional toolbar
- `ModularSidebar`: Navigation sidebar
- `ModularContentView`: Content area
- `ModularStatusBar`: Status information

### `UI/EnhancedAppleComponents.swift`
**Purpose**: Apple-style UI components
**Key Components**:

**EnhancedAppleToolbar**:
- Professional toolbar with all controls
- File operations (New, Open, Save, Export)
- Edit operations (Undo, Redo, Find/Replace)
- View controls (Preview, Line Numbers, Help)
- Collaboration controls (Comments, Versions, Share)
- Template and character database access

**EnhancedAppleStatusBar**:
- Document information display
- Statistics (Words, Pages, Characters)
- Smart formatting status
- Auto-save indicator
- Document modification status

**EnhancedAppleToolbarButton**:
- Consistent button styling
- Hover effects and animations
- Disabled state handling
- Icon and label support

**AppleDivider**:
- Subtle dividers for visual separation
- Consistent styling across the app

**AnimationSpeed**:
- Configurable animation speeds (Slow, Normal, Fast)
- Animation duration management
- Speed indicator icons

### `UI/TemplateSelectorView.swift`
**Purpose**: Template selection interface
**Key Features**:
- Template categories
- Template previews
- Template customization
- Template management

---

## 🛠️ Utils Directory

### `Utils/KeyboardShortcutsManager.swift`
**Purpose**: Keyboard shortcut handling
**Key Features**:
- Shortcut registration
- Shortcut conflict resolution
- Customizable shortcuts
- Shortcut help system

**Key Shortcuts**:
- `Cmd+N`: New document
- `Cmd+O`: Open document
- `Cmd+S`: Save document
- `Cmd+Shift+S`: Save as
- `Cmd+F`: Find
- `Cmd+Z`: Undo
- `Cmd+Shift+Z`: Redo
- `Cmd+E`: Export
- `Cmd+H`: Help

---

## 🎨 Assets Directory

### `Assets.xcassets/`
**Purpose**: App icons and visual assets
**Key Components**:
- `AppIcon.appiconset/`: App icon in various sizes
- `AccentColor.colorset/`: App accent color
- `Contents.json`: Asset catalog configuration

---

## 📚 Documentation Files

### `Readme.md`
**Purpose**: Main project documentation
**Key Sections**:
- Project overview and features
- Getting started guide
- Fountain syntax reference
- Development roadmap
- TODO list with completed features

### `BUILD_INSTALL.md`
**Purpose**: Build and installation guide
**Key Sections**:
- Prerequisites and requirements
- Build process instructions
- Installation steps
- Troubleshooting guide

### `BUILD_SCRIPTS_README.md`
**Purpose**: Build script documentation
**Key Sections**:
- Script descriptions and usage
- Automation details
- Build process explanation
- Script customization

### `CHARACTER_DATABASE_README.md`
**Purpose**: Character system documentation
**Key Sections**:
- Character database features
- Character management workflow
- Character data structures
- Character system integration

### `MODULAR_ARCHITECTURE.md`
**Purpose**: Architecture details
**Key Sections**:
- Architecture overview
- Module relationships
- Coordinator pattern explanation
- Design principles

### `MODULAR_IMPLEMENTATION_SUMMARY.md`
**Purpose**: Implementation summary
**Key Sections**:
- Implementation details
- Code organization
- Best practices
- Development guidelines

### `ADVANCED_EDITOR_FEATURES_SUMMARY.md`
**Purpose**: Editor features documentation
**Key Sections**:
- Advanced editor capabilities
- Feature descriptions
- Usage instructions
- Configuration options

### `BEAT_ANALYSIS_AND_IMPROVEMENTS.md`
**Purpose**: Analysis improvements documentation
**Key Sections**:
- Analysis features
- Improvement suggestions
- Implementation details
- Future enhancements

### `IMPROVEMENT_TODO.md`
**Purpose**: Development roadmap
**Key Sections**:
- Planned features
- Priority levels
- Implementation timeline
- Development phases

---

## 🔧 Build Scripts

### `build_and_install.sh`
**Purpose**: Automated build and installation
**Key Features**:
- Project building
- Installation automation
- Error handling
- Build verification

### `test_app.sh`
**Purpose**: Application testing
**Key Features**:
- Automated testing
- Test execution
- Result reporting
- Error handling

### `test_character_database.sh`
**Purpose**: Character system testing
**Key Features**:
- Character database tests
- Character functionality verification
- Performance testing
- Integration testing

### `test_modular_architecture.sh`
**Purpose**: Architecture testing
**Key Features**:
- Module integration tests
- Coordinator pattern verification
- Service layer testing
- Architecture validation

### `test_outline_mode.sh`
**Purpose**: Outline mode testing
**Key Features**:
- Outline functionality tests
- Outline UI verification
- Outline data testing
- Outline integration testing

---

## 📁 Project Configuration

### `type.xcodeproj/`
**Purpose**: Xcode project configuration
**Key Components**:
- `project.pbxproj`: Project settings and build configuration
- `project.xcworkspace/`: Workspace configuration
- `xcuserdata/`: User-specific settings

### `typeTests/`
**Purpose**: Unit tests
**Key Components**:
- `typeTests.swift`: Main test suite
- Test configuration and setup

### `typeUITests/`
**Purpose**: UI tests
**Key Components**:
- `typeUITests.swift`: UI test suite
- `typeUITestsLaunchTests.swift`: Launch tests
- UI test configuration

---

## 🔄 File Relationships and Dependencies

### Core Dependencies
```
typeApp.swift
    ↓
ModularAppView.swift
    ↓
AppCoordinator.swift
    ↓
[Feature Coordinators]
    ↓
[Feature Views]
    ↓
[Services]
    ↓
[Data Models]
```

### Service Dependencies
```
DocumentService
    ↓
FileManagementService
    ↓
FileManager.swift
```

### Feature Dependencies
```
EditorCoordinator
    ↓
FountainParser
    ↓
FountainSyntaxHighlighter
    ↓
ScreenplayPreview
```

### Data Flow
```
User Input
    ↓
UI Components
    ↓
Coordinators
    ↓
Services
    ↓
Data Models
    ↓
Persistence
```

---

## 🎯 Key Design Patterns

### 1. Coordinator Pattern
- **AppCoordinator**: Central state management
- **Feature Coordinators**: Domain-specific coordination
- **Service Injection**: Dependencies injected into coordinators

### 2. MVVM Pattern
- **Views**: SwiftUI views for UI
- **ViewModels**: Coordinators as ViewModels
- **Models**: Data models and services

### 3. Service Layer Pattern
- **DocumentService**: Document lifecycle
- **FileManagementService**: File operations
- **SettingsService**: User preferences
- **StatisticsService**: Analytics

### 4. Repository Pattern
- **CharacterDatabase**: Character data access
- **OutlineDatabase**: Outline data access
- **SceneDatabase**: Scene data access
- **TimelineDatabase**: Timeline data access

### 5. Observer Pattern
- **Combine Framework**: Reactive programming
- **@Published Properties**: Automatic UI updates
- **ObservableObject**: SwiftUI integration

---

This detailed explanation provides a comprehensive understanding of every folder and file in the Type codebase, their purposes, relationships, and key functionality. The modular architecture ensures maintainability and extensibility while following Apple's design and development guidelines. 