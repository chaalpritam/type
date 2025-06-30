import Foundation
import SwiftUI

class CharacterDatabase: ObservableObject {
    @Published var characters: [Character] = []
    @Published var selectedCharacter: Character?
    @Published var searchFilters = CharacterSearchFilters()
    @Published var statistics = CharacterStatistics(
        totalCharacters: 0,
        charactersWithArcs: 0,
        charactersWithDialogue: 0,
        averageDialogueCount: 0,
        mostActiveCharacter: nil,
        charactersByGender: [:],
        charactersByArcStatus: [:]
    )
    
    private let userDefaults = UserDefaults.standard
    private let charactersKey = "CharacterDatabase.characters"
    
    init() {
        loadCharacters()
        updateStatistics()
    }
    
    // MARK: - Character Management
    
    func addCharacter(_ character: Character) {
        characters.append(character)
        saveCharacters()
        updateStatistics()
    }
    
    func updateCharacter(_ character: Character) {
        if let index = characters.firstIndex(where: { $0.id == character.id }) {
            var updatedCharacter = character
            updatedCharacter.updatedAt = Date()
            characters[index] = updatedCharacter
            saveCharacters()
            updateStatistics()
        }
    }
    
    func deleteCharacter(_ character: Character) {
        characters.removeAll { $0.id == character.id }
        if selectedCharacter?.id == character.id {
            selectedCharacter = nil
        }
        saveCharacters()
        updateStatistics()
    }
    
    func getCharacter(by name: String) -> Character? {
        return characters.first { $0.name.lowercased() == name.lowercased() }
    }
    
    func getCharacter(by id: UUID) -> Character? {
        return characters.first { $0.id == id }
    }
    
    // MARK: - Character Arc Management
    
    func addArc(to character: Character, arc: CharacterArc) {
        if let index = characters.firstIndex(where: { $0.id == character.id }) {
            characters[index].arcs.append(arc)
            saveCharacters()
            updateStatistics()
        }
    }
    
    func updateArc(for character: Character, arc: CharacterArc) {
        if let characterIndex = characters.firstIndex(where: { $0.id == character.id }),
           let arcIndex = characters[characterIndex].arcs.firstIndex(where: { $0.id == arc.id }) {
            var updatedArc = arc
            updatedArc.updatedAt = Date()
            characters[characterIndex].arcs[arcIndex] = updatedArc
            saveCharacters()
            updateStatistics()
        }
    }
    
    func deleteArc(from character: Character, arc: CharacterArc) {
        if let characterIndex = characters.firstIndex(where: { $0.id == character.id }) {
            characters[characterIndex].arcs.removeAll { $0.id == arc.id }
            saveCharacters()
            updateStatistics()
        }
    }
    
    // MARK: - Character Relationship Management
    
    func addRelationship(to character: Character, relationship: CharacterRelationship) {
        if let index = characters.firstIndex(where: { $0.id == character.id }) {
            characters[index].relationships.append(relationship)
            saveCharacters()
        }
    }
    
    func updateRelationship(for character: Character, relationship: CharacterRelationship) {
        if let characterIndex = characters.firstIndex(where: { $0.id == character.id }),
           let relationshipIndex = characters[characterIndex].relationships.firstIndex(where: { $0.id == relationship.id }) {
            characters[characterIndex].relationships[relationshipIndex] = relationship
            saveCharacters()
        }
    }
    
    func deleteRelationship(from character: Character, relationship: CharacterRelationship) {
        if let characterIndex = characters.firstIndex(where: { $0.id == character.id }) {
            characters[characterIndex].relationships.removeAll { $0.id == relationship.id }
            saveCharacters()
        }
    }
    
    // MARK: - Character Note Management
    
    func addNote(to character: Character, note: CharacterNote) {
        if let index = characters.firstIndex(where: { $0.id == character.id }) {
            characters[index].notes.append(note)
            saveCharacters()
        }
    }
    
    func updateNote(for character: Character, note: CharacterNote) {
        if let characterIndex = characters.firstIndex(where: { $0.id == character.id }),
           let noteIndex = characters[characterIndex].notes.firstIndex(where: { $0.id == note.id }) {
            characters[characterIndex].notes[noteIndex] = note
            saveCharacters()
        }
    }
    
    func deleteNote(from character: Character, note: CharacterNote) {
        if let characterIndex = characters.firstIndex(where: { $0.id == character.id }) {
            characters[characterIndex].notes.removeAll { $0.id == note.id }
            saveCharacters()
        }
    }
    
    // MARK: - Fountain Parser Integration
    
    func parseCharactersFromFountain(_ elements: [FountainElement]) {
        var characterAppearances: [String: (first: Int, last: Int, dialogueCount: Int, scenes: Set<String>)] = [:]
        var currentScene = ""
        
        for element in elements {
            switch element.type {
            case .sceneHeading:
                currentScene = element.text
            case .character:
                let characterName = element.text.trimmingCharacters(in: .whitespaces)
                if !characterName.isEmpty {
                    if characterAppearances[characterName] == nil {
                        characterAppearances[characterName] = (element.lineNumber, element.lineNumber, 0, [currentScene])
                    } else {
                        characterAppearances[characterName]?.last = element.lineNumber
                        characterAppearances[characterName]?.scenes.insert(currentScene)
                    }
                }
            case .dialogue:
                // Count dialogue for the most recent character
                if let lastCharacter = elements.prefix(while: { $0.lineNumber < element.lineNumber })
                    .reversed()
                    .first(where: { $0.type == .character }) {
                    let characterName = lastCharacter.text.trimmingCharacters(in: .whitespaces)
                    characterAppearances[characterName]?.dialogueCount += 1
                }
            default:
                break
            }
        }
        
        // Update existing characters or create new ones
        for (characterName, appearances) in characterAppearances {
            if let existingCharacter = getCharacter(by: characterName) {
                var updatedCharacter = existingCharacter
                updatedCharacter.firstAppearance = appearances.first
                updatedCharacter.lastAppearance = appearances.last
                updatedCharacter.dialogueCount = appearances.dialogueCount
                updatedCharacter.sceneCount = appearances.scenes.count
                updateCharacter(updatedCharacter)
            } else {
                var newCharacter = Character(name: characterName)
                newCharacter.firstAppearance = appearances.first
                newCharacter.lastAppearance = appearances.last
                newCharacter.dialogueCount = appearances.dialogueCount
                newCharacter.sceneCount = appearances.scenes.count
                addCharacter(newCharacter)
            }
        }
    }
    
    // MARK: - Search and Filtering
    
    func filteredCharacters() -> [Character] {
        var filtered = characters
        
        // Text search
        if !searchFilters.searchText.isEmpty {
            filtered = filtered.filter { character in
                character.name.localizedCaseInsensitiveContains(searchFilters.searchText) ||
                character.description.localizedCaseInsensitiveContains(searchFilters.searchText) ||
                character.occupation?.localizedCaseInsensitiveContains(searchFilters.searchText) == true ||
                character.tags.contains { $0.localizedCaseInsensitiveContains(searchFilters.searchText) }
            }
        }
        
        // Gender filter
        if let gender = searchFilters.gender {
            filtered = filtered.filter { $0.gender == gender }
        }
        
        // Arc status filter
        if let arcStatus = searchFilters.arcStatus {
            filtered = filtered.filter { character in
                character.arcs.contains { $0.status == arcStatus }
            }
        }
        
        // Has dialogue filter
        if let hasDialogue = searchFilters.hasDialogue {
            filtered = filtered.filter { ($0.dialogueCount > 0) == hasDialogue }
        }
        
        // Has arcs filter
        if let hasArcs = searchFilters.hasArcs {
            filtered = filtered.filter { (!$0.arcs.isEmpty) == hasArcs }
        }
        
        // Tags filter
        if !searchFilters.tags.isEmpty {
            filtered = filtered.filter { character in
                !Set(character.tags).isDisjoint(with: Set(searchFilters.tags))
            }
        }
        
        // Sorting
        filtered.sort { first, second in
            let comparison: Bool
            switch searchFilters.sortBy {
            case .name:
                comparison = first.name < second.name
            case .dialogueCount:
                comparison = first.dialogueCount > second.dialogueCount
            case .sceneCount:
                comparison = first.sceneCount > second.sceneCount
            case .firstAppearance:
                comparison = (first.firstAppearance ?? Int.max) < (second.firstAppearance ?? Int.max)
            case .lastAppearance:
                comparison = (first.lastAppearance ?? Int.max) < (second.lastAppearance ?? Int.max)
            case .createdAt:
                comparison = first.createdAt < second.createdAt
            case .updatedAt:
                comparison = first.updatedAt < second.updatedAt
            }
            return searchFilters.sortOrder == .forward ? comparison : !comparison
        }
        
        return filtered
    }
    
    // MARK: - Statistics
    
    private func updateStatistics() {
        let charactersWithArcs = characters.filter { !$0.arcs.isEmpty }.count
        let charactersWithDialogue = characters.filter { $0.dialogueCount > 0 }.count
        let totalDialogueCount = characters.reduce(0) { $0 + $1.dialogueCount }
        let averageDialogueCount = characters.isEmpty ? 0 : Double(totalDialogueCount) / Double(characters.count)
        let mostActiveCharacter = characters.max { $0.dialogueCount < $1.dialogueCount }
        
        var charactersByGender: [Gender: Int] = [:]
        for gender in Gender.allCases {
            charactersByGender[gender] = characters.filter { $0.gender == gender }.count
        }
        
        var charactersByArcStatus: [ArcStatus: Int] = [:]
        for status in ArcStatus.allCases {
            charactersByArcStatus[status] = characters.filter { character in
                character.arcs.contains { $0.status == status }
            }.count
        }
        
        statistics = CharacterStatistics(
            totalCharacters: characters.count,
            charactersWithArcs: charactersWithArcs,
            charactersWithDialogue: charactersWithDialogue,
            averageDialogueCount: averageDialogueCount,
            mostActiveCharacter: mostActiveCharacter,
            charactersByGender: charactersByGender,
            charactersByArcStatus: charactersByArcStatus
        )
    }
    
    // MARK: - Persistence
    
    private func saveCharacters() {
        if let encoded = try? JSONEncoder().encode(characters) {
            userDefaults.set(encoded, forKey: charactersKey)
        }
    }
    
    private func loadCharacters() {
        if let data = userDefaults.data(forKey: charactersKey),
           let decoded = try? JSONDecoder().decode([Character].self, from: data) {
            characters = decoded
        }
    }
    
    // MARK: - Export/Import
    
    func exportCharacters() -> Data? {
        return try? JSONEncoder().encode(characters)
    }
    
    func importCharacters(from data: Data) -> Bool {
        guard let decoded = try? JSONDecoder().decode([Character].self, from: data) else {
            return false
        }
        characters = decoded
        saveCharacters()
        updateStatistics()
        return true
    }
} 