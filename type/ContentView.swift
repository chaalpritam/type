//
//  ContentView.swift
//  type
//
//  Created by Chaal Pritam on 15/04/25.
//

import SwiftUI

struct ContentView: View {
    @State private var text: String = ""
    @State private var showPlaceholder: Bool = true
    @State private var showPreview: Bool = true
    @State private var showHelp: Bool = false
    @State private var showLineNumbers: Bool = true
    @State private var showFindReplace: Bool = false
    @State private var showAutoCompletion: Bool = true
    @State private var showTemplateSelector: Bool = false
    @State private var selectedTemplate: TemplateType = .default
    @FocusState private var isTextFieldFocused: Bool
    @StateObject private var fountainParser = FountainParser()
    @StateObject private var historyManager = TextHistoryManager()
    @StateObject private var autoCompletionManager = AutoCompletionManager()
    @StateObject private var smartFormattingManager = SmartFormattingManager()
    
    // File Management
    @StateObject private var fileManager = FileManager()
    @StateObject private var keyboardShortcutsManager: KeyboardShortcutsManager
    
    // Collaboration
    @StateObject private var collaborationManager: CollaborationManager
    @State private var showCommentsPanel: Bool = false
    @State private var showVersionHistory: Bool = false
    @State private var showCollaboratorsPanel: Bool = false
    @State private var showSharingDialog: Bool = false
    
    // Character Database
    @StateObject private var characterDatabase = CharacterDatabase()
    @State private var showCharacterDatabase: Bool = false
    
    // Outline Database
    @StateObject private var outlineDatabase = OutlineDatabase()
    @State private var showOutlineMode: Bool = false
    
    // Enhanced editor state
    @State private var wordCount: Int = 0
    @State private var pageCount: Int = 0
    @State private var characterCount: Int = 0
    @State private var canUndo: Bool = false
    @State private var canRedo: Bool = false
    
    // Apple-style interface states
    @State private var selectedFont: String = "SF Mono"
    @State private var fontSize: CGFloat = 13
    @State private var showStatistics: Bool = true
    @State private var isFullScreen: Bool = false
    
    // UI/UX Enhancement states
    @State private var showCustomizationPanel: Bool = false
    @State private var animationSpeed: AnimationSpeed = .normal
    @State private var showWritingGoals: Bool = false
    @State private var dailyWordGoal: Int = 1000
    @State private var currentDailyWords: Int = 0
    
    // File management states
    @State private var showSaveDialog: Bool = false
    @State private var showOpenDialog: Bool = false
    @State private var showExportDialog: Bool = false
    @State private var showUnsavedChangesAlert: Bool = false
    
    init() {
        let fileManager = FileManager()
        self._fileManager = StateObject(wrappedValue: fileManager)
        self._keyboardShortcutsManager = StateObject(wrappedValue: KeyboardShortcutsManager(fileManager: fileManager))
        self._collaborationManager = StateObject(wrappedValue: CollaborationManager(documentId: UUID().uuidString))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fixed light background
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced Apple-style toolbar with file operations
                    EnhancedAppleToolbar(
                        showPreview: $showPreview,
                        showLineNumbers: $showLineNumbers,
                        showFindReplace: $showFindReplace,
                        showHelp: $showHelp,
                        canUndo: canUndo,
                        canRedo: canRedo,
                        onUndo: performUndo,
                        onRedo: performRedo,
                        selectedFont: $selectedFont,
                        fontSize: $fontSize,
                        isFullScreen: $isFullScreen,
                        showCustomizationPanel: $showCustomizationPanel,
                        animationSpeed: $animationSpeed,
                        // File management callbacks
                        onNewDocument: newDocument,
                        onOpenDocument: openDocumentSync,
                        onSaveDocument: saveDocumentSync,
                        onSaveDocumentAs: saveDocumentAsSync,
                        onExportDocument: exportDocumentSync,
                        canSave: fileManager.canSave(),
                        isDocumentModified: fileManager.isDocumentModified,
                        currentDocumentName: fileManager.currentDocument?.url?.lastPathComponent ?? "Untitled",
                        // Collaboration parameters
                        showCommentsPanel: $showCommentsPanel,
                        showVersionHistory: $showVersionHistory,
                        showCollaboratorsPanel: $showCollaboratorsPanel,
                        showSharingDialog: $showSharingDialog,
                        collaboratorCount: collaborationManager.collaborators.count,
                        commentCount: collaborationManager.comments.count,
                        // Template selector
                        showTemplateSelector: $showTemplateSelector,
                        // Character database
                        showCharacterDatabase: $showCharacterDatabase,
                        characterCount: characterDatabase.statistics.totalCharacters,
                        // Outline database
                        showOutlineMode: $showOutlineMode,
                        outlineDatabase: outlineDatabase
                    )
                    
                    // Find/Replace Bar with enhanced animations
                    if showFindReplace {
                        EnhancedAppleFindReplaceView(isVisible: $showFindReplace, text: $text)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showFindReplace)
                    }
                    
                    // Main Content Area with enhanced animations
                HStack(spacing: 0) {
                    // Editor Panel
                        VStack(spacing: 0) {
                            // Enhanced editor header
                            EnhancedAppleEditorHeader(
                                wordCount: wordCount,
                                pageCount: pageCount,
                                characterCount: characterCount,
                                showStatistics: showStatistics,
                                showAutoCompletion: $showAutoCompletion,
                                showWritingGoals: $showWritingGoals,
                                dailyWordGoal: dailyWordGoal,
                                currentDailyWords: currentDailyWords
                            )
                            
                            // Enhanced editor content
                        ZStack(alignment: .topLeading) {
                                // Enhanced paper background
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                                // Enhanced Fountain Text Editor
                                EnhancedFountainTextEditor(
                                text: $text,
                                    placeholder: FountainTemplate.getTemplate(for: selectedTemplate),
                                    showLineNumbers: showLineNumbers,
                                    onTextChange: { newText in
                                        updateStatistics(text: newText)
                                        historyManager.addToHistory(newText)
                                        canUndo = historyManager.canUndo
                                        canRedo = historyManager.canRedo
                                        
                                        // Update auto-completion
                                        autoCompletionManager.updateSuggestions(for: newText, at: 0)
                                        
                                        // Apply smart formatting
                                        let formattedText = smartFormattingManager.formatText(newText)
                                        if formattedText != newText {
                                            text = formattedText
                                        }
                                        
                                        // Mark document as modified
                                        fileManager.markDocumentAsModified()
                                    }
                            )
                            .onChange(of: text) { oldValue, newValue in
                                showPlaceholder = newValue.isEmpty
                                // Parse Fountain syntax in real-time
                                fountainParser.parse(newValue)
                                    updateStatistics(text: newValue)
                                    
                                    // Update character database from parsed elements
                                    characterDatabase.parseCharactersFromFountain(fountainParser.elements)
                                    
                                    // Update document content
                                    if fileManager.currentDocument != nil {
                                        fileManager.currentDocument?.content = newValue
                                    }
                                }
                                
                                // Enhanced auto-completion overlay
                                if showAutoCompletion && autoCompletionManager.showSuggestions {
                                    EnhancedAppleAutoCompletionOverlay(
                                        suggestions: autoCompletionManager.suggestions,
                                        selectedIndex: autoCompletionManager.selectedIndex,
                                        onSelect: { suggestion in
                                            // TODO: Insert suggestion at cursor position
                                            autoCompletionManager.hideSuggestions()
                                        }
                                    )
                                    .transition(.scale.combined(with: .opacity))
                                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: autoCompletionManager.showSuggestions)
                                }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .frame(width: showPreview ? geometry.size.width * 0.5 : geometry.size.width)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .leading)
                        ))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showPreview)
                    
                        // Preview Panel with enhanced styling
                    if showPreview {
                            VStack(spacing: 0) {
                                // Enhanced preview header
                                EnhancedApplePreviewHeader(elementCount: fountainParser.elements.count)
                                
                                // Enhanced preview content
                            ScreenplayPreview(
                                elements: fountainParser.elements,
                                titlePage: fountainParser.titlePage
                            )
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .frame(width: geometry.size.width * 0.5)
                            .background(Color.white)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .trailing)
                            ))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showPreview)
                        }
                    }
                    
                    // Enhanced status bar with file management info
                    EnhancedAppleStatusBar(
                        wordCount: wordCount,
                        pageCount: pageCount,
                        characterCount: characterCount,
                        showStatistics: $showStatistics,
                        smartFormattingManager: smartFormattingManager,
                        animationSpeed: animationSpeed,
                        // File management info
                        autoSaveEnabled: fileManager.autoSaveEnabled,
                        isDocumentModified: fileManager.isDocumentModified,
                        currentDocumentName: fileManager.currentDocument?.url?.lastPathComponent ?? "Untitled"
                    )
                }
                
                // Template selector overlay
                if showTemplateSelector {
                    TemplateSelectorView(
                        selectedTemplate: $selectedTemplate,
                        isVisible: $showTemplateSelector,
                        onTemplateSelected: { template in
                            selectedTemplate = template
                            if text.isEmpty {
                                text = FountainTemplate.getTemplate(for: template)
                            }
                            showTemplateSelector = false
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showTemplateSelector)
                    .zIndex(1000)
                }
                
                // Customization panel overlay
                if showCustomizationPanel {
                    CustomizationPanel(
                        animationSpeed: $animationSpeed,
                        isVisible: $showCustomizationPanel
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCustomizationPanel)
                    .zIndex(1000)
                }
                
                // Help overlay
                if showHelp {
                    FountainHelpView(isPresented: $showHelp)
                        .transition(.opacity.combined(with: .scale))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showHelp)
                }
                
                // Collaboration panels
                if showCommentsPanel {
                    CommentsPanel(
                        collaborationManager: collaborationManager,
                        isVisible: $showCommentsPanel
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCommentsPanel)
                    .zIndex(1000)
                }
                
                if showVersionHistory {
                    VersionHistory(
                        collaborationManager: collaborationManager,
                        isVisible: $showVersionHistory
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showVersionHistory)
                    .zIndex(1000)
                }
                
                if showCollaboratorsPanel {
                    CollaboratorsPanel(
                        collaborationManager: collaborationManager,
                        isVisible: $showCollaboratorsPanel
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCollaboratorsPanel)
                    .zIndex(1000)
                }
                
                // Sharing dialog
                if showSharingDialog {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showSharingDialog = false
                        }
                    
                    SharingDialog(collaborationManager: collaborationManager)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showSharingDialog)
                        .zIndex(1001)
                }
            }
        }
        .onAppear {
            // Initialize with a new document and default template
            if fileManager.currentDocument == nil {
                fileManager.newDocument()
                text = FountainTemplate.getTemplate(for: selectedTemplate)
            }
        }
        // Character database sheet
        .sheet(isPresented: $showCharacterDatabase) {
            ZStack(alignment: .topTrailing) {
                CharacterDatabaseView(characterDatabase: characterDatabase, isVisible: $showCharacterDatabase)
                Button(action: { showCharacterDatabase = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .padding()
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
            }
        }
        // Outline mode sheet
        .sheet(isPresented: $showOutlineMode) {
            ZStack(alignment: .topTrailing) {
                OutlineView(outlineDatabase: outlineDatabase, isVisible: $showOutlineMode)
                Button(action: { showOutlineMode = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .padding()
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
            }
        }
        // File management alerts
        .alert("Save Changes?", isPresented: $showUnsavedChangesAlert) {
            Button("Save") {
                Task {
                    await saveDocument()
                }
            }
            Button("Don't Save") {
                // Proceed without saving
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Do you want to save the changes to this document?")
        }
    }
    
    // MARK: - File Management Functions
    
    private func newDocument() {
        if fileManager.hasUnsavedChanges() {
            showUnsavedChangesAlert = true
        } else {
            fileManager.newDocument()
            text = FountainTemplate.getTemplate(for: selectedTemplate)
        }
    }
    
    private func openDocument() {
        Task {
            do {
                _ = try await fileManager.openDocument()
            } catch {
                await showError("Failed to open document", error: error)
            }
        }
    }
    
    private func saveDocument() async {
        do {
            try await fileManager.saveDocument()
        } catch {
            await showError("Failed to save document", error: error)
        }
    }
    
    private func saveDocumentAs() async {
        do {
            _ = try await fileManager.saveDocumentAs()
        } catch {
            await showError("Failed to save document", error: error)
        }
    }
    
    private func exportDocument() {
        Task {
            let alert = NSAlert()
            alert.messageText = "Export Document"
            alert.informativeText = "Choose export format:"
            alert.addButton(withTitle: "PDF")
            alert.addButton(withTitle: "Final Draft")
            alert.addButton(withTitle: "Cancel")
            alert.alertStyle = .informational
            
            let response = await alert.beginSheetModal(for: NSApp.keyWindow!)
            
            switch response {
            case .alertFirstButtonReturn: // PDF
                do {
                    _ = try await fileManager.exportToPDF()
                } catch {
                    await showError("Failed to export PDF", error: error)
                }
            case .alertSecondButtonReturn: // Final Draft
                do {
                    _ = try await fileManager.exportToFinalDraft()
                } catch {
                    await showError("Failed to export Final Draft", error: error)
                }
            default:
                break
            }
        }
    }
    
    private func showError(_ message: String, error: Error) async {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        
        await alert.beginSheetModal(for: NSApp.keyWindow!)
    }
    
    // MARK: - Existing Functions
    
    private func performUndo() {
        if let previousText = historyManager.undo() {
            text = previousText
            canUndo = historyManager.canUndo
            canRedo = historyManager.canRedo
        }
    }
    
    private func performRedo() {
        if let nextText = historyManager.redo() {
            text = nextText
            canUndo = historyManager.canUndo
            canRedo = historyManager.canRedo
        }
    }
    
    private func updateStatistics(text: String) {
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        wordCount = words.count
        characterCount = text.count
        pageCount = max(1, wordCount / 250) // Rough estimate: 250 words per page
        
        // Update daily word count for writing goals
        currentDailyWords = wordCount
    }
    
    // 1. Synchronous wrappers for async file actions
    private func saveDocumentSync() { Task { await saveDocument() } }
    private func saveDocumentAsSync() { Task { await saveDocumentAs() } }
    private func openDocumentSync() { openDocument() }
    private func exportDocumentSync() { exportDocument() }
}

// MARK: - Template Selector View

struct TemplateSelectorView: View {
    @Binding var selectedTemplate: TemplateType
    @Binding var isVisible: Bool
    let onTemplateSelected: (TemplateType) -> Void
    
    @State private var selectedCategory: TemplateCategory = .basic
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isVisible = false
                }
            
            // Template selector card
            VStack(spacing: 20) {
                // Header with close button
                HStack {
                    Text("Choose Template")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: { isVisible = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                // Category selector
                Picker("Category", selection: $selectedCategory) {
                    ForEach(TemplateCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Templates grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(selectedCategory.templates, id: \.self) { template in
                            TemplateCard(
                                template: template,
                                isSelected: selectedTemplate == template,
                                onTap: {
                                    onTemplateSelected(template)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 400)
                
                // Bottom action buttons
                HStack {
                    Button("Cancel") {
                        isVisible = false
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Use Template") {
                        onTemplateSelected(selectedTemplate)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedTemplate == .default)
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 20)
            .frame(maxWidth: 600, maxHeight: 600)
        }
    }
}

struct TemplateCard: View {
    let template: TemplateType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(template.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.title3)
                    }
                }
                
                Text(template.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                // Template category badge
                Text(template.category.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.accentColor.opacity(0.1))
                    )
                    .foregroundColor(.accentColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Animation Speed Enum
enum AnimationSpeed: String, CaseIterable {
    case slow = "Slow"
    case normal = "Normal"
    case fast = "Fast"
    
    var duration: Double {
        switch self {
        case .slow: return 0.8
        case .normal: return 0.4
        case .fast: return 0.2
        }
    }
    
    var icon: String {
        switch self {
        case .slow: return "tortoise"
        case .normal: return "speedometer"
        case .fast: return "hare"
        }
    }
}

// MARK: - Enhanced Apple-style Toolbar
struct EnhancedAppleToolbar: View {
    @Binding var showPreview: Bool
    @Binding var showLineNumbers: Bool
    @Binding var showFindReplace: Bool
    @Binding var showHelp: Bool
    let canUndo: Bool
    let canRedo: Bool
    let onUndo: () -> Void
    let onRedo: () -> Void
    @Binding var selectedFont: String
    @Binding var fontSize: CGFloat
    @Binding var isFullScreen: Bool
    @Binding var showCustomizationPanel: Bool
    @Binding var animationSpeed: AnimationSpeed
    let onNewDocument: () -> Void
    let onOpenDocument: () -> Void
    let onSaveDocument: () -> Void
    let onSaveDocumentAs: () -> Void
    let onExportDocument: () -> Void
    let canSave: Bool
    let isDocumentModified: Bool
    let currentDocumentName: String
    
    // Collaboration parameters
    @Binding var showCommentsPanel: Bool
    @Binding var showVersionHistory: Bool
    @Binding var showCollaboratorsPanel: Bool
    @Binding var showSharingDialog: Bool
    let collaboratorCount: Int
    let commentCount: Int
    
    // Template selector
    @Binding var showTemplateSelector: Bool
    
    // Character database
    @Binding var showCharacterDatabase: Bool
    let characterCount: Int
    
    // Outline database
    @Binding var showOutlineMode: Bool
    let outlineDatabase: OutlineDatabase
    
    var body: some View {
        HStack(spacing: 12) {
            // File operations with enhanced styling
            HStack(spacing: 6) {
                EnhancedAppleToolbarButton(
                    icon: "doc.badge.plus",
                    label: "New",
                    action: onNewDocument
                )
                
                EnhancedAppleToolbarButton(
                    icon: "folder",
                    label: "Open",
                    action: onOpenDocument
                )
                
                EnhancedAppleToolbarButton(
                    icon: "square.and.arrow.down",
                    label: "Save",
                    action: onSaveDocument
                )
                .disabled(!canSave)
                
                // Save As dropdown
                Menu {
                    Button("Save As...") {
                        onSaveDocumentAs()
                    }
                    Button("Export to PDF...") {
                        onExportDocument()
                    }
                    Button("Export to Final Draft...") {
                        onExportDocument()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .disabled(!canSave)
            }
            
            AppleDivider()
            
            // Template selector
            EnhancedAppleToolbarButton(
                icon: "doc.text",
                label: "Template",
                action: { showTemplateSelector = true }
            )
            
            AppleDivider()
            
            // Edit operations
            HStack(spacing: 6) {
                EnhancedAppleToolbarButton(
                    icon: "arrow.uturn.backward",
                    action: onUndo
                )
                .disabled(!canUndo)
                
                EnhancedAppleToolbarButton(
                    icon: "arrow.uturn.forward",
                    action: onRedo
                )
                .disabled(!canRedo)
                
                EnhancedAppleToolbarButton(
                    icon: "magnifyingglass",
                    action: { showFindReplace.toggle() }
                )
            }
            
            AppleDivider()
            
            // Formatting options with enhanced styling
            HStack(spacing: 8) {
                Picker("Font", selection: $selectedFont) {
                    Text("SF Mono").tag("SF Mono")
                    Text("Menlo").tag("Menlo")
                    Text("Monaco").tag("Monaco")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
                
                HStack(spacing: 4) {
                    EnhancedAppleToolbarButton(
                        icon: "textformat.size.smaller",
                        action: { fontSize = max(10, fontSize - 1) }
                    )
                    
                    Text("\(Int(fontSize))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 25)
                    
                    EnhancedAppleToolbarButton(
                        icon: "textformat.size.larger",
                        action: { fontSize = min(20, fontSize + 1) }
                    )
                }
            }
            
            Spacer()
            
            // View controls with customization
            HStack(spacing: 6) {
                EnhancedAppleToolbarButton(
                    icon: showLineNumbers ? "list.number" : "list.number.fill",
                    action: { showLineNumbers.toggle() }
                )
                
                EnhancedAppleToolbarButton(
                    icon: "paintbrush",
                    action: { showCustomizationPanel.toggle() }
                )
                
                EnhancedAppleToolbarButton(
                    icon: "questionmark.circle",
                    action: { showHelp = true }
                )
                
                EnhancedAppleToolbarButton(
                    icon: showPreview ? "eye.slash" : "eye",
                    action: { showPreview.toggle() }
                )
                
                EnhancedAppleToolbarButton(
                    icon: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right",
                    action: { isFullScreen.toggle() }
                )
            }
            
            AppleDivider()
            
            // Collaboration controls
            HStack(spacing: 6) {
                EnhancedAppleToolbarButton(
                    icon: "bubble.left.and.bubble.right",
                    action: { showCommentsPanel.toggle() }
                )
                .overlay(
                    Group {
                        if commentCount > 0 {
                            Text("\(commentCount)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.red)
                                )
                                .offset(x: 8, y: -8)
                        }
                    }
                )
                
                EnhancedAppleToolbarButton(
                    icon: "clock.arrow.circlepath",
                    action: { showVersionHistory.toggle() }
                )
                
                EnhancedAppleToolbarButton(
                    icon: "person.2",
                    action: { showCollaboratorsPanel.toggle() }
                )
                .overlay(
                    Group {
                        if collaboratorCount > 0 {
                            Text("\(collaboratorCount)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.green)
                                )
                                .offset(x: 8, y: -8)
                        }
                    }
                )
                
                EnhancedAppleToolbarButton(
                    icon: "square.and.arrow.up",
                    action: { showSharingDialog = true }
                )
            }
            
            AppleDivider()
            
            // Character database
            EnhancedAppleToolbarButton(
                icon: "person.3",
                label: "Characters",
                action: { showCharacterDatabase = true }
            )
            .overlay(
                Group {
                    if characterCount > 0 {
                        Text("\(characterCount)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.blue)
                            )
                            .offset(x: 8, y: -8)
                    }
                }
            )
            
            // Outline mode
            EnhancedAppleToolbarButton(
                icon: "list.bullet",
                label: "Outline",
                action: { self.showOutlineMode = true }
            )
            .overlay(
                Group {
                    if self.outlineDatabase.statistics.totalNodes > 0 {
                        Text("\(self.outlineDatabase.statistics.totalNodes)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.green)
                            )
                            .offset(x: 8, y: -8)
                    }
                }
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separatorColor)),
            alignment: .bottom
        )
    }
}

// MARK: - Enhanced Apple-style Components
struct EnhancedAppleToolbarButton: View {
    let icon: String
    var label: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                if let label = label {
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                }
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(EnhancedAppleButtonStyle())
    }
}

struct EnhancedAppleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(configuration.isPressed ? Color(.controlColor) : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AppleDivider: View {
    var body: some View {
        Rectangle()
            .frame(width: 1, height: 20)
            .foregroundColor(Color(.separatorColor))
    }
}

// MARK: - Enhanced Editor Header
struct EnhancedAppleEditorHeader: View {
    let wordCount: Int
    let pageCount: Int
    let characterCount: Int
    let showStatistics: Bool
    @Binding var showAutoCompletion: Bool
    @Binding var showWritingGoals: Bool
    let dailyWordGoal: Int
    let currentDailyWords: Int
    
    var body: some View {
        HStack {
            Text("Editor")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            if showStatistics {
                HStack(spacing: 16) {
                    EnhancedAppleStatisticView(label: "Words", value: "\(wordCount)")
                    EnhancedAppleStatisticView(label: "Pages", value: "\(pageCount)")
                    EnhancedAppleStatisticView(label: "Chars", value: "\(characterCount)")
                    
                    // Writing goal progress
                    if showWritingGoals {
                        WritingGoalProgressView(
                            current: currentDailyWords,
                            goal: dailyWordGoal
                        )
                    }
                }
            }
            
            Button(action: { showAutoCompletion.toggle() }) {
                Image(systemName: showAutoCompletion ? "textformat.abc" : "textformat.abc.dottedunderline")
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
            }
            .buttonStyle(EnhancedAppleButtonStyle())
            
            Button(action: { showWritingGoals.toggle() }) {
                Image(systemName: "target")
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
            }
            .buttonStyle(EnhancedAppleButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Enhanced Supporting Views
struct EnhancedAppleStatisticView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 12, weight: .semibold))
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
    }
}

struct WritingGoalProgressView: View {
    let current: Int
    let goal: Int
    
    private var progress: Double {
        min(Double(current) / Double(goal), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Text("\(current)")
                    .font(.system(size: 12, weight: .semibold))
                Text("/")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Text("\(goal)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.separatorColor))
                        .frame(height: 2)
                    
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progress, height: 2)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(width: 40, height: 2)
        }
    }
    
    private var progressColor: Color {
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.7 {
            return .orange
        } else {
            return .blue
        }
    }
}

// MARK: - Enhanced Preview Header
struct EnhancedApplePreviewHeader: View {
    let elementCount: Int
    
    var body: some View {
        HStack {
            Text("Preview")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(elementCount) elements")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Enhanced Status Bar
struct EnhancedAppleStatusBar: View {
    let wordCount: Int
    let pageCount: Int
    let characterCount: Int
    @Binding var showStatistics: Bool
    let smartFormattingManager: SmartFormattingManager
    let animationSpeed: AnimationSpeed
    let autoSaveEnabled: Bool
    let isDocumentModified: Bool
    let currentDocumentName: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Document info and status
            HStack(spacing: 12) {
                // Document name and modification status
                HStack(spacing: 6) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Text(currentDocumentName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if isDocumentModified {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.orange)
                    }
                }
                
                // Auto-save status
                HStack(spacing: 4) {
                    Image(systemName: autoSaveEnabled ? "clock.arrow.circlepath" : "clock.slash")
                        .font(.system(size: 11))
                        .foregroundColor(autoSaveEnabled ? .green : .secondary)
                    
                    Text(autoSaveEnabled ? "Auto-save" : "Manual save")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Center - Statistics toggle
            Button(action: { showStatistics.toggle() }) {
                HStack(spacing: 4) {
                    Image(systemName: showStatistics ? "chart.bar" : "chart.bar.fill")
                        .font(.system(size: 11))
                    Text("Stats")
                        .font(.system(size: 11))
                }
                .foregroundColor(.secondary)
            }
            .buttonStyle(EnhancedAppleButtonStyle())
            
            // Right side - Smart formatting and ready status
            HStack(spacing: 16) {
                // Smart formatting status
                HStack(spacing: 6) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                    Text("Smart formatting enabled")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                // Fountain format indicator
                Text("Fountain Format")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                // Ready status
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Ready")
                        .font(.system(size: 11))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separatorColor)),
            alignment: .top
        )
    }
}

// MARK: - Customization Panel
struct CustomizationPanel: View {
    @Binding var animationSpeed: AnimationSpeed
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Customization")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Button(action: { isVisible = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                }
                .buttonStyle(EnhancedAppleButtonStyle())
            }
            
            // Animation Speed
            VStack(alignment: .leading, spacing: 12) {
                Text("Animation Speed")
                    .font(.system(size: 14, weight: .medium))
                
                ForEach(AnimationSpeed.allCases, id: \.self) { speed in
                    Button(action: { animationSpeed = speed }) {
                        HStack {
                            Image(systemName: speed.icon)
                                .font(.system(size: 14))
                            Text(speed.rawValue)
                                .font(.system(size: 14))
                            Spacer()
                            if animationSpeed == speed {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(animationSpeed == speed ? Color(.controlColor) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .frame(width: 250)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        .padding(.trailing, 20)
    }
}

// MARK: - Enhanced Auto-completion Overlay
struct EnhancedAppleAutoCompletionOverlay: View {
    let suggestions: [String]
    let selectedIndex: Int
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(suggestions.enumerated()), id: \.offset) { index, suggestion in
                Button(action: {
                    onSelect(suggestion)
                }) {
                    Text(suggestion)
                        .font(.system(size: 13))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(index == selectedIndex ? Color(.controlColor) : Color.clear)
                }
                .buttonStyle(.plain)
                
                if index < suggestions.count - 1 {
                    Divider()
                        .padding(.horizontal, 12)
                }
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .frame(maxWidth: 300)
        .offset(y: 30)
    }
}

// MARK: - Enhanced Find/Replace View
struct EnhancedAppleFindReplaceView: View {
    @Binding var isVisible: Bool
    @Binding var text: String
    @State private var searchText: String = ""
    @State private var replaceText: String = ""
    @State private var caseSensitive: Bool = false
    @State private var useRegex: Bool = false
    @State private var searchResults: [Range<String.Index>] = []
    @State private var currentResultIndex: Int = 0
    
    var body: some View {
        HStack(spacing: 12) {
            // Find field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                TextField("Find", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 13))
                    .onChange(of: searchText) { _, _ in
                        performSearch()
                    }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(6)
            
            // Replace field
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                TextField("Replace", text: $replaceText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 13))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(6)
            
            // Options
            HStack(spacing: 8) {
                Toggle("Aa", isOn: $caseSensitive)
                    .toggleStyle(AppleToggleStyle())
                    .font(.system(size: 11))
                
                Toggle(".*", isOn: $useRegex)
                    .toggleStyle(AppleToggleStyle())
                    .font(.system(size: 11))
            }
            
            // Results count
            if !searchResults.isEmpty {
                Text("\(currentResultIndex + 1) of \(searchResults.count)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 6) {
                EnhancedAppleToolbarButton(
                    icon: "arrow.up",
                    action: previousResult
                )
                .disabled(searchResults.isEmpty)
                
                EnhancedAppleToolbarButton(
                    icon: "arrow.down",
                    action: nextResult
                )
                .disabled(searchResults.isEmpty)
                
                EnhancedAppleToolbarButton(
                    icon: "arrow.triangle.2.circlepath",
                    action: replaceCurrent
                )
                .disabled(searchResults.isEmpty)
                
                EnhancedAppleToolbarButton(
                    icon: "arrow.triangle.2.circlepath.circle",
                    action: replaceAll
                )
                .disabled(searchResults.isEmpty)
            }
            
            // Close button
            EnhancedAppleToolbarButton(
                icon: "xmark",
                action: { isVisible = false }
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separatorColor)),
            alignment: .bottom
        )
    }
    
    private func performSearch() {
        // Implementation would go here
    }
    
    private func nextResult() {
        // Implementation would go here
    }
    
    private func previousResult() {
        // Implementation would go here
    }
    
    private func replaceCurrent() {
        // Implementation would go here
    }
    
    private func replaceAll() {
        // Implementation would go here
    }
}

struct AppleToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                configuration.label
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(configuration.isOn ? .primary : .secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(configuration.isOn ? Color(.controlColor) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}


