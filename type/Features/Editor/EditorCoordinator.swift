import SwiftUI
import Combine
import AppKit

enum EditorModal: Identifiable {
    case help
    case findReplace
    case spellCheck
    case minimap
    
    var id: String { String(describing: self) }
}

// MARK: - Editor Coordinator
/// Coordinates all editor-related functionality
@MainActor
class EditorCoordinator: BaseModuleCoordinator, ModuleCoordinator {
    typealias ModuleView = EditorMainView
    
    // MARK: - Published Properties
    @Published var text: String = ""
    @Published var showPreview: Bool = false
    @Published var showLineNumbers: Bool = false
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
    @Published var activeModal: EditorModal?
    
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

    // MARK: - Performance Optimization
    private var parseDebounceTask: Task<Void, Never>?
    private var statisticsDebounceTask: Task<Void, Never>?
    private let parseDebounceDelay: UInt64 = 50_000_000 // 50ms in nanoseconds
    
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

        // Update history immediately for responsive undo/redo
        historyManager.addToHistory(newText)
        canUndo = historyManager.canUndo
        canRedo = historyManager.canRedo

        // Update document service immediately
        documentService.updateDocumentContent(newText)

        // Cancel previous debounce tasks
        parseDebounceTask?.cancel()
        statisticsDebounceTask?.cancel()

        // Debounce parsing - only parse after user stops typing
        parseDebounceTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: parseDebounceDelay)

                // Parse in background to avoid blocking UI
                await parseTextAsync(newText)

                // Apply smart formatting after parse completes
                let formattedText = smartFormattingManager.formatText(newText)
                if formattedText != newText {
                    text = formattedText
                }
            } catch {
                // Task was cancelled, which is expected during rapid typing
            }
        }

        // Debounce statistics calculation
        statisticsDebounceTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: parseDebounceDelay)
                updateStatistics(text: newText)
            } catch {
                // Task was cancelled
            }
        }

        // Update auto-completion suggestions (lightweight operation)
        autoCompletionManager.updateSuggestions(for: newText, at: 0)
    }

    /// Parse text asynchronously on a background thread
    private func parseTextAsync(_ text: String) async {
        await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            // Perform parsing off the main thread
            await self.fountainParser.parseAsync(text)
        }.value
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
        setModal(.help, isPresented: activeModal != .help)
    }
    
    func toggleFindReplace() {
        setModal(.findReplace, isPresented: activeModal != .findReplace)
    }
    
    func toggleSpellCheck() {
        setModal(.spellCheck, isPresented: activeModal != .spellCheck)
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
    
    func parseFoldingRanges() {
        codeFoldingManager.parseFoldingRanges(from: text)
    }
    
    func toggleMinimap() {
        setModal(.minimap, isPresented: activeModal != .minimap)
    }
    
    func setModal(_ modal: EditorModal, isPresented: Bool) {
        if isPresented {
            if activeModal == modal { return }
            resetModalFlags()
            activeModal = modal
            switch modal {
            case .help:
                showHelp = true
            case .findReplace:
                showFindReplace = true
            case .spellCheck:
                showSpellCheck = true
            case .minimap:
                showMinimap = true
            }
        } else {
            switch modal {
            case .help:
                showHelp = false
            case .findReplace:
                showFindReplace = false
            case .spellCheck:
                showSpellCheck = false
            case .minimap:
                showMinimap = false
            }
            if activeModal == modal {
                activeModal = nil
            }
        }
    }
    
    func dismissActiveModal() {
        if let modal = activeModal {
            setModal(modal, isPresented: false)
        }
    }
    
    // MARK: - Private Methods
    
    private func resetModalFlags() {
        showHelp = false
        showFindReplace = false
        showSpellCheck = false
        showMinimap = false
    }
    
    private func setupEditorBindings() {
        // Initial state
        isFocusModeActive = advancedFeatures.isFocusMode
        isTypewriterModeActive = advancedFeatures.isTypewriterMode
        hasMultipleCursorsActive = !multipleCursorsManager.cursors.isEmpty
        
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
        let mainContent = ZStack {
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
                        if coordinator.showPreview {
                            ScreenplayPreview(
                                elements: coordinator.fountainParser.elements,
                                titlePage: coordinator.fountainParser.titlePage
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .transition(.move(edge: .trailing))
                        } else {
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
                                    showLineNumbers: coordinator.showLineNumbers,
                                    onTextChange: { newText in
                                        coordinator.updateText(newText)
                                    }
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                }
            }
        }
        
        return mainContent
            .sheet(item: $coordinator.activeModal, onDismiss: {
                coordinator.dismissActiveModal()
            }) { modal in
                modalContent(for: modal)
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

// MARK: - Editor Modal Helpers
extension EditorMainView {
    @ViewBuilder
    private func modalContent(for modal: EditorModal) -> some View {
        switch modal {
        case .help:
            FountainHelpView(isPresented: binding(for: .help))
                .frame(minWidth: 500, minHeight: 420)
        case .findReplace:
            FindReplaceView(
                isVisible: binding(for: .findReplace),
                text: $coordinator.text
            )
            .frame(minWidth: 420, minHeight: 320)
        case .spellCheck:
            SpellCheckSheet(
                coordinator: coordinator,
                isPresented: binding(for: .spellCheck)
            )
        case .minimap:
            MinimapSheet(
                coordinator: coordinator,
                isPresented: binding(for: .minimap)
            )
        }
    }
    
    private func binding(for modal: EditorModal) -> Binding<Bool> {
        Binding(
            get: {
                switch modal {
                case .help:
                    return coordinator.showHelp
                case .findReplace:
                    return coordinator.showFindReplace
                case .spellCheck:
                    return coordinator.showSpellCheck
                case .minimap:
                    return coordinator.showMinimap
                }
            },
            set: { newValue in
                coordinator.setModal(modal, isPresented: newValue)
            }
        )
    }
}

private struct SpellCheckSheet: View {
    @ObservedObject var coordinator: EditorCoordinator
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            SpellCheckTextEditor(
                text: $coordinator.text,
                placeholder: "Spell Check Document",
                showLineNumbers: coordinator.showLineNumbers,
                onTextChange: { newText in
                    coordinator.updateText(newText)
                }
            )
            .navigationTitle("Spell Check")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 420)
    }
}

private struct MinimapSheet: View {
    @ObservedObject var coordinator: EditorCoordinator
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            MinimapView(coordinator: coordinator)
                .navigationTitle("Minimap")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            isPresented = false
                        }
                    }
                }
        }
        .frame(minWidth: 320, minHeight: 400)
    }
}
