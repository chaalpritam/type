//
//  DocumentController.swift
//  type
//
//  Document-Based MVC Architecture - Base Controller
//  Inspired by Beat's BeatDocumentBaseController
//
//  This class is the cross-platform base class for document handling.
//  It manages document state, parser, registered views, and core functionality.
//

import Foundation
import AppKit
import Combine

// MARK: - Document Controller
/// Base controller for document-based editing
/// Mirrors Beat's BeatDocumentBaseController - handles document state, parsing, and view registration
@MainActor
class DocumentController: NSObject, ObservableObject, DocumentDelegate, EditorDelegate {
    
    // MARK: - Published Properties
    
    @Published var text: String = ""
    @Published var isDocumentLoading: Bool = false
    @Published var isDocumentModified: Bool = false
    @Published var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @Published var lastEditedRange: NSRange = NSRange(location: 0, length: 0)
    @Published var revisionMode: Bool = false
    @Published var editorMode: EditorMode = .editing
    @Published var sidebarVisible: Bool = true
    
    // MARK: - Document Identity
    
    let documentId: UUID = UUID()
    
    // MARK: - Settings
    
    let documentSettings: DocumentSettings = DocumentSettings()
    let exportSettings: ExportSettings = ExportSettings()
    
    // MARK: - Parser
    
    lazy var parser: FountainParser = FountainParser()
    
    // MARK: - Document State
    
    var contentBuffer: String?
    var documentIsLoading: Bool { isDocumentLoading }
    var disableFormatting: Bool = false
    var hideFountainMarkup: Bool = false
    
    // MARK: - Editor Properties
    
    var documentWidth: CGFloat = 612  // US Letter width
    var magnification: CGFloat = 1.0
    
    // MARK: - Page Settings
    
    @Published var pageSize: PageSize = .usLetter
    @Published var printSceneNumbers: Bool = true
    @Published var showSceneNumberLabels: Bool = true
    @Published var showPageNumbers: Bool = true
    
    // MARK: - Data Cache
    
    /// Cached attributed text for thread-safe access
    private var _attributedTextCache: NSAttributedString?
    var attributedTextCache: NSAttributedString? {
        return _attributedTextCache
    }
    
    /// Data cache for safe saving
    private var dataCache: Data?
    
    // MARK: - Undo Manager
    
    private var _undoManager: UndoManager?
    var documentUndoManager: UndoManager? {
        get { _undoManager }
        set { _undoManager = newValue }
    }
    
    // MARK: - File Info
    
    var fileURL: URL?
    
    var fileNameString: String {
        return fileURL?.lastPathComponent.replacingOccurrences(of: ".fountain", with: "") ?? "Untitled"
    }
    
    var displayName: String {
        return fileNameString
    }
    
    var isDark: Bool {
        return NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }
    
    var contentLocked: Bool {
        return documentSettings.locked
    }
    
    // MARK: - Registered Views (Beat Pattern)
    
    /// Registered editor views that need updating when content changes
    private var registeredViews: Set<AnyHashable> = []
    private var registeredViewsArray: [EditorView] = []
    
    /// Registered outline views that need updating when outline changes
    private var registeredOutlineViewsArray: [SceneOutlineView] = []
    
    /// Selection observers
    private var registeredSelectionObserversArray: [SelectionObserver] = []
    
    // MARK: - Current State
    
    var currentLine: FountainElement? {
        // Find the element at the current cursor position
        return parser.elements.first { element in
            guard let range = element.range else { return false }
            return selectedRange.location >= range.location && 
                   selectedRange.location <= range.location + range.length
        }
    }
    
    var currentScene: OutlineScene? {
        // Find the scene at the current cursor position
        return outline.last { scene in
            scene.position <= selectedRange.location
        }
    }
    
    var outline: [OutlineScene] {
        // Convert parser elements to outline scenes
        var scenes: [OutlineScene] = []
        var sceneNumber = 1
        
        for element in parser.elements where element.type == .sceneHeading {
            let scene = OutlineScene(
                sceneNumber: "\(sceneNumber)",
                string: element.text,
                position: element.range?.location ?? 0,
                length: element.range?.length ?? element.text.count,
                type: .scene
            )
            scenes.append(scene)
            sceneNumber += 1
        }
        
        return scenes
    }
    
    // MARK: - Combine
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Change Listeners (Beat Pattern)
    
    private var changeListeners: [ObjectIdentifier: (NSRange) -> Void] = [:]
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        _undoManager = UndoManager()
        let id = documentId
        Logger.document.info("DocumentController initialized with ID: \(id.uuidString)")
    }
    
    deinit {
        let id = documentId
        Logger.document.info("DocumentController deinit: \(id.uuidString)")
    }
    
    // MARK: - Document Loading
    
    /// Load document content from a string (like Beat's readBeatDocumentString)
    @discardableResult
    func loadDocumentString(_ content: String) -> String {
        isDocumentLoading = true
        
        // Parse the content
        text = content
        parser.parse(content)
        
        // Update cache
        updateAttributedTextCache()
        
        isDocumentLoading = false
        isDocumentModified = false
        
        return content
    }
    
    /// Revert to given text
    func revertToText(_ newText: String) {
        text = newText
        parser.parse(newText)
        updateAttributedTextCache()
        isDocumentModified = false
        updateEditorViewsInBackground()
    }
    
    /// Load document from URL
    func loadDocument(from url: URL) throws {
        isDocumentLoading = true
        defer { isDocumentLoading = false }
        
        let content = try String(contentsOf: url, encoding: .utf8)
        fileURL = url
        loadDocumentString(content)
    }
    
    // MARK: - Document Saving
    
    /// Create the document file content for saving (like Beat's createDocumentFile)
    func createDocumentFile() -> String {
        // In Beat, this adds settings as a JSON block at the end
        // For now, we just return the text
        return text
    }
    
    /// Save document to URL
    func saveDocument(to url: URL) throws {
        let content = createDocumentFile()
        
        guard let data = content.data(using: .utf8) else {
            throw DocumentError.saveFailed
        }
        
        try data.write(to: url, options: .atomic)
        
        // Update cache on successful save
        dataCache = data
        fileURL = url
        isDocumentModified = false
        
        Logger.document.info("Document saved: \(url.lastPathComponent)")
    }
    
    // MARK: - Text Operations
    
    func updateText(_ newText: String) {
        let oldText = text
        text = newText
        
        // Record for undo
        documentUndoManager?.registerUndo(withTarget: self) { target in
            Task { @MainActor in
                target.updateText(oldText)
            }
        }
        
        // Update parser
        parser.parse(newText)
        
        // Update cache
        updateAttributedTextCache()
        
        // Mark as modified
        isDocumentModified = true
        
        // Notify change listeners
        notifyChangeListeners(range: lastEditedRange)
        
        // Update views
        textDidChange()
    }
    
    func getAttributedText() -> NSAttributedString {
        return _attributedTextCache ?? NSAttributedString(string: text)
    }
    
    private func updateAttributedTextCache() {
        // Create attributed string with basic styling
        let attributedString = NSMutableAttributedString(string: text)
        
        // Apply fountain highlighting
        let highlighter = FountainSyntaxHighlighter(text: text, font: .system(size: 12), baseColor: .primary)
        highlighter.highlight(attributedString, elements: parser.elements)
        
        _attributedTextCache = attributedString
    }
    
    // MARK: - Attribute Operations
    
    func addAttribute(_ key: NSAttributedString.Key, value: Any, range: NSRange) {
        guard let attrText = _attributedTextCache as? NSMutableAttributedString else { return }
        attrText.addAttribute(key, value: value, range: range)
        _attributedTextCache = attrText
    }
    
    func removeAttribute(_ key: NSAttributedString.Key, range: NSRange) {
        guard let attrText = _attributedTextCache as? NSMutableAttributedString else { return }
        attrText.removeAttribute(key, range: range)
        _attributedTextCache = attrText
    }
    
    func addAttributes(_ attributes: [NSAttributedString.Key: Any], range: NSRange) {
        guard let attrText = _attributedTextCache as? NSMutableAttributedString else { return }
        attrText.addAttributes(attributes, range: range)
        _attributedTextCache = attrText
    }
    
    // MARK: - Change Tracking
    
    private var lastCheckedText: String = ""
    
    func hasChanged() -> Bool {
        let changed = text != lastCheckedText
        if changed {
            lastCheckedText = text
        }
        return changed
    }
    
    func textDidChange() {
        // Update all registered views
        updateEditorViewsInBackground()
    }
    
    func markDocumentModified() {
        isDocumentModified = true
    }
    
    // MARK: - View Registration (Beat Pattern)
    
    func registerEditorView(_ view: EditorView) {
        registeredViewsArray.append(view)
        Logger.document.debug("Registered editor view. Count: \(self.registeredViewsArray.count)")
    }
    
    func unregisterEditorView(_ view: EditorView) {
        registeredViewsArray.removeAll { $0 === view }
        Logger.document.debug("Unregistered editor view. Count: \(self.registeredViewsArray.count)")
    }
    
    func registerOutlineView(_ view: SceneOutlineView) {
        registeredOutlineViewsArray.append(view)
        Logger.document.debug("Registered outline view. Count: \(self.registeredOutlineViewsArray.count)")
    }
    
    func unregisterOutlineView(_ view: SceneOutlineView) {
        registeredOutlineViewsArray.removeAll { $0 === view }
        Logger.document.debug("Unregistered outline view. Count: \(self.registeredOutlineViewsArray.count)")
    }
    
    func registerSelectionObserver(_ observer: SelectionObserver) {
        registeredSelectionObserversArray.append(observer)
        Logger.document.debug("Registered selection observer. Count: \(self.registeredSelectionObserversArray.count)")
    }
    
    func unregisterSelectionObserver(_ observer: SelectionObserver) {
        registeredSelectionObserversArray.removeAll { $0 === observer }
        Logger.document.debug("Unregistered selection observer. Count: \(self.registeredSelectionObserversArray.count)")
    }
    
    func updateEditorViewsInBackground() {
        Task { @MainActor in
            for view in self.registeredViewsArray where view.isVisible {
                view.reloadInBackground()
            }
        }
    }
    
    /// Update outline views with changes
    func outlineDidUpdate(changes: OutlineChanges?) {
        for view in registeredOutlineViewsArray where view.isVisible {
            view.reloadWithChanges(changes)
        }
    }
    
    /// Notify selection observers
    func selectionDidChange() {
        for observer in registeredSelectionObserversArray {
            observer.selectionDidChange(selectedRange)
        }
    }
    
    // MARK: - Change Listeners (Beat Pattern)
    
    func addChangeListener(_ listener: @escaping (NSRange) -> Void, owner: AnyObject) {
        let id = ObjectIdentifier(owner)
        changeListeners[id] = listener
    }
    
    func removeChangeListeners(for owner: AnyObject) {
        let id = ObjectIdentifier(owner)
        changeListeners.removeValue(forKey: id)
    }
    
    private func notifyChangeListeners(range: NSRange) {
        for listener in changeListeners.values {
            listener(range)
        }
    }
    
    // MARK: - Layout
    
    func ensureLayout() {
        // Override in subclasses
    }
    
    func updateLayout() {
        ensureLayout()
    }
    
    func refreshTextView() {
        // Override in subclasses
    }
    
    // MARK: - Scrolling
    
    func scrollToLine(_ line: Int) {
        // Override in subclasses
    }
    
    func scrollToRange(_ range: NSRange) {
        scrollToRange(range, callback: nil)
    }
    
    func scrollToRange(_ range: NSRange, callback: (() -> Void)?) {
        // Override in subclasses
        callback?()
    }
    
    func scrollToScene(_ scene: OutlineScene) {
        scrollToRange(scene.textRange)
    }
    
    // MARK: - Sidebar
    
    func toggleSidebar() {
        sidebarVisible.toggle()
    }
    
    // MARK: - Preview
    
    func invalidatePreview() {
        // Override in subclasses
    }
    
    func invalidatePreviewAt(_ index: Int) {
        // Override in subclasses
    }
    
    func resetPreview() {
        // Override in subclasses
    }
    
    // MARK: - Focus
    
    func focusEditor() {
        // Override in subclasses
    }
    
    func returnToEditor() {
        // Override in subclasses
    }
    
    // MARK: - Cleanup (Beat Pattern)
    
    /// Comprehensive cleanup - call before deallocation
    /// Inspired by Beat's unloadViews method
    func cleanup() {
        let id = documentId
        Logger.document.info("DocumentController cleanup started: \(id.uuidString)")
        
        // 1. Cancel all Combine subscriptions
        cancellables.removeAll()
        
        // 2. Remove all registered views
        registeredViewsArray.removeAll()
        registeredOutlineViewsArray.removeAll()
        registeredSelectionObserversArray.removeAll()
        
        // 3. Clear change listeners
        changeListeners.removeAll()
        
        // 4. Clear caches
        _attributedTextCache = nil
        dataCache = nil
        contentBuffer = nil
        
        // 5. Clear parser state
        parser.elements.removeAll()
        parser.titlePage.removeAll()
        
        Logger.document.info("DocumentController cleanup completed: \(id.uuidString)")
    }
}
