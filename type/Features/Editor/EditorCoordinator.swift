import SwiftUI
import Combine
import Features.Editor.FountainParser
import Features.Editor.TextHistoryManager
import Features.Editor.AutoCompletionManager
import Features.Editor.SmartFormattingManager
import Features.Editor.FountainTemplate
import Features.Editor.AdvancedEditorFeatures
import Features.Editor.CodeFoldingManager
import Data.ScreenplayDocument
import Services.DocumentService
import Services.FileManagementService
import Services.StatisticsService
import Core.ModuleCoordinator

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
        setupEditorBindings()
    }
    
    // MARK: - ModuleCoordinator Implementation
    
    func createView() -> EditorMainView {
        return EditorMainView(coordinator: self)
    }
    
    // MARK: - Public Methods
    
    override func updateDocument(_ document: ScreenplayDocument?) {
        if let document = document {
            text = document.content
            updateStatistics(text: document.content)
            fountainParser.parse(document.content)
        } else {
            text = ""
            updateStatistics(text: "")
            fountainParser.clear()
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
        showHelp.toggle()
    }
    
    func toggleFindReplace() {
        showFindReplace.toggle()
    }
    
    func toggleSpellCheck() {
        showSpellCheck.toggle()
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
        codeFoldingManager.showFoldingControls.toggle()
    }
    
    func parseFoldingRanges() {
        codeFoldingManager.parseFoldingRanges(from: text)
    }
    
    func toggleMinimap() {
        showMinimap.toggle()
    }
    
    // MARK: - Private Methods
    
    private func setupEditorBindings() {
        // Listen for document changes
        documentService.$currentDocument
            .sink { [weak self] document in
                self?.updateDocument(document)
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
        Group {
            if coordinator.advancedFeatures.isFocusMode {
                FocusModeView(
                    coordinator: coordinator,
                    advancedFeatures: coordinator.advancedFeatures
                )
            } else {
                HStack(spacing: 0) {
                    // Main editor
                    VStack(spacing: 0) {
                        // Editor toolbar
                        EditorToolbarView(coordinator: coordinator)
                        
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
                                    coordinator: coordinator
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            
                            // Preview panel
                            if coordinator.showPreview {
                                ScreenplayPreview(
                                    fountainParser: coordinator.fountainParser,
                                    text: coordinator.text
                                )
                                .frame(width: 300)
                                .transition(.move(edge: .trailing))
                            }
                        }
                    }
                    
                    // Side panels
                    VStack(spacing: 0) {
                        if coordinator.showHelp {
                            FountainHelpView()
                                .frame(width: 250)
                                .transition(.move(edge: .trailing))
                        }
                        
                        if coordinator.showFindReplace {
                            FindReplaceView(coordinator: coordinator)
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
                    TemplateSelectorView(coordinator: coordinator)
                }
            }
        }
    }
}

// MARK: - Editor Toolbar View
struct EditorToolbarView: View {
    @ObservedObject var coordinator: EditorCoordinator
    
    var body: some View {
        HStack(spacing: 12) {
            // File operations
            HStack(spacing: 8) {
                Button("Undo") {
                    coordinator.performUndo()
                }
                .disabled(!coordinator.canUndo)
                
                Button("Redo") {
                    coordinator.performRedo()
                }
                .disabled(!coordinator.canRedo)
            }
            
            Divider()
            
            // View controls
            HStack(spacing: 8) {
                Button("Preview") {
                    coordinator.togglePreview()
                }
                .background(coordinator.showPreview ? Color.blue.opacity(0.2) : Color.clear)
                
                Button("Help") {
                    coordinator.toggleHelp()
                }
                .background(coordinator.showHelp ? Color.blue.opacity(0.2) : Color.clear)
                
                Button("Find/Replace") {
                    coordinator.toggleFindReplace()
                }
                .background(coordinator.showFindReplace ? Color.blue.opacity(0.2) : Color.clear)
            }
            
            Divider()
            
            // Advanced features
            HStack(spacing: 8) {
                Button(action: {
                    coordinator.toggleFocusMode()
                }) {
                    Image(systemName: coordinator.advancedFeatures.isFocusMode ? "eye.slash.fill" : "eye.slash")
                        .foregroundColor(coordinator.advancedFeatures.isFocusMode ? .blue : .primary)
                }
                .help("Focus Mode - Distraction-free writing")
                
                Button(action: {
                    coordinator.toggleTypewriterMode()
                }) {
                    Image(systemName: coordinator.advancedFeatures.isTypewriterMode ? "typewriter.fill" : "typewriter")
                        .foregroundColor(coordinator.advancedFeatures.isTypewriterMode ? .blue : .primary)
                }
                .help("Typewriter Mode - Centered cursor with auto-scroll")
                
                Button(action: {
                    coordinator.toggleMultipleCursors()
                }) {
                    Image(systemName: coordinator.multipleCursorsManager.cursors.isEmpty ? "cursorarrow.rays" : "cursorarrow.rays.fill")
                        .foregroundColor(coordinator.multipleCursorsManager.cursors.isEmpty ? .primary : .blue)
                }
                .help("Multiple Cursors - Edit multiple locations simultaneously")
                
                Button(action: {
                    coordinator.toggleCodeFolding()
                }) {
                    Image(systemName: coordinator.codeFoldingManager.showFoldingControls ? "chevron.up.chevron.down" : "chevron.up.chevron.down")
                        .foregroundColor(coordinator.codeFoldingManager.showFoldingControls ? .blue : .primary)
                }
                .help("Code Folding - Collapse/expand sections and scenes")
                
                Button(action: {
                    coordinator.toggleMinimap()
                }) {
                    Image(systemName: coordinator.showMinimap ? "map.fill" : "map")
                        .foregroundColor(coordinator.showMinimap ? .blue : .primary)
                }
                .help("Minimap - Document overview and navigation")
            }
            
            Spacer()
            
            // Statistics
            HStack(spacing: 16) {
                Text("Words: \(coordinator.wordCount)")
                    .font(.caption)
                Text("Pages: \(coordinator.pageCount)")
                    .font(.caption)
                Text("Characters: \(coordinator.characterCount)")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .border(Color(.systemGray4), width: 0.5)
    }
}

// MARK: - Template Selector View
struct TemplateSelectorView: View {
    @ObservedObject var coordinator: EditorCoordinator
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(TemplateType.allCases, id: \.self) { template in
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.rawValue)
                        .font(.headline)
                    Text(template.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    coordinator.selectTemplate(template)
                    dismiss()
                }
            }
            .navigationTitle("Select Template")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 400, height: 300)
    }
}

// MARK: - Template Type
enum TemplateType: String, CaseIterable {
    case `default` = "Default"
    case screenplay = "Screenplay"
    case stageplay = "Stageplay"
    case audioDrama = "Audio Drama"
    case comic = "Comic"
    case novel = "Novel"
    
    var description: String {
        switch self {
        case .default:
            return "Standard screenplay format"
        case .screenplay:
            return "Feature film screenplay"
        case .stageplay:
            return "Theater play format"
        case .audioDrama:
            return "Audio drama/podcast format"
        case .comic:
            return "Comic book script format"
        case .novel:
            return "Novel manuscript format"
        }
    }
} 