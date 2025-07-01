import SwiftUI
import Combine

// MARK: - Outline Coordinator
/// Coordinates all outline-related functionality
@MainActor
class OutlineCoordinator: BaseModuleCoordinator {
    // MARK: - Published Properties
    @Published var outlines: [Outline] = []
    @Published var selectedOutline: Outline?
    @Published var showOutlineDetail: Bool = false
    @Published var showOutlineEdit: Bool = false
    @Published var searchText: String = ""
    @Published var selectedFilter: OutlineFilter = .all
    @Published var statistics: OutlineStatistics = OutlineStatistics()
    
    // MARK: - Services
    private let outlineDatabase = OutlineDatabase()
    
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
            return filtered.filter { $0.status == .active }
        case .completed:
            return filtered.filter { $0.status == .completed }
        case .recentlyUpdated:
            return filtered.sorted { $0.updatedAt > $1.updatedAt }
        }
    }
    
    // MARK: - Initialization
    override init(documentService: DocumentService) {
        super.init(documentService: documentService)
        setupOutlineBindings()
    }
    
    // MARK: - Public Methods
    
    override func updateDocument(_ document: ScreenplayDocument?) {
        if let document = document {
            // Parse outlines from Fountain content
            let fountainParser = FountainParser()
            fountainParser.parse(document.content)
            outlineDatabase.parseOutlinesFromFountain(fountainParser.elements)
            
            // Update local state
            outlines = outlineDatabase.outlines
            updateStatistics()
        } else {
            outlines = []
            updateStatistics()
        }
    }
    
    func addOutline(_ outline: Outline) {
        outlineDatabase.addOutline(outline)
        outlines = outlineDatabase.outlines
        updateStatistics()
    }
    
    func updateOutline(_ outline: Outline) {
        outlineDatabase.updateOutline(outline)
        outlines = outlineDatabase.outlines
        updateStatistics()
        
        if selectedOutline?.id == outline.id {
            selectedOutline = outline
        }
    }
    
    func deleteOutline(_ outline: Outline) {
        outlineDatabase.deleteOutline(outline)
        outlines = outlineDatabase.outlines
        updateStatistics()
        
        if selectedOutline?.id == outline.id {
            selectedOutline = nil
            showOutlineDetail = false
        }
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
        let newOutline = Outline(title: "New Outline", description: "")
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
        let outline = Outline(title: "Document Outline", description: "Auto-generated from screenplay")
        
        // Add scenes as outline items
        for (index, element) in fountainParser.elements.enumerated() {
            if case .scene(let sceneTitle) = element {
                let item = OutlineItem(
                    title: sceneTitle,
                    description: "Scene \(index + 1)",
                    type: .scene,
                    status: .planned
                )
                outline.items.append(item)
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