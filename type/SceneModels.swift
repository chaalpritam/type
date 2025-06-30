import Foundation
import SwiftUI

// MARK: - Scene Model
struct Scene: Identifiable, Codable, Hashable {
    let id = UUID()
    var heading: String
    var content: String
    var lineNumber: Int
    var actNumber: Int?
    var sequenceNumber: Int?
    var sceneNumber: Int?
    var duration: SceneDuration?
    var location: String
    var timeOfDay: TimeOfDay
    var sceneType: SceneType
    var status: SceneStatus
    var characters: [String]
    var dialogueCount: Int
    var actionCount: Int
    var wordCount: Int
    var notes: [SceneNote]
    var tags: [String]
    var color: SceneColor
    var isCompleted: Bool
    var isImportant: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(heading: String, content: String, lineNumber: Int) {
        self.heading = heading
        self.content = content
        self.lineNumber = lineNumber
        self.location = ""
        self.timeOfDay = .day
        self.sceneType = .interior
        self.status = .draft
        self.characters = []
        self.dialogueCount = 0
        self.actionCount = 0
        self.wordCount = 0
        self.notes = []
        self.tags = []
        self.color = .blue
        self.isCompleted = false
        self.isImportant = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Scene Card Model
struct SceneCard: Identifiable, Codable, Hashable {
    let id = UUID()
    var scene: Scene
    var thumbnail: String
    var summary: String
    var keyMoments: [String]
    var mood: SceneMood
    var tension: TensionLevel
    var isExpanded: Bool
    
    init(scene: Scene) {
        self.scene = scene
        self.thumbnail = ""
        self.summary = ""
        self.keyMoments = []
        self.mood = .neutral
        self.tension = .medium
        self.isExpanded = false
    }
}

// MARK: - Scene Navigation Model
struct SceneNavigation: Identifiable, Codable, Hashable {
    let id = UUID()
    var currentSceneIndex: Int
    var scenes: [Scene]
    var bookmarks: [SceneBookmark]
    var recentScenes: [Int]
    var favoriteScenes: [Int]
    var searchHistory: [String]
    
    init(scenes: [Scene] = []) {
        self.currentSceneIndex = 0
        self.scenes = scenes
        self.bookmarks = []
        self.recentScenes = []
        self.favoriteScenes = []
        self.searchHistory = []
    }
}

// MARK: - Scene Bookmark
struct SceneBookmark: Identifiable, Codable, Hashable {
    let id = UUID()
    var sceneIndex: Int
    var name: String
    var description: String
    var color: SceneColor
    var createdAt: Date
    
    init(sceneIndex: Int, name: String, description: String = "") {
        self.sceneIndex = sceneIndex
        self.name = name
        self.description = description
        self.color = .yellow
        self.createdAt = Date()
    }
}

// MARK: - Scene Note
struct SceneNote: Identifiable, Codable, Hashable {
    let id = UUID()
    var title: String
    var content: String
    var type: SceneNoteType
    var lineNumber: Int?
    var createdAt: Date
    
    init(title: String, content: String, type: SceneNoteType = .general) {
        self.title = title
        self.content = content
        self.type = type
        self.createdAt = Date()
    }
}

// MARK: - Enums
enum SceneType: String, CaseIterable, Codable {
    case interior = "Interior"
    case exterior = "Exterior"
    case interiorExterior = "Interior/Exterior"
    case montage = "Montage"
    case flashback = "Flashback"
    case dream = "Dream"
    case fantasy = "Fantasy"
    case other = "Other"
}

enum TimeOfDay: String, CaseIterable, Codable {
    case day = "Day"
    case night = "Night"
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case dawn = "Dawn"
    case dusk = "Dusk"
    case continuous = "Continuous"
    case later = "Later"
    case sameTime = "Same Time"
}

enum SceneStatus: String, CaseIterable, Codable {
    case draft = "Draft"
    case outline = "Outline"
    case inProgress = "In Progress"
    case completed = "Completed"
    case revised = "Revised"
    case final = "Final"
    case archived = "Archived"
}

enum SceneColor: String, CaseIterable, Codable {
    case blue = "Blue"
    case green = "Green"
    case yellow = "Yellow"
    case orange = "Orange"
    case red = "Red"
    case purple = "Purple"
    case gray = "Gray"
    case pink = "Pink"
    case teal = "Teal"
    case brown = "Brown"
    
    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        case .orange: return .orange
        case .red: return .red
        case .purple: return .purple
        case .gray: return .gray
        case .pink: return .pink
        case .teal: return .teal
        case .brown: return .brown
        }
    }
}

enum SceneMood: String, CaseIterable, Codable {
    case happy = "Happy"
    case sad = "Sad"
    case tense = "Tense"
    case peaceful = "Peaceful"
    case chaotic = "Chaotic"
    case mysterious = "Mysterious"
    case romantic = "Romantic"
    case action = "Action"
    case comedic = "Comedic"
    case dramatic = "Dramatic"
    case neutral = "Neutral"
}

enum TensionLevel: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case extreme = "Extreme"
}

enum SceneNoteType: String, CaseIterable, Codable {
    case general = "General"
    case blocking = "Blocking"
    case dialogue = "Dialogue"
    case action = "Action"
    case character = "Character"
    case setting = "Setting"
    case technical = "Technical"
    case revision = "Revision"
    case research = "Research"
    case inspiration = "Inspiration"
}

enum SceneDuration: String, CaseIterable, Codable {
    case short = "Short (< 1 page)"
    case medium = "Medium (1-3 pages)"
    case long = "Long (3-5 pages)"
    case veryLong = "Very Long (> 5 pages)"
}

enum SceneViewMode: String, CaseIterable {
    case cards = "Cards"
    case list = "List"
    case timeline = "Timeline"
    case grid = "Grid"
}

enum SceneSortOption: String, CaseIterable {
    case order = "Scene Order"
    case heading = "Scene Heading"
    case location = "Location"
    case timeOfDay = "Time of Day"
    case status = "Status"
    case wordCount = "Word Count"
    case dialogueCount = "Dialogue Count"
    case createdAt = "Created Date"
    case updatedAt = "Updated Date"
}

// MARK: - Scene Statistics
struct SceneStatistics {
    let totalScenes: Int
    let completedScenes: Int
    let totalWordCount: Int
    let totalDialogueCount: Int
    let averageSceneLength: Double
    let longestScene: Scene?
    let shortestScene: Scene?
    let scenesByStatus: [SceneStatus: Int]
    scenesByType: [SceneType: Int]
    scenesByTimeOfDay: [TimeOfDay: Int]
    scenesByLocation: [String: Int]
    scenesByColor: [SceneColor: Int]
}

// MARK: - Scene Search Filters
struct SceneSearchFilters {
    var searchText: String = ""
    var sceneType: SceneType?
    var timeOfDay: TimeOfDay?
    var status: SceneStatus?
    var color: SceneColor?
    var mood: SceneMood?
    var tension: TensionLevel?
    var location: String = ""
    var characters: [String] = []
    var tags: [String] = []
    var isCompleted: Bool?
    var isImportant: Bool?
    var sortBy: SceneSortOption = .order
    var sortOrder: SortOrder = .ascending
    var viewMode: SceneViewMode = .cards
}

// MARK: - Scene Outline
struct SceneOutline: Identifiable, Codable, Hashable {
    let id = UUID()
    var title: String
    var description: String
    var scenes: [SceneOutlineItem]
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, description: String = "") {
        self.title = title
        self.description = description
        self.scenes = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct SceneOutlineItem: Identifiable, Codable, Hashable {
    let id = UUID()
    var sceneIndex: Int
    var title: String
    var description: String
    var status: SceneStatus
    var order: Int
    var notes: String
    
    init(sceneIndex: Int, title: String, description: String = "") {
        self.sceneIndex = sceneIndex
        self.title = title
        self.description = description
        self.status = .outline
        self.order = 0
        self.notes = ""
    }
} 