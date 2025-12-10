import SwiftUI
import Combine
import UniformTypeIdentifiers
import AppKit

// MARK: - File Coordinator
/// Coordinates all file-related operations
@MainActor
class FileCoordinator: BaseModuleCoordinator, ModuleCoordinator {
    typealias ModuleView = FileMainView
    
    // MARK: - Published Properties
    @Published var showSaveDialog: Bool = false
    @Published var showOpenDialog: Bool = false
    @Published var showExportDialog: Bool = false
    @Published var showUnsavedChangesAlert: Bool = false
    @Published var exportFormat: ExportFormat = .pdf
    @Published var isExporting: Bool = false
    @Published var showRecentFiles: Bool = false
    
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
        Task { @MainActor in
            setupFileBindings()
        }
    }
    
    // MARK: - ModuleCoordinator Implementation
    
    func createView() -> FileMainView {
        return FileMainView(coordinator: self)
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
            
            let response: NSApplication.ModalResponse
            if let window = NSApp.keyWindow ?? NSApp.mainWindow {
                response = await panel.beginSheetModal(for: window)
            } else {
                // Fallback when there is no active window (e.g. during app shutdown)
                response = panel.runModal()
            }
            
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
    
    func toggleRecentFiles() {
        showRecentFiles.toggle()
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
        
        let response: NSApplication.ModalResponse
        if let window = NSApp.keyWindow ?? NSApp.mainWindow {
            response = await panel.beginSheetModal(for: window)
        } else {
            // Fallback when there is no active window (e.g. during app shutdown)
            response = panel.runModal()
        }
        
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

// MARK: - File Main View
struct FileMainView: View {
    @ObservedObject var coordinator: FileCoordinator
    
    var body: some View {
        VStack(spacing: 0) {
            // File toolbar
            FileToolbarView(coordinator: coordinator)
            
            // File content
            FileContentView(coordinator: coordinator)
        }
        .sheet(isPresented: $coordinator.showRecentFiles) {
            RecentFilesView(coordinator: coordinator)
        }
        .alert("Unsaved Changes", isPresented: $coordinator.showUnsavedChangesAlert) {
            Button("Save") {
                Task {
                    await coordinator.forceSave()
                }
            }
            Button("Don't Save", role: .cancel) { }
        } message: {
            Text("Do you want to save your changes before closing?")
        }
    }
}

// MARK: - File Toolbar View
struct FileToolbarView: View {
    @ObservedObject var coordinator: FileCoordinator
    
    var body: some View {
        HStack(spacing: 12) {
            // File operations
            HStack(spacing: 8) {
                Button("New") {
                    coordinator.newDocument()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Open") {
                    Task {
                        await coordinator.openDocument()
                    }
                }
                .buttonStyle(.bordered)
                
                Button("Save") {
                    Task {
                        await coordinator.saveDocument()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(!coordinator.canSave)
                
                Button("Save As...") {
                    Task {
                        await coordinator.saveDocumentAs()
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Divider()
            
            // Export controls
            HStack(spacing: 8) {
                Picker("Export Format", selection: $coordinator.exportFormat) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Text(format.displayName).tag(format)
                    }
                }
                .pickerStyle(.menu)
                
                Button("Export") {
                    Task {
                        await coordinator.exportDocument()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(coordinator.isExporting)
            }
            
            Divider()
            
            // Recent files
            Button("Recent Files") {
                coordinator.toggleRecentFiles()
            }
            .buttonStyle(.bordered)
            
            Spacer()
            
            // Document info
            VStack(alignment: .trailing, spacing: 4) {
                Text(coordinator.currentDocumentName)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if coordinator.isDocumentModified {
                    Text("Modified")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(nsColor: .systemGray))
        .border(Color(nsColor: .separatorColor), width: 0.5)
    }
}

// MARK: - File Content View
struct FileContentView: View {
    @ObservedObject var coordinator: FileCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            // Document status
            DocumentStatusCard(coordinator: coordinator)
            
            // Quick actions
            QuickActionsCard(coordinator: coordinator)
            
            // Export options
            ExportOptionsCard(coordinator: coordinator)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Document Status Card
struct DocumentStatusCard: View {
    @ObservedObject var coordinator: FileCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Document Status")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Name:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(coordinator.currentDocumentName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Status:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(coordinator.isDocumentModified ? "Modified" : "Saved")
                        .font(.subheadline)
                        .foregroundColor(coordinator.isDocumentModified ? .orange : .green)
                }
                
                HStack {
                    Text("Can Save:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(coordinator.canSave ? "Yes" : "No")
                        .font(.subheadline)
                        .foregroundColor(coordinator.canSave ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color(nsColor: .systemGray))
        .cornerRadius(8)
    }
}

// MARK: - Quick Actions Card
struct QuickActionsCard: View {
    @ObservedObject var coordinator: FileCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            
            VStack(spacing: 8) {
                Button("Create New Document") {
                    coordinator.newDocument()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Open Recent File") {
                    coordinator.toggleRecentFiles()
                }
                .buttonStyle(.bordered)
                
                if coordinator.isDocumentModified {
                    Button("Save Changes") {
                        Task {
                            await coordinator.saveDocument()
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(nsColor: .systemGray))
        .cornerRadius(8)
    }
}

// MARK: - Export Options Card
struct ExportOptionsCard: View {
    @ObservedObject var coordinator: FileCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export Options")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(ExportFormat.allCases, id: \.self) { format in
                    HStack {
                        Button(format.displayName) {
                            coordinator.exportFormat = format
                            Task {
                                await coordinator.exportDocument()
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(coordinator.isExporting)
                        
                        Spacer()
                        
                        Text(format.fileExtension.uppercased())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(nsColor: .systemGray))
        .cornerRadius(8)
    }
}

// MARK: - Recent Files View
struct RecentFilesView: View {
    @ObservedObject var coordinator: FileCoordinator
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(coordinator.documentService.recentFiles, id: \.self) { url in
                VStack(alignment: .leading, spacing: 4) {
                    Text(url.lastPathComponent)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(url.path)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    Task {
                        try? await coordinator.documentService.loadDocument(from: url)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Recent Files")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 500, height: 400)
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