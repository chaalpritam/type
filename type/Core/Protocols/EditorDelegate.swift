//
//  EditorDelegate.swift
//  type
//
//  Document-Based MVC Architecture - Inspired by Beat's BeatEditorDelegate
//  This protocol provides the core interface for editor functionality.
//

import Foundation
import AppKit

// MARK: - Editor View Protocol
/// Protocol for editor views that need to be updated when content changes
/// Mirrors Beat's BeatEditorView protocol
@MainActor
protocol EditorView: AnyObject {
    /// Reload the view in the background (async)
    func reloadInBackground()
    
    /// Reload the view immediately
    func reloadView()
    
    /// Whether the view is currently visible
    var isVisible: Bool { get }
}

// MARK: - Selection Observer Protocol
/// Protocol for views/objects that need to be updated when selection changes
/// Mirrors Beat's BeatSelectionObserver protocol
@MainActor
protocol SelectionObserver: AnyObject {
    func selectionDidChange(_ selectedRange: NSRange)
}

// MARK: - Scene Outline View Protocol
/// Protocol for views that display the outline structure
/// Mirrors Beat's BeatSceneOutlineView protocol
@MainActor
protocol SceneOutlineView: EditorView {
    /// Reload with specific changes
    func reloadWithChanges(_ changes: OutlineChanges?)
    
    /// Called when moving to a specific scene index
    func didMoveToSceneIndex(_ index: Int)
}

// MARK: - Outline Changes
/// Represents changes to the outline structure
struct OutlineChanges {
    var addedScenes: [Int] = []
    var removedScenes: [Int] = []
    var modifiedScenes: [Int] = []
    var movedScenes: [(from: Int, to: Int)] = []
    
    var hasChanges: Bool {
        return !addedScenes.isEmpty || !removedScenes.isEmpty || 
               !modifiedScenes.isEmpty || !movedScenes.isEmpty
    }
}

// MARK: - Text Editor Protocol
/// Protocol for text editor views
/// Mirrors Beat's BeatTextEditor protocol
@MainActor
protocol TextEditorProtocol: AnyObject {
    var text: String { get set }
    var typingAttributes: [NSAttributedString.Key: Any] { get set }
    
    func scrollToLine(_ line: Int)
    func scrollToRange(_ range: NSRange)
    func scrollToRange(_ range: NSRange, callback: (() -> Void)?)
    func scrollToScene(_ scene: OutlineScene)
}

// MARK: - Editor Delegate Protocol
/// Main protocol for the document editor controller
/// Inspired by Beat's BeatEditorDelegate - provides core functionality for document editing
@MainActor
protocol EditorDelegate: AnyObject {
    // MARK: - Document State
    
    /// Whether the document is currently loading
    var documentIsLoading: Bool { get }
    
    /// Cached attributed text for thread-safe access
    var attributedTextCache: NSAttributedString? { get }
    
    /// The undo manager for the document
    var documentUndoManager: UndoManager? { get }
    
    /// Whether formatting is currently disabled
    var disableFormatting: Bool { get }
    
    // MARK: - Document Information
    
    /// The document file name
    var fileNameString: String { get }
    
    /// Whether dark mode is enabled
    var isDark: Bool { get }
    
    /// Whether the document content is locked
    var contentLocked: Bool { get }
    
    // MARK: - Parser Access
    
    /// The current line at cursor position
    var currentLine: FountainElement? { get }
    
    /// The current scene at cursor position
    var currentScene: OutlineScene? { get }
    
    /// Get the attributed string content
    func getAttributedText() -> NSAttributedString
    
    // MARK: - Selection & Ranges
    
    /// Current selected range in the editor
    var selectedRange: NSRange { get set }
    
    /// The last edited range
    var lastEditedRange: NSRange { get }
    
    /// Document width for layout
    var documentWidth: CGFloat { get }
    
    /// Current magnification level
    var magnification: CGFloat { get }
    
    // MARK: - Text Operations
    
    /// Add an attribute to a range
    func addAttribute(_ key: NSAttributedString.Key, value: Any, range: NSRange)
    
    /// Remove an attribute from a range
    func removeAttribute(_ key: NSAttributedString.Key, range: NSRange)
    
    /// Add multiple attributes to a range
    func addAttributes(_ attributes: [NSAttributedString.Key: Any], range: NSRange)
    
    /// Check if text has changed since last query
    func hasChanged() -> Bool
    
    /// Force text reformat and editor view updates
    func textDidChange()
    
    /// Ensure the text view layout is up to date
    func ensureLayout()
    
    /// Update the layout
    func updateLayout()
    
    // MARK: - Scrolling
    
    /// Scroll to a specific line
    func scrollToLine(_ line: Int)
    
    /// Scroll to a range
    func scrollToRange(_ range: NSRange)
    
    /// Scroll to a range with callback
    func scrollToRange(_ range: NSRange, callback: (() -> Void)?)
    
    /// Scroll to a scene
    func scrollToScene(_ scene: OutlineScene)
    
    // MARK: - View Registration
    
    /// Register an editor view for updates
    func registerEditorView(_ view: EditorView)
    
    /// Unregister an editor view
    func unregisterEditorView(_ view: EditorView)
    
    /// Register an outline view for updates
    func registerOutlineView(_ view: SceneOutlineView)
    
    /// Unregister an outline view
    func unregisterOutlineView(_ view: SceneOutlineView)
    
    /// Register a selection observer
    func registerSelectionObserver(_ observer: SelectionObserver)
    
    /// Unregister a selection observer
    func unregisterSelectionObserver(_ observer: SelectionObserver)
    
    /// Update editor views in the background
    func updateEditorViewsInBackground()
    
    // MARK: - Editor State
    
    /// Whether revision mode is enabled
    var revisionMode: Bool { get set }
    
    /// Current editor mode
    var editorMode: EditorMode { get set }
    
    /// Whether fountain markup should be hidden
    var hideFountainMarkup: Bool { get }
    
    /// Toggle sidebar visibility
    func toggleSidebar()
    
    /// Whether the sidebar is visible
    var sidebarVisible: Bool { get }
    
    // MARK: - Preview
    
    /// Invalidate the preview
    func invalidatePreview()
    
    /// Invalidate preview at specific index
    func invalidatePreviewAt(_ index: Int)
    
    /// Reset the entire preview
    func resetPreview()
    
    // MARK: - Focus & Navigation
    
    /// Focus the editor
    func focusEditor()
    
    /// Switch to main editor view
    func returnToEditor()
    
    // MARK: - Document Operations
    
    /// Mark document as modified
    func markDocumentModified()
    
    /// Refresh the text view
    func refreshTextView()
}

// MARK: - Editor Mode
/// Represents the current editor mode
enum EditorMode: Int, CaseIterable {
    case editing = 0
    case tagging = 1
    case review = 2
    
    var displayName: String {
        switch self {
        case .editing: return "Edit"
        case .tagging: return "Tag"
        case .review: return "Review"
        }
    }
}

// MARK: - Outline Scene
/// Represents a scene in the outline
/// Similar to Beat's OutlineScene
class OutlineScene: Identifiable, Hashable {
    let id: UUID
    var sceneNumber: String?
    var string: String
    var position: Int
    var length: Int
    var type: OutlineSceneType
    var color: String?
    var synopsis: String?
    var notes: [String] = []
    var characters: [String] = []
    var omitted: Bool = false
    
    var textRange: NSRange {
        return NSRange(location: position, length: length)
    }
    
    init(id: UUID = UUID(), 
         sceneNumber: String? = nil,
         string: String, 
         position: Int, 
         length: Int, 
         type: OutlineSceneType = .scene) {
        self.id = id
        self.sceneNumber = sceneNumber
        self.string = string
        self.position = position
        self.length = length
        self.type = type
    }
    
    static func == (lhs: OutlineScene, rhs: OutlineScene) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Outline Scene Type
/// Type of scene in the outline
enum OutlineSceneType: Int {
    case scene = 0
    case section = 1
    case synopsis = 2
    case heading = 3
}
