import SwiftUI
import Combine
import UniformTypeIdentifiers
import AppKit

// MARK: - Outline Coordinator
/// Coordinates all outline-related functionality
@MainActor
class OutlineCoordinator: BaseModuleCoordinator, ModuleCoordinator {
    typealias ModuleView = OutlineMainView
    
    // MARK: - Published Properties
    @Published var outlines: [Outline] = []
    @Published var selectedOutline: Outline?
    @Published var showOutlineDetail: Bool = false
    @Published var showOutlineEdit: Bool = false
    @Published var showOutlineMode: Bool = false
    @Published var searchText: String = ""
    @Published var selectedFilter: OutlineFilter = .all
    @Published var statistics: OutlineStatistics = OutlineStatistics(
        totalNodes: 0,
        totalSections: 0,
        totalWords: 0,
        averageWordsPerNode: 0.0,
        completedNodes: 0,
        nodesByType: [:],
        nodesByStatus: [:],
        nodesByPriority: [:],
        depthDistribution: [:],
        outlineHealth: OutlineHealth(overallHealth: 0.0, issues: [], recommendations: [], strengths: [])
    )
    
    // MARK: - Services
    let outlineDatabase = OutlineDatabase()
    
    // MARK: - Computed Properties
    var filteredOutlines: [Outline] {
        let filtered = outlines.filter { outline in
            if !searchText.isEmpty {
                return outline.title.localizedCaseInsensitiveContains(searchText) ||
                       outline.description.localizedCaseInsensitiveContains(searchText)
            }
            return true
        }
        
        switch selectedFilter {
        case .all:
            return filtered
        case .active:
            return filtered
        case .completed:
            return filtered
        case .recentlyUpdated:
            return filtered.sorted { $0.updatedAt > $1.updatedAt }
        }
    }
    
    // MARK: - Initialization
    override init(documentService: DocumentService) {
        super.init(documentService: documentService)
        Task { @MainActor in
            setupOutlineBindings()
        }
    }
    
    // MARK: - ModuleCoordinator Implementation
    
    func createView() -> OutlineMainView {
        return OutlineMainView(coordinator: self)
    }
    
    // MARK: - Public Methods
    
    override func updateDocument(_ document: ScreenplayDocument?) {
        Task { @MainActor in
            if let document = document {
                // Update outline database with new document
                outlineDatabase.updateOutline(outlineDatabase.outline)
                updateStatistics()
            } else {
                // Clear outline when no document
                updateStatistics()
            }
        }
    }
    
    func addOutline(_ outline: Outline) {
        outlines.append(outline)
        updateStatistics()
    }
    
    func updateOutline(_ outline: Outline) {
        if let index = outlines.firstIndex(where: { $0.id == outline.id }) {
            outlines[index] = outline
            updateStatistics()
        }
    }
    
    func deleteOutline(_ outline: Outline) {
        outlines.removeAll { $0.id == outline.id }
        if selectedOutline?.id == outline.id {
            selectedOutline = nil
            showOutlineDetail = false
        }
        updateStatistics()
    }
    
    func selectOutline(_ outline: Outline) {
        selectedOutline = outline
        showOutlineDetail = true
    }
    
    func editOutline(_ outline: Outline) {
        selectedOutline = outline
        showOutlineEdit = true
    }
    
    func createNewOutline() {
        let newOutline = Outline(title: "New Outline", description: "Outline description")
        selectedOutline = newOutline
        showOutlineEdit = true
    }
    
    func searchOutlines(_ query: String) {
        searchText = query
    }
    
    func applyFilter(_ filter: OutlineFilter) {
        selectedFilter = filter
    }
    
    func generateOutlineFromDocument() {
        guard let document = documentService.currentDocument else { return }
        
        let fountainParser = FountainParser()
        fountainParser.parse(document.content)
        
        // Create outline from parsed elements
        var outline = Outline(title: "Document Outline", description: "Auto-generated from screenplay")
        
        // Add scenes as outline nodes
        for (index, element) in fountainParser.elements.enumerated() {
            if element.type == .sceneHeading {
                let node = OutlineNode(
                    title: element.text,
                    nodeType: .scene
                )
                outline.rootNodes.append(node)
            }
        }
        
        addOutline(outline)
    }
    
    func exportOutline(_ outline: Outline) async throws -> URL? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.json]
        panel.nameFieldStringValue = "\(outline.title).json"
        panel.title = "Export Outline"
        panel.message = "Choose a location to save the outline data"
        
        let response = await panel.beginSheetModal(for: NSApp.keyWindow!)
        
        if response == .OK, let url = panel.url {
            let data = try JSONEncoder().encode(outline)
            try data.write(to: url)
            return url
        }
        
        return nil
    }
    
    func importOutline() async throws -> URL? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.json]
        panel.allowsMultipleSelection = false
        panel.title = "Import Outline"
        panel.message = "Choose an outline data file to import"
        
        let response = await panel.beginSheetModal(for: NSApp.keyWindow!)
        
        if response == .OK, let url = panel.url {
            let data = try Data(contentsOf: url)
            let importedOutline = try JSONDecoder().decode(Outline.self, from: data)
            
            // Add to existing outlines
            addOutline(importedOutline)
            
            return url
        }
        
        return nil
    }
    
    // MARK: - Private Methods
    
    private func setupOutlineBindings() {
        // Listen for document changes
        documentService.$currentDocument
            .sink { [weak self] document in
                self?.updateDocument(document)
            }
            .store(in: &cancellables)
    }
    
    private func updateStatistics() {
        statistics = outlineDatabase.statistics
    }
}

// MARK: - Outline Main View
struct OutlineMainView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var coordinator: OutlineCoordinator
    
    var body: some View {
        OutlineView(
            outlineDatabase: coordinator.outlineDatabase,
            isVisible: .constant(true)
        )
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
    }
}

// MARK: - Outline Edit View
struct OutlineEditView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    let outline: Outline
    @ObservedObject var coordinator: OutlineCoordinator
    @State private var title: String
    @State private var description: String
    
    init(outline: Outline, coordinator: OutlineCoordinator) {
        self.outline = outline
        self.coordinator = coordinator
        self._title = State(initialValue: outline.title)
        self._description = State(initialValue: outline.description)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ModalHeader(
                title: "Edit Outline",
                onCancel: { dismiss() },
                onSave: {
                    var updatedOutline = outline
                    updatedOutline.title = title
                    updatedOutline.description = description
                    coordinator.updateOutline(updatedOutline)
                    dismiss()
                },
                canSave: !title.isEmpty
            )
            
            ScrollView {
                VStack(spacing: TypeSpacing.xl) {
                    ModalSection(title: "Basic Information") {
                        VStack(spacing: TypeSpacing.md) {
                            ModalTextField(label: "Title", placeholder: "Outline title", text: $title)
                            ModalTextArea(label: "Description", placeholder: "Outline description", text: $description)
                        }
                    }
                }
                .padding(TypeSpacing.xl)
            }
        }
        .frame(minWidth: 400, minHeight: 300)
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
    }
}

// MARK: - Outline Filter
enum OutlineFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
    case recentlyUpdated = "Recently Updated"
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .active: return "play.circle"
        case .completed: return "checkmark.circle"
        case .recentlyUpdated: return "clock"
        }
    }
} 