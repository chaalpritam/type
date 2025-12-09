import SwiftUI
import Combine
import UniformTypeIdentifiers
import AppKit

// MARK: - Character Coordinator
/// Coordinates all character-related functionality
@MainActor
class CharacterCoordinator: BaseModuleCoordinator, ModuleCoordinator {
    typealias ModuleView = CharacterMainView
    
    // MARK: - Published Properties
    @Published var characters: [Character] = []
    @Published var selectedCharacter: Character?
    @Published var showCharacterDetail: Bool = false
    @Published var showCharacterEdit: Bool = false
    @Published var showCharacterDatabase: Bool = false
    @Published var searchText: String = ""
    @Published var selectedFilter: CharacterFilter = .all
    @Published var statistics: CharacterStatistics = CharacterStatistics(
        totalCharacters: 0,
        charactersWithArcs: 0,
        charactersWithDialogue: 0,
        averageDialogueCount: 0.0,
        mostActiveCharacter: nil,
        charactersByGender: [:],
        charactersByArcStatus: [:]
    )
    
    // MARK: - Services
    let characterDatabase = CharacterDatabase()
    
    // MARK: - Computed Properties
    var filteredCharacters: [Character] {
        let filtered = characters.filter { character in
            if !searchText.isEmpty {
                return character.name.localizedCaseInsensitiveContains(searchText) ||
                       character.description.localizedCaseInsensitiveContains(searchText)
            }
            return true
        }
        
        switch selectedFilter {
        case .all:
            return filtered
        case .withDialogue:
            return filtered.filter { $0.dialogueCount > 0 }
        case .withArcs:
            return filtered.filter { !$0.arcs.isEmpty }
        case .recentlyUpdated:
            return filtered.sorted { $0.updatedAt > $1.updatedAt }
        }
    }
    
    // MARK: - Initialization
    override init(documentService: DocumentService) {
        super.init(documentService: documentService)
        Task { @MainActor in
            setupCharacterBindings()
        }
    }
    
    // MARK: - ModuleCoordinator Implementation
    
    func createView() -> CharacterMainView {
        return CharacterMainView(coordinator: self)
    }
    
    // MARK: - Public Methods
    
    override func updateDocument(_ document: ScreenplayDocument?) {
        Task { @MainActor in
            if let document = document {
                // Parse characters from Fountain content
                let fountainParser = FountainParser()
                fountainParser.parse(document.content)
                characterDatabase.parseCharactersFromFountain(fountainParser.elements)
                
                // Update local state
                characters = characterDatabase.characters
                updateStatistics()
            } else {
                characters = []
                updateStatistics()
            }
        }
    }
    
    func addCharacter(_ character: Character) {
        characterDatabase.addCharacter(character)
        characters = characterDatabase.characters
        updateStatistics()
    }
    
    func updateCharacter(_ character: Character) {
        characterDatabase.updateCharacter(character)
        characters = characterDatabase.characters
        updateStatistics()
        
        if selectedCharacter?.id == character.id {
            selectedCharacter = character
        }
    }
    
    func deleteCharacter(_ character: Character) {
        characterDatabase.deleteCharacter(character)
        characters = characterDatabase.characters
        updateStatistics()
        
        if selectedCharacter?.id == character.id {
            selectedCharacter = nil
            showCharacterDetail = false
        }
    }
    
    func selectCharacter(_ character: Character) {
        selectedCharacter = character
        showCharacterDetail = true
    }
    
    func editCharacter(_ character: Character) {
        selectedCharacter = character
        showCharacterEdit = true
    }
    
    func createNewCharacter() {
        let newCharacter = Character(name: "New Character")
        selectedCharacter = newCharacter
        showCharacterEdit = true
    }
    
    func searchCharacters(_ query: String) {
        searchText = query
    }
    
    func applyFilter(_ filter: CharacterFilter) {
        selectedFilter = filter
    }
    
    func exportCharacters() async throws -> URL? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.json]
        panel.nameFieldStringValue = "Characters.json"
        panel.title = "Export Characters"
        panel.message = "Choose a location to save the character data"
        
        let response = await panel.beginSheetModal(for: NSApp.keyWindow!)
        
        if response == .OK, let url = panel.url {
            let data = try JSONEncoder().encode(characters)
            try data.write(to: url)
            return url
        }
        
        return nil
    }
    
    func importCharacters() async throws -> URL? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.json]
        panel.allowsMultipleSelection = false
        panel.title = "Import Characters"
        panel.message = "Choose a character data file to import"
        
        let response = await panel.beginSheetModal(for: NSApp.keyWindow!)
        
        if response == .OK, let url = panel.url {
            let data = try Data(contentsOf: url)
            let importedCharacters = try JSONDecoder().decode([Character].self, from: data)
            
            // Merge with existing characters
            for character in importedCharacters {
                if !characters.contains(where: { $0.id == character.id }) {
                    addCharacter(character)
                }
            }
            
            return url
        }
        
        return nil
    }
    
    // MARK: - Private Methods
    
    private func setupCharacterBindings() {
        // Listen for document changes
        documentService.$currentDocument
            .sink { [weak self] document in
                self?.updateDocument(document)
            }
            .store(in: &cancellables)
    }
    
    private func updateStatistics() {
        statistics = characterDatabase.statistics
    }
}

// MARK: - Character Main View
struct CharacterMainView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var coordinator: CharacterCoordinator
    
    var body: some View {
        CharacterDatabaseView(
            characterDatabase: coordinator.characterDatabase,
            isVisible: .constant(true)
        )
        .background(colorScheme == .dark ? TypeColors.editorBackgroundDark : TypeColors.editorBackgroundLight)
    }
}

// MARK: - Character Filter
enum CharacterFilter: String, CaseIterable {
    case all = "All"
    case withDialogue = "With Dialogue"
    case withArcs = "With Arcs"
    case recentlyUpdated = "Recently Updated"
    
    var icon: String {
        switch self {
        case .all: return "person.2"
        case .withDialogue: return "message"
        case .withArcs: return "chart.line.uptrend.xyaxis"
        case .recentlyUpdated: return "clock"
        }
    }
} 