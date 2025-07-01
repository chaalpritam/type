import SwiftUI
import Combine
import Features.Editor.FountainParser
import Features.Editor.TextHistoryManager
import Features.Editor.AutoCompletionManager
import Features.Editor.SmartFormattingManager
import Features.Editor.FountainTemplate
import Data.ScreenplayDocument
import Services.DocumentService
import Core.ModuleCoordinator

// MARK: - Editor Coordinator
/// Coordinates all editor-related functionality
@MainActor
class EditorCoordinator: BaseModuleCoordinator {
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
    
    // MARK: - Services
    private let fountainParser = FountainParser()
    private let historyManager = TextHistoryManager()
    private let autoCompletionManager = AutoCompletionManager()
    private let smartFormattingManager = SmartFormattingManager()
    
    // MARK: - Initialization
    override init(documentService: DocumentService) {
        super.init(documentService: documentService)
        setupEditorBindings()
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
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        wordCount = words.count
        characterCount = text.count
        pageCount = calculatePageCount(text: text)
    }
    
    private func calculatePageCount(text: String) -> Int {
        // Rough calculation: 1 page ≈ 55 lines
        let lines = text.components(separatedBy: .newlines).count
        return max(1, lines / 55)
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