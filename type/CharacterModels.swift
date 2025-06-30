import Foundation
import SwiftUI

// MARK: - Character Model
struct Character: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var age: Int?
    var gender: Gender?
    var occupation: String?
    var appearance: String?
    var personality: String?
    var background: String?
    var goals: [String]
    var conflicts: [String]
    var relationships: [CharacterRelationship]
    var arcs: [CharacterArc]
    var firstAppearance: Int? // Line number in screenplay
    var lastAppearance: Int? // Line number in screenplay
    var dialogueCount: Int
    var sceneCount: Int
    var tags: [String]
    var notes: [CharacterNote]
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, description: String = "") {
        self.id = UUID()
        self.name = name
        self.description = description
        self.goals = []
        self.conflicts = []
        self.relationships = []
        self.arcs = []
        self.dialogueCount = 0
        self.sceneCount = 0
        self.tags = []
        self.notes = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Character Arc Model
struct CharacterArc: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var arcType: ArcType
    var startScene: String?
    var endScene: String?
    var milestones: [ArcMilestone]
    var status: ArcStatus
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, description: String = "", arcType: ArcType = .character) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.arcType = arcType
        self.milestones = []
        self.status = .planned
        self.notes = ""
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Arc Milestone
struct ArcMilestone: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var scene: String?
    var lineNumber: Int?
    var status: MilestoneStatus
    var notes: String
    var createdAt: Date
    
    init(name: String, description: String = "") {
        self.id = UUID()
        self.name = name
        self.description = description
        self.status = .planned
        self.notes = ""
        self.createdAt = Date()
    }
}

// MARK: - Character Relationship
struct CharacterRelationship: Identifiable, Codable, Hashable {
    let id: UUID
    var targetCharacter: String
    var relationshipType: RelationshipType
    var description: String
    var strength: RelationshipStrength
    var notes: String
    var createdAt: Date
    
    init(targetCharacter: String, relationshipType: RelationshipType = .neutral) {
        self.id = UUID()
        self.targetCharacter = targetCharacter
        self.relationshipType = relationshipType
        self.description = ""
        self.strength = .medium
        self.notes = ""
        self.createdAt = Date()
    }
}

// MARK: - Character Note
struct CharacterNote: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var type: NoteType
    var scene: String?
    var lineNumber: Int?
    var createdAt: Date
    
    init(title: String, content: String, type: NoteType = .general) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.type = type
        self.createdAt = Date()
    }
}

// MARK: - Enums
enum Gender: String, CaseIterable, Codable {
    case male = "Male"
    case female = "Female"
    case nonBinary = "Non-binary"
    case other = "Other"
    case unspecified = "Unspecified"
}

enum ArcType: String, CaseIterable, Codable {
    case character = "Character Development"
    case relationship = "Relationship"
    case plot = "Plot"
    case emotional = "Emotional"
    case physical = "Physical"
    case spiritual = "Spiritual"
    case professional = "Professional"
    case personal = "Personal"
}

enum ArcStatus: String, CaseIterable, Codable {
    case planned = "Planned"
    case inProgress = "In Progress"
    case completed = "Completed"
    case abandoned = "Abandoned"
}

enum MilestoneStatus: String, CaseIterable, Codable {
    case planned = "Planned"
    case inProgress = "In Progress"
    case completed = "Completed"
    case skipped = "Skipped"
}

enum RelationshipType: String, CaseIterable, Codable {
    case family = "Family"
    case romantic = "Romantic"
    case friendship = "Friendship"
    case professional = "Professional"
    case antagonistic = "Antagonistic"
    case mentor = "Mentor"
    case student = "Student"
    case neutral = "Neutral"
    case other = "Other"
}

enum RelationshipStrength: String, CaseIterable, Codable {
    case weak = "Weak"
    case medium = "Medium"
    case strong = "Strong"
    case veryStrong = "Very Strong"
}

enum NoteType: String, CaseIterable, Codable {
    case general = "General"
    case dialogue = "Dialogue"
    case action = "Action"
    case development = "Development"
    case research = "Research"
    case inspiration = "Inspiration"
}

// MARK: - Character Statistics
struct CharacterStatistics {
    let totalCharacters: Int
    let charactersWithArcs: Int
    let charactersWithDialogue: Int
    let averageDialogueCount: Double
    let mostActiveCharacter: Character?
    let charactersByGender: [Gender: Int]
    let charactersByArcStatus: [ArcStatus: Int]
}

// MARK: - Character Search Filters
struct CharacterSearchFilters {
    var searchText: String = ""
    var gender: Gender?
    var arcStatus: ArcStatus?
    var hasDialogue: Bool?
    var hasArcs: Bool?
    var tags: [String] = []
    var sortBy: CharacterSortOption = .name
    var sortOrder: SortOrder = .forward
}

enum CharacterSortOption: String, CaseIterable {
    case name = "Name"
    case dialogueCount = "Dialogue Count"
    case sceneCount = "Scene Count"
    case firstAppearance = "First Appearance"
    case lastAppearance = "Last Appearance"
    case createdAt = "Created Date"
    case updatedAt = "Updated Date"
} 