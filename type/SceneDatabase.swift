import Foundation
import SwiftUI

class SceneDatabase: ObservableObject {
    @Published var scenes: [Scene] = []
    @Published var selectedScene: Scene?
    @Published var currentSceneIndex: Int = 0
    @Published var searchFilters = SceneSearchFilters()
    @Published var statistics = SceneStatistics(
        totalScenes: 0,
        completedScenes: 0,
        totalWordCount: 0,
        totalDialogueCount: 0,
        averageSceneLength: 0,
        longestScene: nil,
        shortestScene: nil,
        scenesByStatus: [:],
        scenesByType: [:],
        scenesByTimeOfDay: [:],
        scenesByLocation: [:],
        scenesByColor: [:]
    )
    @Published var bookmarks: [SceneBookmark] = []
    @Published var recentScenes: [Int] = []
    @Published var favoriteScenes: [Int] = []
    @Published var searchHistory: [String] = []
    
    private let userDefaults = UserDefaults.standard
    private let scenesKey = "SceneDatabase.scenes"
    private let bookmarksKey = "SceneDatabase.bookmarks"
    private let recentScenesKey = "SceneDatabase.recentScenes"
    private let favoriteScenesKey = "SceneDatabase.favoriteScenes"
    private let searchHistoryKey = "SceneDatabase.searchHistory"
    
    init() {
        loadData()
        updateStatistics()
    }
    
    // MARK: - Scene Management
    
    func addScene(_ scene: Scene) {
        scenes.append(scene)
        saveScenes()
        updateStatistics()
    }
    
    func updateScene(_ scene: Scene) {
        if let index = scenes.firstIndex(where: { $0.id == scene.id }) {
            var updatedScene = scene
            updatedScene.updatedAt = Date()
            scenes[index] = updatedScene
            saveScenes()
            updateStatistics()
        }
    }
    
    func deleteScene(_ scene: Scene) {
        scenes.removeAll { $0.id == scene.id }
        if selectedScene?.id == scene.id {
            selectedScene = nil
        }
        saveScenes()
        updateStatistics()
    }
    
    func getScene(by id: UUID) -> Scene? {
        return scenes.first { $0.id == id }
    }
    
    func getScene(by index: Int) -> Scene? {
        guard index >= 0 && index < scenes.count else { return nil }
        return scenes[index]
    }
    
    func getScene(by lineNumber: Int) -> Scene? {
        return scenes.first { $0.lineNumber == lineNumber }
    }
    
    // MARK: - Scene Navigation
    
    func goToScene(_ scene: Scene) {
        if let index = scenes.firstIndex(where: { $0.id == scene.id }) {
            currentSceneIndex = index
            selectedScene = scene
            addToRecentScenes(index)
        }
    }
    
    func goToScene(at index: Int) {
        guard index >= 0 && index < scenes.count else { return }
        currentSceneIndex = index
        selectedScene = scenes[index]
        addToRecentScenes(index)
    }
    
    func nextScene() {
        if currentSceneIndex < scenes.count - 1 {
            goToScene(at: currentSceneIndex + 1)
        }
    }
    
    func previousScene() {
        if currentSceneIndex > 0 {
            goToScene(at: currentSceneIndex - 1)
        }
    }
    
    func goToFirstScene() {
        if !scenes.isEmpty {
            goToScene(at: 0)
        }
    }
    
    func goToLastScene() {
        if !scenes.isEmpty {
            goToScene(at: scenes.count - 1)
        }
    }
    
    // MARK: - Scene Bookmarks
    
    func addBookmark(_ bookmark: SceneBookmark) {
        bookmarks.append(bookmark)
        saveBookmarks()
    }
    
    func updateBookmark(_ bookmark: SceneBookmark) {
        if let index = bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
            bookmarks[index] = bookmark
            saveBookmarks()
        }
    }
    
    func deleteBookmark(_ bookmark: SceneBookmark) {
        bookmarks.removeAll { $0.id == bookmark.id }
        saveBookmarks()
    }
    
    func goToBookmark(_ bookmark: SceneBookmark) {
        goToScene(at: bookmark.sceneIndex)
    }
    
    // MARK: - Recent and Favorite Scenes
    
    private func addToRecentScenes(_ sceneIndex: Int) {
        recentScenes.removeAll { $0 == sceneIndex }
        recentScenes.insert(sceneIndex, at: 0)
        if recentScenes.count > 10 {
            recentScenes = Array(recentScenes.prefix(10))
        }
        saveRecentScenes()
    }
    
    func toggleFavoriteScene(_ sceneIndex: Int) {
        if favoriteScenes.contains(sceneIndex) {
            favoriteScenes.removeAll { $0 == sceneIndex }
        } else {
            favoriteScenes.append(sceneIndex)
        }
        saveFavoriteScenes()
    }
    
    func isFavoriteScene(_ sceneIndex: Int) -> Bool {
        return favoriteScenes.contains(sceneIndex)
    }
    
    // MARK: - Search History
    
    func addToSearchHistory(_ query: String) {
        guard !query.isEmpty else { return }
        searchHistory.removeAll { $0 == query }
        searchHistory.insert(query, at: 0)
        if searchHistory.count > 20 {
            searchHistory = Array(searchHistory.prefix(20))
        }
        saveSearchHistory()
    }
    
    func clearSearchHistory() {
        searchHistory.removeAll()
        saveSearchHistory()
    }
    
    // MARK: - Fountain Parser Integration
    
    func parseScenesFromFountain(_ elements: [FountainElement]) {
        var newScenes: [Scene] = []
        var currentScene: Scene?
        var currentSceneContent: [String] = []
        var sceneNumber = 1
        
        for element in elements {
            switch element.type {
            case .sceneHeading:
                // Save previous scene if exists
                if let scene = currentScene {
                    scene.content = currentSceneContent.joined(separator: "\n")
                    newScenes.append(scene)
                }
                
                // Create new scene
                let scene = Scene(
                    heading: element.text,
                    content: "",
                    lineNumber: element.lineNumber
                )
                currentScene = scene
                currentSceneContent = []
                
                // Parse scene heading for location and time
                parseSceneHeading(scene: &currentScene!, heading: element.text)
                
            case .action, .dialogue, .character, .parenthetical, .transition, .note:
                if currentScene != nil {
                    currentSceneContent.append(element.originalText)
                }
                
            default:
                break
            }
        }
        
        // Add the last scene
        if let scene = currentScene {
            scene.content = currentSceneContent.joined(separator: "\n")
            newScenes.append(scene)
        }
        
        // Update scenes with additional information
        for (index, scene) in newScenes.enumerated() {
            var updatedScene = scene
            updatedScene.sceneNumber = index + 1
            updatedScene.wordCount = countWords(in: scene.content)
            updatedScene.dialogueCount = countDialogue(in: scene.content)
            updatedScene.actionCount = countAction(in: scene.content)
            updatedScene.characters = extractCharacters(from: scene.content)
            newScenes[index] = updatedScene
        }
        
        DispatchQueue.main.async {
            self.scenes = newScenes
            self.saveScenes()
            self.updateStatistics()
        }
    }
    
    private func parseSceneHeading(scene: inout Scene, heading: String) {
        let components = heading.components(separatedBy: " - ")
        if components.count >= 2 {
            scene.location = components[0].trimmingCharacters(in: .whitespaces)
            let timeComponent = components[1].trimmingCharacters(in: .whitespaces)
            scene.timeOfDay = parseTimeOfDay(timeComponent)
        }
        
        // Determine scene type
        if heading.uppercased().contains("INT") {
            scene.sceneType = .interior
        } else if heading.uppercased().contains("EXT") {
            scene.sceneType = .exterior
        } else if heading.uppercased().contains("INT/EXT") || heading.uppercased().contains("I/E") {
            scene.sceneType = .interiorExterior
        } else if heading.uppercased().contains("MONTAGE") {
            scene.sceneType = .montage
        } else if heading.uppercased().contains("FLASHBACK") {
            scene.sceneType = .flashback
        } else if heading.uppercased().contains("DREAM") {
            scene.sceneType = .dream
        } else if heading.uppercased().contains("FANTASY") {
            scene.sceneType = .fantasy
        } else {
            scene.sceneType = .other
        }
    }
    
    private func parseTimeOfDay(_ timeString: String) -> TimeOfDay {
        let time = timeString.uppercased()
        if time.contains("DAY") {
            return .day
        } else if time.contains("NIGHT") {
            return .night
        } else if time.contains("MORNING") {
            return .morning
        } else if time.contains("AFTERNOON") {
            return .afternoon
        } else if time.contains("EVENING") {
            return .evening
        } else if time.contains("DAWN") {
            return .dawn
        } else if time.contains("DUSK") {
            return .dusk
        } else if time.contains("CONTINUOUS") {
            return .continuous
        } else if time.contains("LATER") {
            return .later
        } else if time.contains("SAME TIME") {
            return .sameTime
        } else {
            return .day
        }
    }
    
    private func countWords(in text: String) -> Int {
        return text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
    
    private func countDialogue(in text: String) -> Int {
        let lines = text.components(separatedBy: .newlines)
        return lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return !trimmed.isEmpty && !trimmed.hasPrefix("(") && !trimmed.hasPrefix("[") && !trimmed.hasPrefix("INT") && !trimmed.hasPrefix("EXT")
        }.count
    }
    
    private func countAction(in text: String) -> Int {
        let lines = text.components(separatedBy: .newlines)
        return lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return !trimmed.isEmpty && !trimmed.hasPrefix("(") && !trimmed.hasPrefix("[") && !trimmed.hasPrefix("INT") && !trimmed.hasPrefix("EXT") && !trimmed.matches(pattern: "^[A-Z][A-Z\\s]+$")
        }.count
    }
    
    private func extractCharacters(from text: String) -> [String] {
        let lines = text.components(separatedBy: .newlines)
        var characters: Set<String> = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.matches(pattern: "^[A-Z][A-Z\\s]+$") {
                characters.insert(trimmed)
            }
        }
        
        return Array(characters)
    }
    
    // MARK: - Search and Filtering
    
    func filteredScenes() -> [Scene] {
        var filtered = scenes
        
        // Text search
        if !searchFilters.searchText.isEmpty {
            filtered = filtered.filter { scene in
                scene.heading.localizedCaseInsensitiveContains(searchFilters.searchText) ||
                scene.content.localizedCaseInsensitiveContains(searchFilters.searchText) ||
                scene.location.localizedCaseInsensitiveContains(searchFilters.searchText) ||
                scene.tags.contains { $0.localizedCaseInsensitiveContains(searchFilters.searchText) }
            }
        }
        
        // Scene type filter
        if let sceneType = searchFilters.sceneType {
            filtered = filtered.filter { $0.sceneType == sceneType }
        }
        
        // Time of day filter
        if let timeOfDay = searchFilters.timeOfDay {
            filtered = filtered.filter { $0.timeOfDay == timeOfDay }
        }
        
        // Status filter
        if let status = searchFilters.status {
            filtered = filtered.filter { $0.status == status }
        }
        
        // Color filter
        if let color = searchFilters.color {
            filtered = filtered.filter { $0.color == color }
        }
        
        // Mood filter
        if let mood = searchFilters.mood {
            // This would require mood to be set on scenes
            // For now, we'll skip this filter
        }
        
        // Tension filter
        if let tension = searchFilters.tension {
            // This would require tension to be set on scenes
            // For now, we'll skip this filter
        }
        
        // Location filter
        if !searchFilters.location.isEmpty {
            filtered = filtered.filter { $0.location.localizedCaseInsensitiveContains(searchFilters.location) }
        }
        
        // Characters filter
        if !searchFilters.characters.isEmpty {
            filtered = filtered.filter { scene in
                !Set(scene.characters).isDisjoint(with: Set(searchFilters.characters))
            }
        }
        
        // Tags filter
        if !searchFilters.tags.isEmpty {
            filtered = filtered.filter { scene in
                !Set(scene.tags).isDisjoint(with: Set(searchFilters.tags))
            }
        }
        
        // Completion filter
        if let isCompleted = searchFilters.isCompleted {
            filtered = filtered.filter { $0.isCompleted == isCompleted }
        }
        
        // Importance filter
        if let isImportant = searchFilters.isImportant {
            filtered = filtered.filter { $0.isImportant == isImportant }
        }
        
        // Sorting
        filtered.sort { first, second in
            let comparison: Bool
            switch searchFilters.sortBy {
            case .order:
                comparison = first.sceneNumber ?? 0 < second.sceneNumber ?? 0
            case .heading:
                comparison = first.heading < second.heading
            case .location:
                comparison = first.location < second.location
            case .timeOfDay:
                comparison = first.timeOfDay.rawValue < second.timeOfDay.rawValue
            case .status:
                comparison = first.status.rawValue < second.status.rawValue
            case .wordCount:
                comparison = first.wordCount > second.wordCount
            case .dialogueCount:
                comparison = first.dialogueCount > second.dialogueCount
            case .createdAt:
                comparison = first.createdAt < second.createdAt
            case .updatedAt:
                comparison = first.updatedAt < second.updatedAt
            }
            return searchFilters.sortOrder == .ascending ? comparison : !comparison
        }
        
        return filtered
    }
    
    // MARK: - Statistics
    
    private func updateStatistics() {
        let completedScenes = scenes.filter { $0.isCompleted }.count
        let totalWordCount = scenes.reduce(0) { $0 + $1.wordCount }
        let totalDialogueCount = scenes.reduce(0) { $0 + $1.dialogueCount }
        let averageSceneLength = scenes.isEmpty ? 0 : Double(totalWordCount) / Double(scenes.count)
        let longestScene = scenes.max { $0.wordCount < $1.wordCount }
        let shortestScene = scenes.min { $0.wordCount < $1.wordCount }
        
        var scenesByStatus: [SceneStatus: Int] = [:]
        for status in SceneStatus.allCases {
            scenesByStatus[status] = scenes.filter { $0.status == status }.count
        }
        
        var scenesByType: [SceneType: Int] = [:]
        for type in SceneType.allCases {
            scenesByType[type] = scenes.filter { $0.sceneType == type }.count
        }
        
        var scenesByTimeOfDay: [TimeOfDay: Int] = [:]
        for time in TimeOfDay.allCases {
            scenesByTimeOfDay[time] = scenes.filter { $0.timeOfDay == time }.count
        }
        
        var scenesByLocation: [String: Int] = [:]
        for scene in scenes {
            scenesByLocation[scene.location, default: 0] += 1
        }
        
        var scenesByColor: [SceneColor: Int] = [:]
        for color in SceneColor.allCases {
            scenesByColor[color] = scenes.filter { $0.color == color }.count
        }
        
        statistics = SceneStatistics(
            totalScenes: scenes.count,
            completedScenes: completedScenes,
            totalWordCount: totalWordCount,
            totalDialogueCount: totalDialogueCount,
            averageSceneLength: averageSceneLength,
            longestScene: longestScene,
            shortestScene: shortestScene,
            scenesByStatus: scenesByStatus,
            scenesByType: scenesByType,
            scenesByTimeOfDay: scenesByTimeOfDay,
            scenesByLocation: scenesByLocation,
            scenesByColor: scenesByColor
        )
    }
    
    // MARK: - Persistence
    
    private func saveScenes() {
        if let encoded = try? JSONEncoder().encode(scenes) {
            userDefaults.set(encoded, forKey: scenesKey)
        }
    }
    
    private func saveBookmarks() {
        if let encoded = try? JSONEncoder().encode(bookmarks) {
            userDefaults.set(encoded, forKey: bookmarksKey)
        }
    }
    
    private func saveRecentScenes() {
        if let encoded = try? JSONEncoder().encode(recentScenes) {
            userDefaults.set(encoded, forKey: recentScenesKey)
        }
    }
    
    private func saveFavoriteScenes() {
        if let encoded = try? JSONEncoder().encode(favoriteScenes) {
            userDefaults.set(encoded, forKey: favoriteScenesKey)
        }
    }
    
    private func saveSearchHistory() {
        if let encoded = try? JSONEncoder().encode(searchHistory) {
            userDefaults.set(encoded, forKey: searchHistoryKey)
        }
    }
    
    private func loadData() {
        // Load scenes
        if let data = userDefaults.data(forKey: scenesKey),
           let decoded = try? JSONDecoder().decode([Scene].self, from: data) {
            scenes = decoded
        }
        
        // Load bookmarks
        if let data = userDefaults.data(forKey: bookmarksKey),
           let decoded = try? JSONDecoder().decode([SceneBookmark].self, from: data) {
            bookmarks = decoded
        }
        
        // Load recent scenes
        if let data = userDefaults.data(forKey: recentScenesKey),
           let decoded = try? JSONDecoder().decode([Int].self, from: data) {
            recentScenes = decoded
        }
        
        // Load favorite scenes
        if let data = userDefaults.data(forKey: favoriteScenesKey),
           let decoded = try? JSONDecoder().decode([Int].self, from: data) {
            favoriteScenes = decoded
        }
        
        // Load search history
        if let data = userDefaults.data(forKey: searchHistoryKey),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            searchHistory = decoded
        }
    }
    
    // MARK: - Export/Import
    
    func exportScenes() -> Data? {
        return try? JSONEncoder().encode(scenes)
    }
    
    func importScenes(from data: Data) -> Bool {
        guard let decoded = try? JSONDecoder().decode([Scene].self, from: data) else {
            return false
        }
        scenes = decoded
        saveScenes()
        updateStatistics()
        return true
    }
}

// MARK: - String Extension for Pattern Matching
extension String {
    func matches(pattern: String) -> Bool {
        return range(of: pattern, options: .regularExpression) != nil
    }
} 