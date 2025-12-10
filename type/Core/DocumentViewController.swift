//
//  DocumentViewController.swift
//  type
//
//  Document-Based MVC Architecture - View Controller
//  Inspired by Beat's BeatDocumentViewController
//
//  This class extends DocumentController with UI-specific functionality
//  and manages the main editor view.
//

import Foundation
import AppKit
import SwiftUI
import Combine

// MARK: - Document View Controller
/// View controller for document editing - extends DocumentController with UI functionality
/// Mirrors Beat's BeatDocumentViewController
@MainActor
final class DocumentViewController: DocumentController {
    
    // MARK: - Published UI State
    
    @Published var showPreview: Bool = false
    @Published var showOutline: Bool = true
    @Published var showWelcome: Bool = false
    @Published var showHelp: Bool = false
    @Published var showFindReplace: Bool = false
    @Published var showTemplateSelector: Bool = false
    @Published var isFocusMode: Bool = false
    @Published var isTypewriterMode: Bool = false
    
    // MARK: - Statistics
    
    @Published var wordCount: Int = 0
    @Published var characterCount: Int = 0
    @Published var pageCount: Int = 1
    
    // MARK: - Editor State
    
    @Published var canUndo: Bool = false
    @Published var canRedo: Bool = false
    
    // MARK: - Formatting Services
    
    /// Editor formatting handler - like Beat's BeatEditorFormatting
    lazy var formatting: EditorFormatting = EditorFormatting(delegate: self)
    
    /// Text I/O handler - like Beat's BeatTextIO
    lazy var textIO: TextIOHandler = TextIOHandler(delegate: self)
    
    /// Auto-completion handler - like Beat's BeatAutocomplete
    lazy var autoComplete: AutoCompleteHandler = AutoCompleteHandler(delegate: self)
    
    // MARK: - Preview
    
    /// Preview controller - like Beat's BeatPreviewController
    lazy var previewController: PreviewController = PreviewController(delegate: self)
    
    // MARK: - Revision Tracking
    
    /// Revision tracking - like Beat's BeatRevisions
    lazy var revisionTracking: RevisionTracking = RevisionTracking(delegate: self)
    
    // MARK: - Window Reference
    
    weak var documentWindow: NSWindow?
    
    // MARK: - Private Properties
    
    private var hasSetup: Bool = false
    private var statisticsTimer: Timer?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupViewController()
    }
    
    // MARK: - Setup
    
    private func setupViewController() {
        guard !hasSetup else { return }
        hasSetup = true
        
        Logger.document.info("DocumentViewController setup started")
        
        // Setup bindings
        setupBindings()
        
        // Setup statistics timer
        setupStatisticsTimer()
        
        Logger.document.info("DocumentViewController setup completed")
    }
    
    private func setupBindings() {
        // Observe text changes
        $text
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] newText in
                self?.updateStatistics(text: newText)
            }
            .store(in: &cancellables)
        
        // Observe undo manager
        NotificationCenter.default.publisher(for: .NSUndoManagerDidUndoChange)
            .sink { [weak self] _ in
                self?.updateUndoState()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .NSUndoManagerDidRedoChange)
            .sink { [weak self] _ in
                self?.updateUndoState()
            }
            .store(in: &cancellables)
    }
    
    private func setupStatisticsTimer() {
        statisticsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateStatisticsIfNeeded()
            }
        }
    }
    
    // MARK: - Document Loading Override
    
    override func loadDocumentString(_ content: String) -> String {
        let result = super.loadDocumentString(content)
        
        // Update UI state after loading
        updateStatistics(text: content)
        updateUndoState()
        
        // Create initial preview
        previewController.createPreview(range: NSRange(location: 0, length: 1), sync: false)
        
        return result
    }
    
    // MARK: - Text Update Override
    
    override func updateText(_ newText: String) {
        super.updateText(newText)
        
        // Update formatting
        formatting.formatChangedLines()
        
        // Update preview
        invalidatePreviewAt(lastEditedRange.location)
    }
    
    // MARK: - Statistics
    
    private func updateStatistics(text: String) {
        // Word count
        let words = text.split { $0.isWhitespace || $0.isNewline }
        wordCount = words.count
        
        // Character count
        characterCount = text.count
        
        // Page count (rough estimate: ~55 lines per page)
        let lines = text.components(separatedBy: .newlines)
        pageCount = max(1, lines.count / 55)
    }
    
    private var lastStatisticsText: String = ""
    
    private func updateStatisticsIfNeeded() {
        guard text != lastStatisticsText else { return }
        lastStatisticsText = text
        updateStatistics(text: text)
    }
    
    // MARK: - Undo/Redo
    
    private func updateUndoState() {
        canUndo = documentUndoManager?.canUndo ?? false
        canRedo = documentUndoManager?.canRedo ?? false
    }
    
    func performUndo() {
        documentUndoManager?.undo()
        updateUndoState()
    }
    
    func performRedo() {
        documentUndoManager?.redo()
        updateUndoState()
    }
    
    // MARK: - Preview
    
    override func invalidatePreview() {
        previewController.invalidatePreview()
    }
    
    override func invalidatePreviewAt(_ index: Int) {
        previewController.invalidatePreviewAt(index)
    }
    
    override func resetPreview() {
        previewController.resetPreview()
    }
    
    func togglePreview() {
        showPreview.toggle()
        if showPreview {
            previewController.renderOnScreen()
        }
    }
    
    // MARK: - UI Toggles
    
    func toggleOutline() {
        showOutline.toggle()
    }
    
    func toggleFocusMode() {
        isFocusMode.toggle()
    }
    
    func toggleTypewriterMode() {
        isTypewriterMode.toggle()
    }
    
    func toggleHelp() {
        showHelp.toggle()
    }
    
    func toggleFindReplace() {
        showFindReplace.toggle()
    }
    
    func toggleTemplateSelector() {
        showTemplateSelector.toggle()
    }
    
    // MARK: - Selection Override
    
    override func selectionDidChange() {
        super.selectionDidChange()
        
        // Update auto-complete
        autoComplete.updateSuggestions()
    }
    
    // MARK: - Focus
    
    override func focusEditor() {
        // Post notification for views to handle
        NotificationCenter.default.post(name: .focusEditor, object: self)
    }
    
    override func returnToEditor() {
        showPreview = false
        showHelp = false
        showFindReplace = false
        showTemplateSelector = false
        focusEditor()
    }
    
    // MARK: - Cleanup Override
    
    override func cleanup() {
        Logger.document.info("DocumentViewController cleanup started")
        
        // Stop timers
        statisticsTimer?.invalidate()
        statisticsTimer = nil
        
        // Cleanup services
        formatting.cleanup()
        textIO.cleanup()
        autoComplete.cleanup()
        previewController.cleanup()
        revisionTracking.cleanup()
        
        // Clear window reference
        documentWindow = nil
        
        // Call parent cleanup
        super.cleanup()
        
        Logger.document.info("DocumentViewController cleanup completed")
    }
}

// MARK: - Notification Names Extension
extension Notification.Name {
    static let focusEditor = Notification.Name("focusEditor")
}

// MARK: - Editor Formatting
/// Handles editor text formatting - like Beat's BeatEditorFormatting
@MainActor
class EditorFormatting {
    private weak var delegate: DocumentViewController?
    
    init(delegate: DocumentViewController) {
        self.delegate = delegate
    }
    
    func formatChangedLines() {
        // Format lines that have changed
        guard let delegate = delegate else { return }
        
        // Get changed lines from parser
        // Apply formatting to those lines
        delegate.parser.parse(delegate.text)
    }
    
    func formatAllLines() {
        guard let delegate = delegate else { return }
        delegate.parser.parse(delegate.text)
    }
    
    func cleanup() {
        delegate = nil
    }
}

// MARK: - Text IO Handler
/// Handles text input/output operations - like Beat's BeatTextIO
@MainActor
class TextIOHandler {
    private weak var delegate: DocumentViewController?
    
    init(delegate: DocumentViewController) {
        self.delegate = delegate
    }
    
    /// Insert text at a position
    func insertText(_ string: String, at position: Int) {
        guard let delegate = delegate else { return }
        var newText = delegate.text
        let index = newText.index(newText.startIndex, offsetBy: min(position, newText.count))
        newText.insert(contentsOf: string, at: index)
        delegate.updateText(newText)
    }
    
    /// Replace range with string
    func replaceRange(_ range: NSRange, with string: String) {
        guard let delegate = delegate else { return }
        guard let swiftRange = Range(range, in: delegate.text) else { return }
        var newText = delegate.text
        newText.replaceSubrange(swiftRange, with: string)
        delegate.updateText(newText)
    }
    
    /// Delete range
    func deleteRange(_ range: NSRange) {
        replaceRange(range, with: "")
    }
    
    func cleanup() {
        delegate = nil
    }
}

// MARK: - Auto Complete Handler
/// Handles auto-completion - like Beat's BeatAutocomplete
@MainActor
class AutoCompleteHandler {
    private weak var delegate: DocumentViewController?
    
    @Published var suggestions: [String] = []
    @Published var isActive: Bool = false
    
    init(delegate: DocumentViewController) {
        self.delegate = delegate
    }
    
    func updateSuggestions() {
        guard let delegate = delegate else { return }
        
        // Get current line type and suggest accordingly
        if let currentLine = delegate.currentLine {
            switch currentLine.type {
            case .character:
                // Suggest character names from the document
                suggestions = delegate.parser.elements
                    .filter { $0.type == .character }
                    .map { $0.text.uppercased() }
                    .unique()
            case .sceneHeading:
                // Suggest scene heading prefixes
                suggestions = ["INT.", "EXT.", "INT./EXT.", "I/E."]
            default:
                suggestions = []
            }
        } else {
            suggestions = []
        }
        
        isActive = !suggestions.isEmpty
    }
    
    func selectSuggestion(_ suggestion: String) {
        // Apply the suggestion
        isActive = false
        suggestions = []
    }
    
    func cleanup() {
        delegate = nil
        suggestions = []
        isActive = false
    }
}

// MARK: - Preview Controller
/// Handles preview rendering - like Beat's BeatPreviewController
@MainActor
class PreviewController {
    private weak var delegate: DocumentViewController?
    
    @Published var isRendering: Bool = false
    @Published var previewPages: [PreviewPage] = []
    
    init(delegate: DocumentViewController) {
        self.delegate = delegate
    }
    
    func createPreview(range: NSRange, sync: Bool) {
        guard let delegate = delegate else { return }
        
        isRendering = true
        
        if sync {
            renderPreview(text: delegate.text)
        } else {
            Task {
                renderPreview(text: delegate.text)
            }
        }
    }
    
    private func renderPreview(text: String) {
        // Create preview pages
        let lines = text.components(separatedBy: .newlines)
        var pages: [PreviewPage] = []
        var currentPage = PreviewPage(pageNumber: 1)
        var lineCount = 0
        
        for line in lines {
            currentPage.lines.append(line)
            lineCount += 1
            
            if lineCount >= 55 {
                pages.append(currentPage)
                currentPage = PreviewPage(pageNumber: pages.count + 1)
                lineCount = 0
            }
        }
        
        if !currentPage.lines.isEmpty {
            pages.append(currentPage)
        }
        
        previewPages = pages
        isRendering = false
    }
    
    func invalidatePreview() {
        previewPages = []
    }
    
    func invalidatePreviewAt(_ index: Int) {
        // Invalidate from specific index
        createPreview(range: NSRange(location: index, length: 1), sync: false)
    }
    
    func resetPreview() {
        previewPages = []
        createPreview(range: NSRange(location: 0, length: 1), sync: false)
    }
    
    func renderOnScreen() {
        guard let delegate = delegate else { return }
        createPreview(range: NSRange(location: 0, length: delegate.text.count), sync: true)
    }
    
    func cleanup() {
        delegate = nil
        previewPages = []
    }
}

// MARK: - Preview Page
struct PreviewPage: Identifiable {
    let id = UUID()
    let pageNumber: Int
    var lines: [String] = []
}

// MARK: - Revision Tracking
/// Handles revision tracking - like Beat's BeatRevisions
@MainActor
class RevisionTracking {
    private weak var delegate: DocumentViewController?
    
    @Published var revisions: [Revision] = []
    @Published var currentRevisionLevel: Int = 0
    
    init(delegate: DocumentViewController) {
        self.delegate = delegate
    }
    
    func addRevision(range: NSRange, type: RevisionType) {
        let revision = Revision(range: range, type: type, level: currentRevisionLevel)
        revisions.append(revision)
    }
    
    func removeRevision(at index: Int) {
        guard index < revisions.count else { return }
        revisions.remove(at: index)
    }
    
    func bakeRevisions() {
        // Convert revision markers to plain text
        revisions.removeAll()
    }
    
    func cleanup() {
        delegate = nil
        revisions = []
    }
}

// MARK: - Revision
struct Revision: Identifiable {
    let id = UUID()
    let range: NSRange
    let type: RevisionType
    let level: Int
    let timestamp: Date = Date()
}

// MARK: - Revision Type
enum RevisionType {
    case addition
    case deletion
    case modification
}

// MARK: - Array Extension
private extension Array where Element: Hashable {
    func unique() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
