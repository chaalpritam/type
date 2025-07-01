import SwiftUI
import Combine
import Data.OutlineModels
import Features.Outline.OutlineDatabase
import Features.Editor.FountainParser
import Data.ScreenplayDocument
import Services.DocumentService
import Core.ModuleCoordinator

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
    
    // MARK: - ModuleCoordinator Implementation
    
    func createView() -> OutlineMainView {
        return OutlineMainView(coordinator: self)
    }
    
    // MARK: - Public Methods
    
    override func updateDocument(_ document: ScreenplayDocument?) {
        if let document = document {
            // Update outline database with new document
            outlineDatabase.updateOutline(outlineDatabase.outline)
            updateStatistics()
        } else {
            // Clear outline when no document
            updateStatistics()
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

// MARK: - Outline Main View
struct OutlineMainView: View {
    @ObservedObject var coordinator: OutlineCoordinator
    
    var body: some View {
        HStack(spacing: 0) {
            // Main outline view
            VStack(spacing: 0) {
                // Outline toolbar
                OutlineToolbarView(coordinator: coordinator)
                
                // Outline content
                OutlineView(
                    outlineDatabase: coordinator.outlineDatabase,
                    isVisible: .constant(true)
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Detail panel
            if coordinator.showOutlineDetail, let outline = coordinator.selectedOutline {
                OutlineDetailPanel(outline: outline, coordinator: coordinator)
                    .frame(width: 350)
                    .transition(.move(edge: .trailing))
            }
        }
        .sheet(isPresented: $coordinator.showOutlineEdit) {
            if let outline = coordinator.selectedOutline {
                OutlineEditView(outline: outline, coordinator: coordinator)
            }
        }
    }
}

// MARK: - Outline Toolbar View
struct OutlineToolbarView: View {
    @ObservedObject var coordinator: OutlineCoordinator
    
    var body: some View {
        HStack(spacing: 12) {
            // Outline operations
            HStack(spacing: 8) {
                Button("New Outline") {
                    coordinator.createNewOutline()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Generate from Document") {
                    coordinator.generateOutlineFromDocument()
                }
                .buttonStyle(.bordered)
                
                Button("Import") {
                    Task {
                        try? await coordinator.importOutline()
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Divider()
            
            // Filter controls
            HStack(spacing: 8) {
                Picker("Filter", selection: $coordinator.selectedFilter) {
                    ForEach(OutlineFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.menu)
            }
            
            Spacer()
            
            // Statistics
            HStack(spacing: 16) {
                Text("Total Nodes: \(coordinator.statistics.totalNodes)")
                    .font(.caption)
                Text("Total Sections: \(coordinator.statistics.totalSections)")
                    .font(.caption)
                Text("Total Words: \(coordinator.statistics.totalWords)")
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

// MARK: - Outline Detail Panel
struct OutlineDetailPanel: View {
    let outline: Outline
    @ObservedObject var coordinator: OutlineCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Outline Details")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Title: \(outline.title)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Description: \(outline.description)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Status: \(outline.status.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Items: \(outline.items.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .border(Color(.systemGray4), width: 0.5)
    }
}

// MARK: - Outline Edit View
struct OutlineEditView: View {
    let outline: Outline
    @ObservedObject var coordinator: OutlineCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var description: String
    @State private var status: OutlineStatus
    
    init(outline: Outline, coordinator: OutlineCoordinator) {
        self.outline = outline
        self.coordinator = coordinator
        self._title = State(initialValue: outline.title)
        self._description = State(initialValue: outline.description)
        self._status = State(initialValue: outline.status)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    Picker("Status", selection: $status) {
                        ForEach(OutlineStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
            }
            .navigationTitle("Edit Outline")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        var updatedOutline = outline
                        updatedOutline.title = title
                        updatedOutline.description = description
                        updatedOutline.status = status
                        coordinator.updateOutline(updatedOutline)
                        dismiss()
                    }
                }
            }
        }
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