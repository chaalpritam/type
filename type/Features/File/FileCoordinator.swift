import SwiftUI
import Combine
import UniformTypeIdentifiers
import Data.ScreenplayDocument
import Services.DocumentService
import Core.ModuleCoordinator

// MARK: - File Coordinator
/// Coordinates all file-related operations
@MainActor
class FileCoordinator: BaseModuleCoordinator {
    // MARK: - Published Properties
    @Published var showSaveDialog: Bool = false
    @Published var showOpenDialog: Bool = false
    @Published var showExportDialog: Bool = false
    @Published var showUnsavedChangesAlert: Bool = false
    @Published var exportFormat: ExportFormat = .pdf
    @Published var isExporting: Bool = false
    
    // MARK: - Computed Properties
    var canSave: Bool {
        documentService.canSave()
    }
    
    var isDocumentModified: Bool {
        documentService.isDocumentModified
    }
    
    var currentDocumentName: String {
        documentService.currentDocument?.url?.lastPathComponent ?? "Untitled"
    }
    
    // MARK: - Initialization
    override init(documentService: DocumentService) {
        super.init(documentService: documentService)
        setupFileBindings()
    }
    
    // MARK: - Public Methods
    
    override func updateDocument(_ document: ScreenplayDocument?) {
        // File coordinator doesn't need to update its state when document changes
        // It just provides file operations
    }
    
    func newDocument() {
        documentService.newDocument()
    }
    
    func openDocument() async {
        do {
            let panel = NSOpenPanel()
            panel.allowedContentTypes = [UTType.plainText]
            panel.allowsMultipleSelection = false
            panel.title = "Open Screenplay"
            panel.message = "Choose a screenplay file to open"
            
            let response = await panel.beginSheetModal(for: NSApp.keyWindow!)
            
            if response == .OK, let url = panel.url {
                try await documentService.loadDocument(from: url)
            }
        } catch {
            print("Failed to open document: \(error.localizedDescription)")
        }
    }
    
    func saveDocument() async {
        do {
            try await documentService.saveDocument()
        } catch {
            print("Failed to save document: \(error.localizedDescription)")
        }
    }
    
    func saveDocumentAs() async {
        do {
            _ = try await documentService.saveDocumentAs()
        } catch {
            print("Failed to save document as: \(error.localizedDescription)")
        }
    }
    
    func exportDocument() async {
        isExporting = true
        
        do {
            let url = try await performExport()
            if let url = url {
                print("Document exported successfully to: \(url.path)")
            }
        } catch {
            print("Failed to export document: \(error.localizedDescription)")
        }
        
        isExporting = false
    }
    
    func checkForUnsavedChanges() -> Bool {
        return documentService.isDocumentModified
    }
    
    func handleUnsavedChanges() async -> Bool {
        if checkForUnsavedChanges() {
            showUnsavedChangesAlert = true
            return false
        }
        return true
    }
    
    func forceSave() async {
        await saveDocument()
    }
    
    func forceSaveAs() async {
        await saveDocumentAs()
    }
    
    // MARK: - Private Methods
    
    private func setupFileBindings() {
        // Listen for document changes to update UI state
        documentService.$currentDocument
            .sink { [weak self] _ in
                // Update any file-related UI state if needed
            }
            .store(in: &cancellables)
    }
    
    private func performExport() async throws -> URL? {
        guard let document = documentService.currentDocument else {
            throw FileError.noDocument
        }
        
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "Screenplay.\(exportFormat.fileExtension)"
        panel.title = "Export to \(exportFormat.displayName)"
        panel.message = "Choose a location to save the exported file"
        
        let response = await panel.beginSheetModal(for: NSApp.keyWindow!)
        
        if response == .OK, let url = panel.url {
            switch exportFormat {
            case .pdf:
                return try await exportToPDF(document: document, to: url)
            case .finalDraft:
                return try await exportToFinalDraft(document: document, to: url)
            case .fountain:
                return try await exportToFountain(document: document, to: url)
            case .plainText:
                return try await exportToPlainText(document: document, to: url)
            }
        }
        
        return nil
    }
    
    private func exportToPDF(document: ScreenplayDocument, to url: URL) async throws -> URL {
        let pdfData = try await generatePDF(from: document.content)
        try pdfData.write(to: url)
        return url
    }
    
    private func exportToFinalDraft(document: ScreenplayDocument, to url: URL) async throws -> URL {
        let fdxData = try await generateFinalDraftXML(from: document.content)
        try fdxData.write(to: url)
        return url
    }
    
    private func exportToFountain(document: ScreenplayDocument, to url: URL) async throws -> URL {
        try document.content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
    
    private func exportToPlainText(document: ScreenplayDocument, to url: URL) async throws -> URL {
        try document.content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
    
    private func generatePDF(from content: String) async throws -> Data {
        // This is a simplified PDF generation
        // In a real app, you'd want to use a proper PDF library
        let attributedString = NSAttributedString(string: content)
        let pdfData = try attributedString.data(from: NSRange(location: 0, length: attributedString.length),
                                               documentAttributes: [.documentType: NSAttributedString.DocumentType.plain])
        return pdfData
    }
    
    private func generateFinalDraftXML(from content: String) async throws -> Data {
        // Simplified Final Draft XML generation
        // In a real app, you'd want to implement proper FDX format
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <FinalDraft DocumentType="Screenplay" Template="Screenplay" Version="3">
            <Content>
                \(content)
            </Content>
        </FinalDraft>
        """
        
        return xmlString.data(using: .utf8) ?? Data()
    }
}

// MARK: - Export Format
enum ExportFormat: String, CaseIterable {
    case pdf = "PDF"
    case finalDraft = "Final Draft"
    case fountain = "Fountain"
    case plainText = "Plain Text"
    
    var displayName: String {
        return rawValue
    }
    
    var fileExtension: String {
        switch self {
        case .pdf: return "pdf"
        case .finalDraft: return "fdx"
        case .fountain: return "fountain"
        case .plainText: return "txt"
        }
    }
    
    var contentType: UTType {
        switch self {
        case .pdf: return .pdf
        case .finalDraft: return UTType(filenameExtension: "fdx") ?? .xml
        case .fountain: return .plainText
        case .plainText: return .plainText
        }
    }
}

// MARK: - File Error
enum FileError: LocalizedError {
    case noDocument
    case noSaveLocation
    case saveFailed
    case loadFailed
    case exportFailed
    
    var errorDescription: String? {
        switch self {
        case .noDocument:
            return "No document to save"
        case .noSaveLocation:
            return "No save location specified"
        case .saveFailed:
            return "Failed to save document"
        case .loadFailed:
            return "Failed to load document"
        case .exportFailed:
            return "Failed to export document"
        }
    }
} 