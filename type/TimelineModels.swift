import Foundation
import SwiftUI

// MARK: - Timeline Model
struct StoryTimeline: Identifiable, Codable, Hashable {
    let id = UUID()
    var title: String
    var description: String
    var scenes: [TimelineScene]
    var acts: [StoryAct]
    var storyBeats: [StoryBeat]
    var milestones: [StoryMilestone]
    var timelineType: TimelineType
    var viewMode: TimelineViewMode
    var colorScheme: TimelineColorScheme
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, description: String = "") {
        self.title = title
        self.description = description
        self.scenes = []
        self.acts = []
        self.storyBeats = []
        self.milestones = []
        self.timelineType = .linear
        self.viewMode = .timeline
        self.colorScheme = .default
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Timeline Scene
struct TimelineScene: Identifiable, Codable, Hashable {
    let id = UUID()
    var scene: Scene
    var position: TimelinePosition
    var duration: SceneDuration
    var importance: SceneImportance
    var storyFunction: StoryFunction
    var connections: [SceneConnection]
    var visualNotes: [VisualNote]
    var isHighlighted: Bool
    var customColor: SceneColor?
    
    init(scene: Scene, position: TimelinePosition) {
        self.scene = scene
        self.position = position
        self.duration = .medium
        self.importance = .medium
        self.storyFunction = .development
        self.connections = []
        self.visualNotes = []
        self.isHighlighted = false
        self.customColor = nil
    }
}

// MARK: - Story Act
struct StoryAct: Identifiable, Codable, Hashable {
    let id = UUID()
    var name: String
    var description: String
    var actNumber: Int
    var startScene: Int
    var endScene: Int
    var scenes: [Int]
    var storyFunction: ActFunction
    var duration: ActDuration
    var color: SceneColor
    var isCompleted: Bool
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, actNumber: Int, description: String = "") {
        self.name = name
        self.actNumber = actNumber
        self.description = description
        self.startScene = 0
        self.endScene = 0
        self.scenes = []
        self.storyFunction = .setup
        self.duration = .standard
        self.color = .blue
        self.isCompleted = false
        self.notes = ""
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Story Beat
struct StoryBeat: Identifiable, Codable, Hashable {
    let id = UUID()
    var name: String
    var description: String
    var beatType: BeatType
    var position: TimelinePosition
    var scenes: [Int]
    var characters: [String]
    var importance: BeatImportance
    var isCompleted: Bool
    var notes: String
    var createdAt: Date
    
    init(name: String, beatType: BeatType, position: TimelinePosition) {
        self.name = name
        self.beatType = beatType
        self.position = position
        self.description = ""
        self.scenes = []
        self.characters = []
        self.importance = .medium
        self.isCompleted = false
        self.notes = ""
        self.createdAt = Date()
    }
}

// MARK: - Story Milestone
struct StoryMilestone: Identifiable, Codable, Hashable {
    let id = UUID()
    var name: String
    var description: String
    var milestoneType: MilestoneType
    var position: TimelinePosition
    var sceneIndex: Int?
    var characters: [String]
    var isCompleted: Bool
    var completionDate: Date?
    var notes: String
    var createdAt: Date
    
    init(name: String, milestoneType: MilestoneType, position: TimelinePosition) {
        self.name = name
        self.milestoneType = milestoneType
        self.position = position
        self.description = ""
        self.sceneIndex = nil
        self.characters = []
        self.isCompleted = false
        self.completionDate = nil
        self.notes = ""
        self.createdAt = Date()
    }
}

// MARK: - Timeline Position
struct TimelinePosition: Codable, Hashable {
    var act: Int
    var sequence: Int
    var scene: Int
    var percentage: Double // 0.0 to 1.0
    
    init(act: Int = 1, sequence: Int = 1, scene: Int = 1, percentage: Double = 0.0) {
        self.act = act
        self.sequence = sequence
        self.scene = scene
        self.percentage = percentage
    }
}

// MARK: - Scene Connection
struct SceneConnection: Identifiable, Codable, Hashable {
    let id = UUID()
    var fromScene: Int
    var toScene: Int
    var connectionType: ConnectionType
    var description: String
    var strength: ConnectionStrength
    
    init(fromScene: Int, toScene: Int, connectionType: ConnectionType) {
        self.fromScene = fromScene
        self.toScene = toScene
        self.connectionType = connectionType
        self.description = ""
        self.strength = .medium
    }
}

// MARK: - Visual Note
struct VisualNote: Identifiable, Codable, Hashable {
    let id = UUID()
    var text: String
    var noteType: VisualNoteType
    var position: CGPoint
    var color: SceneColor
    var isVisible: Bool
    
    init(text: String, noteType: VisualNoteType, position: CGPoint) {
        self.text = text
        self.noteType = noteType
        self.position = position
        self.color = .yellow
        self.isVisible = true
    }
}

// MARK: - Enums
enum TimelineType: String, CaseIterable, Codable {
    case linear = "Linear"
    case circular = "Circular"
    case spiral = "Spiral"
    case tree = "Tree"
    case network = "Network"
}

enum TimelineViewMode: String, CaseIterable, Codable {
    case timeline = "Timeline"
    case acts = "Acts"
    case beats = "Beats"
    case structure = "Structure"
    case flow = "Flow"
}

enum TimelineColorScheme: String, CaseIterable, Codable {
    case `default` = "Default"
    case monochrome = "Monochrome"
    case rainbow = "Rainbow"
    case temperature = "Temperature"
    case mood = "Mood"
    case custom = "Custom"
}

enum SceneImportance: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

enum StoryFunction: String, CaseIterable, Codable {
    case setup = "Setup"
    case development = "Development"
    case conflict = "Conflict"
    case resolution = "Resolution"
    case transition = "Transition"
    case climax = "Climax"
    case denouement = "Denouement"
}

enum ActFunction: String, CaseIterable, Codable {
    case setup = "Setup"
    case confrontation = "Confrontation"
    case resolution = "Resolution"
    case development = "Development"
    case climax = "Climax"
    case denouement = "Denouement"
}

enum ActDuration: String, CaseIterable, Codable {
    case short = "Short"
    case standard = "Standard"
    case long = "Long"
    case extended = "Extended"
}

enum BeatType: String, CaseIterable, Codable {
    case incitingIncident = "Inciting Incident"
    case plotPoint1 = "Plot Point 1"
    case pinchPoint1 = "Pinch Point 1"
    case midpoint = "Midpoint"
    case pinchPoint2 = "Pinch Point 2"
    case plotPoint2 = "Plot Point 2"
    case climax = "Climax"
    case resolution = "Resolution"
    case characterBeat = "Character Beat"
    case thematicBeat = "Thematic Beat"
    case subplotBeat = "Subplot Beat"
    case custom = "Custom"
}

enum BeatImportance: String, CaseIterable, Codable {
    case minor = "Minor"
    case medium = "Medium"
    case major = "Major"
    case critical = "Critical"
}

enum MilestoneType: String, CaseIterable, Codable {
    case storyMilestone = "Story Milestone"
    case characterMilestone = "Character Milestone"
    case plotMilestone = "Plot Milestone"
    case thematicMilestone = "Thematic Milestone"
    case technicalMilestone = "Technical Milestone"
    case custom = "Custom"
}

enum ConnectionType: String, CaseIterable, Codable {
    case plot = "Plot"
    case character = "Character"
    case thematic = "Thematic"
    case visual = "Visual"
    case audio = "Audio"
    case emotional = "Emotional"
    case causal = "Causal"
    case parallel = "Parallel"
    case contrast = "Contrast"
}

enum ConnectionStrength: String, CaseIterable, Codable {
    case weak = "Weak"
    case medium = "Medium"
    case strong = "Strong"
    case critical = "Critical"
}

enum VisualNoteType: String, CaseIterable, Codable {
    case note = "Note"
    case warning = "Warning"
    case idea = "Idea"
    case reminder = "Reminder"
    case question = "Question"
    case highlight = "Highlight"
}

// MARK: - Timeline Statistics
struct TimelineStatistics {
    let totalScenes: Int
    let totalActs: Int
    let totalBeats: Int
    let totalMilestones: Int
    let averageActLength: Double
    let storyStructure: StoryStructure
    let pacingAnalysis: PacingAnalysis
    let characterArcs: [CharacterArcProgress]
    let themeDevelopment: [ThemeProgress]
    let timelineHealth: TimelineHealth
}

struct StoryStructure {
    let actBreakdown: [Int: Int] // Act number -> scene count
    let beatDistribution: [BeatType: Int]
    let structureType: StructureType
    let balanceScore: Double // 0.0 to 1.0
    let completeness: Double // 0.0 to 1.0
}

struct PacingAnalysis {
    let overallPacing: PacingType
    let actPacing: [Int: PacingType]
    let sceneDensity: [Int: Double]
    let tensionCurve: [Double] // Array of tension values
    let momentumPoints: [Int] // Scene indices with high momentum
}

struct CharacterArcProgress {
    let characterName: String
    let arcType: ArcType
    let progress: Double // 0.0 to 1.0
    let keyScenes: [Int]
    let milestones: [String]
    let isComplete: Bool
}

struct ThemeProgress {
    let themeName: String
    let development: Double // 0.0 to 1.0
    let keyScenes: [Int]
    let strength: ThemeStrength
    let resolution: Bool
}

struct TimelineHealth {
    let overallHealth: Double // 0.0 to 1.0
    let issues: [TimelineIssue]
    let recommendations: [String]
    let strengths: [String]
}

// MARK: - Supporting Enums
enum StructureType: String, CaseIterable, Codable {
    case threeAct = "Three Act"
    case fiveAct = "Five Act"
    case heroJourney = "Hero's Journey"
    case saveTheCat = "Save the Cat"
    case custom = "Custom"
}

enum PacingType: String, CaseIterable, Codable {
    case slow = "Slow"
    case steady = "Steady"
    case fast = "Fast"
    case variable = "Variable"
    case intense = "Intense"
}

enum ThemeStrength: String, CaseIterable, Codable {
    case weak = "Weak"
    case developing = "Developing"
    case strong = "Strong"
    case dominant = "Dominant"
}

enum TimelineIssue: String, CaseIterable, Codable {
    case pacingIssue = "Pacing Issue"
    case structureGap = "Structure Gap"
    case characterArcIncomplete = "Character Arc Incomplete"
    case themeUnderdeveloped = "Theme Underdeveloped"
    case actImbalance = "Act Imbalance"
    case beatMissing = "Beat Missing"
    case connectionWeak = "Connection Weak"
}

// MARK: - Timeline Configuration
struct TimelineConfiguration {
    var showSceneNumbers: Bool = true
    var showSceneTitles: Bool = true
    var showActBreaks: Bool = true
    var showBeatMarkers: Bool = true
    var showConnections: Bool = true
    var showNotes: Bool = true
    var showProgress: Bool = true
    var autoLayout: Bool = true
    var snapToGrid: Bool = true
    var gridSize: CGFloat = 20.0
    var zoomLevel: Double = 1.0
    var panOffset: CGPoint = .zero
}

// MARK: - Timeline Export Options
struct TimelineExportOptions {
    var includeScenes: Bool = true
    var includeActs: Bool = true
    var includeBeats: Bool = true
    var includeMilestones: Bool = true
    var includeConnections: Bool = true
    var includeNotes: Bool = true
    var includeStatistics: Bool = true
    var format: ExportFormat = .json
    var imageFormat: ImageFormat = .png
    var resolution: CGSize = CGSize(width: 1920, height: 1080)
}

enum ExportFormat: String, CaseIterable, Codable {
    case json = "JSON"
    case xml = "XML"
    case csv = "CSV"
    case pdf = "PDF"
}

enum ImageFormat: String, CaseIterable, Codable {
    case png = "PNG"
    case jpg = "JPG"
    case svg = "SVG"
    case pdf = "PDF"
} 