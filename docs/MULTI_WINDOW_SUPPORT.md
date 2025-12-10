# Multi-Window Support

## Overview

Type now supports **multi-window functionality**, allowing users to open and work with multiple screenplay documents simultaneously in separate windows. This feature is inspired by professional screenwriting applications like Beat and provides a more flexible workflow for screenwriters working on multiple projects or comparing different versions of their work.

## Features

### ✨ Key Capabilities

1. **Multiple Document Windows**
   - Open multiple screenplay documents simultaneously
   - Each window has its own independent state and document
   - Windows can be arranged, resized, and managed independently

2. **Window Management**
   - Create new blank documents in new windows
   - Open existing documents in new windows
   - Switch between open windows via Window menu
   - Each window maintains its own undo/redo history

3. **Independent State**
   - Each window has its own `AppCoordinator` instance
   - Separate editor state, character database, outline, etc.
   - Changes in one window don't affect others

4. **Window Tracking**
   - WindowManager service tracks all open windows
   - Dynamic window list in Window menu
   - Focus and activate windows by clicking their name in the menu

## Architecture

### Components

#### 1. **WindowManager** (`Services/WindowManager.swift`)
Singleton service that manages all open windows:
- Registers and unregisters windows
- Tracks window titles and document IDs
- Manages active window state
- Provides window information for UI

```swift
class WindowManager: ObservableObject {
    static let shared = WindowManager()
    @Published var openWindows: [WindowInfo] = []
    @Published var activeWindowId: UUID?
    
    func registerWindow(id: UUID, documentId: UUID, title: String)
    func unregisterWindow(id: UUID)
    func updateWindowTitle(id: UUID, title: String)
    func focusWindow(_ windowId: UUID)
}
```

#### 2. **DocumentWindowView** (`UI/DocumentWindowView.swift`)
Wrapper view for each document window:
- Creates a unique `AppCoordinator` for each window
- Handles window lifecycle (setup/cleanup)
- Manages document loading
- Updates window titles automatically

```swift
struct DocumentWindowView: View {
    let windowId: UUID
    let documentURL: URL?
    @StateObject private var appCoordinator: AppCoordinator
    
    init(windowId: UUID, documentURL: URL? = nil)
}
```

#### 3. **Updated TypeStyleAppView** (`UI/TypeStyleAppView.swift`)
Modified to support dependency injection:
- Accepts optional `AppCoordinator` parameter
- Enables each window to have its own coordinator instance
- Maintains all existing functionality

```swift
struct TypeStyleAppView: View {
    @ObservedObject var appCoordinator: AppCoordinator
    
    init(appCoordinator: AppCoordinator? = nil)
}
```

#### 4. **Updated typeApp** (`typeApp.swift`)
Main app structure with multi-window support:
- Uses `WindowGroup` with unique IDs
- Provides window management commands
- Handles document opening in new windows

## Usage

### Opening New Windows

#### From Menu Bar
- **File → New Document** (⌘N): Creates a new blank document in a new window
- **File → New Window** (⌘⇧N): Opens another new window
- **File → Open Document...** (⌘O): Opens a document in a new window

#### From Keyboard
- `⌘N` - New document in new window
- `⌘⇧N` - New window
- `⌘O` - Open document dialog

### Managing Windows

#### Window Menu
The Window menu shows:
- Standard window commands (Minimize, Zoom, etc.)
- Toggle Sidebar (⌃⌘S)
- Toggle Preview (⌘⇧P)
- Toggle Outline (⌘⇧O)
- **List of all open windows** - Click to focus that window

#### Switching Between Windows
1. Use the Window menu to see all open documents
2. Click on a window name to bring it to front
3. Use standard macOS window management (Mission Control, etc.)

### Window Behavior

- **Independent State**: Each window maintains its own:
  - Document content
  - Undo/redo history
  - Editor state (cursor position, selection, etc.)
  - Character database
  - Outline structure
  - UI state (sidebar, preview, panels)

- **Auto-Save**: Each window auto-saves independently every 30 seconds

- **Window Titles**: Automatically update to show document name

## Implementation Details

### Window Lifecycle

1. **Window Creation**
   ```swift
   // User clicks "New Document"
   → openNewWindow() called
   → NSApp creates new WindowGroup instance
   → DocumentWindowView(windowId: UUID()) initialized
   → New AppCoordinator created for this window
   → Window registered with WindowManager
   ```

2. **Document Loading**
   ```swift
   // User opens existing document
   → openDocument() called
   → File picker shown
   → openDocumentInNewWindow(url:) called
   → New window created
   → Document loaded via notification
   → Window title updated
   ```

3. **Window Closing**
   ```swift
   // User closes window
   → DocumentWindowView.onDisappear triggered
   → cleanupWindow() called
   → Window unregistered from WindowManager
   → AppCoordinator deallocated
   ```

### State Management

Each window has its own:
- `AppCoordinator` - Central state manager
- `DocumentService` - Document management
- `EditorCoordinator` - Editor state
- `CharacterCoordinator` - Character database
- `OutlineCoordinator` - Outline structure
- `CollaborationCoordinator` - Collaboration features

This ensures complete isolation between windows.

### Notifications

New notification for document loading:
```swift
extension Notification.Name {
    static let loadDocumentInActiveWindow = Notification.Name("loadDocumentInActiveWindow")
}
```

## Benefits

### For Writers

1. **Compare Versions**: Open different versions side-by-side
2. **Multiple Projects**: Work on multiple screenplays simultaneously
3. **Reference Material**: Keep reference scripts open while writing
4. **Flexible Workflow**: Arrange windows as needed for your workflow

### Technical Benefits

1. **Isolated State**: No shared state between windows
2. **Memory Efficient**: Each window only loads what it needs
3. **Crash Resilient**: Issues in one window don't affect others
4. **Scalable**: Can support many windows without performance issues

## Future Enhancements

Potential improvements for multi-window support:

1. **Window Restoration**
   - Save and restore window positions on app restart
   - Remember which documents were open

2. **Window Tabs**
   - macOS native tab support
   - Group related documents in tabs

3. **Cross-Window Features**
   - Drag and drop between windows
   - Copy/paste scenes between documents
   - Compare mode with synchronized scrolling

4. **Window Templates**
   - Save window layouts
   - Quick workspace switching

5. **Document Linking**
   - Link related documents (e.g., different episodes)
   - Navigate between linked documents

## Troubleshooting

### Common Issues

**Q: Windows don't appear in Window menu**
- A: Make sure WindowManager is properly initialized as @StateObject

**Q: Document changes affect other windows**
- A: Check that each window has its own AppCoordinator instance

**Q: Window titles don't update**
- A: Verify onChange listener for currentDocumentName is working

**Q: Can't open same document twice**
- A: This is by design to prevent conflicts (can be changed if needed)

## Code Examples

### Opening a New Window Programmatically

```swift
// In typeApp.swift
private func openNewWindow() {
    NSApp.sendAction(#selector(NSDocumentController.newDocument(_:)), 
                     to: nil, from: nil)
}
```

### Focusing a Specific Window

```swift
private func focusWindow(_ windowId: UUID) {
    if let window = NSApp.windows.first(where: { 
        $0.identifier?.rawValue == windowId.uuidString 
    }) {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
```

### Loading a Document in Active Window

```swift
NotificationCenter.default.post(
    name: .loadDocumentInActiveWindow,
    object: nil,
    userInfo: ["url": documentURL]
)
```

## Testing

To test multi-window support:

1. **Basic Test**
   - Launch app
   - Press ⌘N to create new window
   - Verify two windows are open
   - Type in each window independently
   - Verify changes don't affect other window

2. **Document Opening**
   - Press ⌘O
   - Select a .fountain file
   - Verify it opens in new window
   - Open another document
   - Verify both are independent

3. **Window Menu**
   - Open multiple windows
   - Check Window menu shows all windows
   - Click on a window name
   - Verify it brings that window to front

4. **State Isolation**
   - Open two windows
   - Make changes in window 1
   - Verify window 2 is unaffected
   - Test undo/redo in each window independently

## Conclusion

Multi-window support transforms Type into a professional-grade screenwriting application, matching the capabilities of industry-standard tools like Beat and Final Draft. Writers can now work more efficiently with multiple documents, compare versions, and organize their workspace exactly as they need.
