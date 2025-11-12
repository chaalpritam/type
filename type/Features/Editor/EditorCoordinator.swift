import SwiftUI
import Combine
import AppKit

// MARK: - Editor Coordinator
/// Coordinates all editor-related functionality
@MainActor
class EditorCoordinator: BaseModuleCoordinator, ModuleCoordinator {
    typealias ModuleView = EditorMainView
    
    // MARK: - Published Properties
    @Published var text: String = ""
    @Published var showPreview: Bool = true
    @Published var showHelp: Bool = false
    @Published var showTemplateSelector: Bool = false
    @Published var selectedTemplate: TemplateType = .default
    @Published var wordCount: Int = 0
    @Published var pageCount: Int = 0
    @Published var characterCount: Int = 0
    @Published var canUndo: Bool = false
    @Published var canRedo: Bool = false
    @Published var showFindReplace: Bool = false
    @Published var showSpellCheck: Bool = false
    @Published var showMinimap: Bool = false
    @Published var isFocusModeActive: Bool = false
    @Published var isTypewriterModeActive: Bool = false
    @Published var hasMultipleCursorsActive: Bool = false
    @Published var isCodeFoldingActive: Bool = false
    
    // MARK: - Services
    let fountainParser = FountainParser()
    private let historyManager = TextHistoryManager()
    private let autoCompletionManager = AutoCompletionManager()
    let smartFormattingManager = SmartFormattingManager()
    private let fileManagementService = FileManagementService()
    private let statisticsService = StatisticsService()
    let advancedFeatures = AdvancedEditorFeatures()
    let multipleCursorsManager = MultipleCursorsManager()
    let codeFoldingManager = CodeFoldingManager()
    
    // MARK: - Initialization
    override init(documentService: DocumentService) {
        super.init(documentService: documentService)
        Task { @MainActor in
            setupEditorBindings()
        }
    }
    
    // MARK: - ModuleCoordinator Implementation
    
    func createView() -> EditorMainView {
        return EditorMainView(coordinator: self)
    }
    
    // MARK: - Public Methods
    
    override func updateDocument(_ document: ScreenplayDocument?) {
        Task { @MainActor in
            if let document = document {
                text = document.content
                updateStatistics(text: document.content)
                fountainParser.parse(document.content)
            } else {
                text = ""
                updateStatistics(text: "")
                // Clear fountainParser elements
                fountainParser.elements = []
                fountainParser.titlePage = [:]
            }
        }
    }
    
    func updateText(_ newText: String) {
        text = newText
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
        
        // Update document service
        documentService.updateDocumentContent(newText)
        
        // Parse Fountain syntax in real-time
        fountainParser.parse(newText)
    }
    
    func performUndo() {
        if let previousText = historyManager.undo() {
            text = previousText
            updateStatistics(text: previousText)
            documentService.updateDocumentContent(previousText)
            fountainParser.parse(previousText)
        }
    }
    
    func performRedo() {
        if let nextText = historyManager.redo() {
            text = nextText
            updateStatistics(text: nextText)
            documentService.updateDocumentContent(nextText)
            fountainParser.parse(nextText)
        }
    }
    
    func selectTemplate(_ template: TemplateType) {
        selectedTemplate = template
        if text.isEmpty {
            text = FountainTemplate.getTemplate(for: template)
            documentService.updateDocumentContent(text)
        }
        showTemplateSelector = false
    }
    
    func togglePreview() {
        showPreview.toggle()
    }
    
    func toggleHelp() {
        let willShow = !showHelp
        showHelp = willShow
        if willShow {
            showFindReplace = false
            showSpellCheck = false
            codeFoldingManager.showFoldingControls = false
            isCodeFoldingActive = false
            showMinimap = false
        }
    }
    
    func toggleFindReplace() {
        let willShow = !showFindReplace
        showFindReplace = willShow
        if willShow {
            showHelp = false
            showSpellCheck = false
            codeFoldingManager.showFoldingControls = false
            isCodeFoldingActive = false
            showMinimap = false
        }
    }
    
    func toggleSpellCheck() {
        let willShow = !showSpellCheck
        showSpellCheck = willShow
        if willShow {
            showHelp = false
            showFindReplace = false
            codeFoldingManager.showFoldingControls = false
            isCodeFoldingActive = false
            showMinimap = false
        }
    }
    
    // MARK: - Advanced Features
    
    func toggleFocusMode() {
        advancedFeatures.toggleFocusMode()
    }
    
    func toggleTypewriterMode() {
        advancedFeatures.toggleTypewriterMode()
    }
    
    func toggleMultipleCursors() {
        // Toggle multiple cursors mode
        if multipleCursorsManager.cursors.isEmpty {
            // Add a cursor at current position
            multipleCursorsManager.addCursor(at: text.count / 2)
        } else {
            // Clear all cursors
            multipleCursorsManager.clearAllCursors()
        }
    }
    
    func toggleCodeFolding() {
        let willShow = !codeFoldingManager.showFoldingControls
        codeFoldingManager.showFoldingControls = willShow
        isCodeFoldingActive = willShow
        if willShow {
            showHelp = false
            showFindReplace = false
            showSpellCheck = false
            showMinimap = false
        }
    }
    
    func parseFoldingRanges() {
        codeFoldingManager.parseFoldingRanges(from: text)
    }
    
    func toggleMinimap() {
        let willShow = !showMinimap
        showMinimap = willShow
        if willShow {
            showHelp = false
            showFindReplace = false
            showSpellCheck = false
            codeFoldingManager.showFoldingControls = false
            isCodeFoldingActive = false
        }
    }
    
    // MARK: - Private Methods
    
    private func setupEditorBindings() {
        // Initial state
        isFocusModeActive = advancedFeatures.isFocusMode
        isTypewriterModeActive = advancedFeatures.isTypewriterMode
        hasMultipleCursorsActive = !multipleCursorsManager.cursors.isEmpty
        isCodeFoldingActive = codeFoldingManager.showFoldingControls
        
        // Listen for document changes
        documentService.$currentDocument
            .sink { [weak self] document in
                self?.updateDocument(document)
            }
            .store(in: &cancellables)
        
        // Observe advanced feature states
        advancedFeatures.$isFocusMode
            .sink { [weak self] value in
                self?.isFocusModeActive = value
            }
            .store(in: &cancellables)
        
        advancedFeatures.$isTypewriterMode
            .sink { [weak self] value in
                self?.isTypewriterModeActive = value
            }
            .store(in: &cancellables)
        
        multipleCursorsManager.$cursors
            .sink { [weak self] cursors in
                self?.hasMultipleCursorsActive = !cursors.isEmpty
            }
            .store(in: &cancellables)
    }
    
    private func updateStatistics(text: String) {
        statisticsService.updateStatistics(text: text)
        wordCount = statisticsService.wordCount
        characterCount = statisticsService.characterCount
        pageCount = statisticsService.pageCount
    }
    
    private func calculatePageCount(text: String) -> Int {
        // Rough calculation: 1 page ≈ 55 lines
        let lines = text.components(separatedBy: .newlines).count
        return max(1, lines / 55)
    }
}

// MARK: - Editor Main View
struct EditorMainView: View {
    @ObservedObject var coordinator: EditorCoordinator
    
    var body: some View {
        ZStack {
            if coordinator.advancedFeatures.isFocusMode {
                FocusModeView(
                    coordinator: coordinator,
                    advancedFeatures: coordinator.advancedFeatures
                )
            } else {
                HStack(spacing: 0) {
                    // Main editor
                    VStack(spacing: 0) {
                        // Editor content
                        HStack(spacing: 0) {
                            // Text editor
                            if !coordinator.multipleCursorsManager.cursors.isEmpty {
                                MultipleCursorsTextEditor(
                                    text: $coordinator.text,
                                    coordinator: coordinator,
                                    cursorsManager: coordinator.multipleCursorsManager
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                EnhancedFountainTextEditor(
                                    text: $coordinator.text,
                                    placeholder: "Start writing your screenplay...",
                                    showLineNumbers: true,
                                    onTextChange: { newText in
                                        coordinator.updateText(newText)
                                    }
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            
                            // Preview panel
                            if coordinator.showPreview {
                                ScreenplayPreview(
                                    elements: coordinator.fountainParser.elements,
                                    titlePage: coordinator.fountainParser.titlePage
                                )
                                .frame(width: 300)
                                .transition(.move(edge: .trailing))
                            }
                        }
                    }
                    
                    // Side panels
                    VStack(spacing: 0) {
                        if coordinator.showHelp {
                            FountainHelpView(isPresented: $coordinator.showHelp)
                                .frame(width: 250)
                                .transition(.move(edge: .trailing))
                        }
                        
                        if coordinator.showFindReplace {
                            FindReplaceView(
                                isVisible: $coordinator.showFindReplace,
                                text: $coordinator.text
                            )
                            .frame(width: 250)
                            .transition(.move(edge: .trailing))
                        }
                        
                        if coordinator.codeFoldingManager.showFoldingControls {
                            CodeFoldingView(
                                foldingManager: coordinator.codeFoldingManager,
                                coordinator: coordinator
                            )
                            .frame(width: 250)
                            .transition(.move(edge: .trailing))
                        }
                        
                        if coordinator.showMinimap {
                            MinimapView(coordinator: coordinator)
                                .frame(width: 200)
                                .transition(.move(edge: .trailing))
                        }
                    }
                }
                .sheet(isPresented: $coordinator.showTemplateSelector) {
                    TemplateSelectorView(
                        selectedTemplate: $coordinator.selectedTemplate,
                        isVisible: $coordinator.showTemplateSelector,
                        onTemplateSelected: { template in
                            coordinator.selectTemplate(template)
                        }
                    )
                }
            }
        }
    }
}
