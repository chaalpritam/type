import Foundation
import SwiftUI

// MARK: - Document Outline Model
struct DocumentOutline: Identifiable, Codable, Hashable {
    let id = UUID()
    var title: String
    var description: String
    var rootNodes: [OutlineNode]
    var outlineType: OutlineType
    var viewMode: OutlineViewMode
    var sortOrder: OutlineSortOrder
    var showSceneNumbers: Bool
    var showWordCounts: Bool
    var showStatus: Bool
    var collapsedNodes: Set<UUID>
    var selectedNode: UUID?
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, description: String = "") {
        self.title = title
        self.description = description
        self.rootNodes = []
        self.outlineType = .scene
        self.viewMode = .tree
        self.sortOrder = .order
        self.showSceneNumbers = true
        self.showWordCounts = true
        self.showStatus = true
        self.collapsedNodes = []
        self.selectedNode = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Outline Node
struct OutlineNode: Identifiable, Codable, Hashable {
    let id = UUID()
    var title: String
    var content: String
    var nodeType: NodeType
    var level: Int
    var order: Int
    var children: [OutlineNode]
    var parentId: UUID?
    var sceneId: UUID?
    var characterId: UUID?
    var metadata: OutlineMetadata
    var isExpanded: Bool
    var isSelected: Bool
    var isVisible: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, nodeType: NodeType, level: Int = 0, order: Int = 0) {
        self.title = title
        self.content = ""
        self.nodeType = nodeType
        self.level = level
        self.order = order
        self.children = []
        self.parentId = nil
        self.sceneId = nil
        self.characterId = nil
        self.metadata = OutlineMetadata()
        self.isExpanded = true
        self.isSelected = false
        self.isVisible = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Outline Metadata
struct OutlineMetadata: Codable, Hashable {
    var wordCount: Int
    var sceneNumber: Int?
    var actNumber: Int?
    var sequenceNumber: Int?
    var status: OutlineStatus
    var priority: OutlinePriority
    var tags: [String]
    var notes: String
    var color: SceneColor
    var isCompleted: Bool
    var isImportant: Bool
    var estimatedDuration: TimeInterval?
    var actualDuration: TimeInterval?
    var characters: [String]
    var locations: [String]
    var props: [String]
    var soundEffects: [String]
    var visualEffects: [String]
    
    init() {
        self.wordCount = 0
        self.sceneNumber = nil
        self.actNumber = nil
        self.sequenceNumber = nil
        self.status = .draft
        self.priority = .medium
        self.tags = []
        self.notes = ""
        self.color = .blue
        self.isCompleted = false
        self.isImportant = false
        self.estimatedDuration = nil
        self.actualDuration = nil
        self.characters = []
        self.locations = []
        self.props = []
        self.soundEffects = []
        self.visualEffects = []
    }
}

// MARK: - Outline Section
struct OutlineSection: Identifiable, Codable, Hashable {
    let id = UUID()
    var title: String
    var description: String
    var nodes: [OutlineNode]
    var sectionType: SectionType
    var order: Int
    var isCollapsed: Bool
    var color: SceneColor
    var createdAt: Date
    
    init(title: String, sectionType: SectionType, order: Int = 0) {
        self.title = title
        self.description = ""
        self.nodes = []
        self.sectionType = sectionType
        self.order = order
        self.isCollapsed = false
        self.color = .blue
        self.createdAt = Date()
    }
}

// MARK: - Outline Template
struct OutlineTemplate: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var description: String
    var templateType: OutlineTemplateType
    var structure: [OutlineNode]
    var isDefault: Bool
    var createdAt: Date
    
    init(name: String, templateType: OutlineTemplateType) {
        self.name = name
        self.description = ""
        self.templateType = templateType
        self.structure = []
        self.isDefault = false
        self.createdAt = Date()
    }
}

// MARK: - Enums
enum OutlineType: String, CaseIterable, Codable {
    case scene = "Scene"
    case character = "Character"
    case plot = "Plot"
    case theme = "Theme"
    case mixed = "Mixed"
}

enum OutlineViewMode: String, CaseIterable, Codable {
    case tree = "Tree"
    case list = "List"
    case cards = "Cards"
    case mindmap = "Mind Map"
    case flowchart = "Flow Chart"
}

enum OutlineSortOrder: String, CaseIterable, Codable {
    case order = "Order"
    case alphabetical = "Alphabetical"
    case wordCount = "Word Count"
    case status = "Status"
    case priority = "Priority"
    case createdAt = "Created Date"
    case updatedAt = "Updated Date"
}

enum NodeType: String, CaseIterable, Codable {
    case title = "Title"
    case act = "Act"
    case sequence = "Sequence"
    case scene = "Scene"
    case beat = "Beat"
    case character = "Character"
    case location = "Location"
    case theme = "Theme"
    case subplot = "Subplot"
    case note = "Note"
    case section = "Section"
    case chapter = "Chapter"
    case part = "Part"
    case episode = "Episode"
    case custom = "Custom"
}

enum OutlineStatus: String, CaseIterable, Codable {
    case draft = "Draft"
    case outline = "Outline"
    case inProgress = "In Progress"
    case completed = "Completed"
    case revised = "Revised"
    case final = "Final"
    case archived = "Archived"
}

enum OutlinePriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

enum SectionType: String, CaseIterable, Codable {
    case acts = "Acts"
    case sequences = "Sequences"
    case scenes = "Scenes"
    case characters = "Characters"
    case locations = "Locations"
    case themes = "Themes"
    case subplots = "Subplots"
    case notes = "Notes"
    case research = "Research"
    case ideas = "Ideas"
}

enum OutlineTemplateType: String, CaseIterable, Codable {
    case threeAct = "Three Act"
    case fiveAct = "Five Act"
    case heroJourney = "Hero's Journey"
    case saveTheCat = "Save the Cat"
    case timeBased = "Time Based"
    case custom = "Custom"
    case `import` = "Import"
}

// MARK: - Outline Statistics
struct OutlineStatistics {
    let totalNodes: Int
    let totalSections: Int
    let totalWords: Int
    let averageWordsPerNode: Double
    let completedNodes: Int
    let nodesByType: [NodeType: Int]
    let nodesByStatus: [OutlineStatus: Int]
    let nodesByPriority: [OutlinePriority: Int]
    let depthDistribution: [Int: Int]
    let outlineHealth: OutlineHealth
}

struct OutlineHealth {
    let overallHealth: Double // 0.0 to 1.0
    let issues: [OutlineIssue]
    let recommendations: [String]
    let strengths: [String]
}

enum OutlineIssue: String, CaseIterable, Codable {
    case emptyNodes = "Empty Nodes"
    case unbalancedStructure = "Unbalanced Structure"
    case missingContent = "Missing Content"
    case inconsistentLevels = "Inconsistent Levels"
    case orphanedNodes = "Orphaned Nodes"
    case circularReferences = "Circular References"
    case incompleteHierarchy = "Incomplete Hierarchy"
}

// MARK: - Outline Search Filters
struct OutlineSearchFilters {
    var searchText: String = ""
    var nodeType: NodeType?
    var status: OutlineStatus?
    var priority: OutlinePriority?
    var level: Int?
    var tags: [String] = []
    var isCompleted: Bool?
    var isImportant: Bool?
    var sortBy: OutlineSortOrder = .order
    var sortOrder: SortOrder = .forward
    var showCompleted: Bool = true
    var showDrafts: Bool = true
    var showArchived: Bool = false
}

// MARK: - Outline Export Options
struct OutlineExportOptions {
    var includeContent: Bool = true
    var includeMetadata: Bool = true
    var includeChildren: Bool = true
    var maxDepth: Int = -1 // -1 for unlimited
    var format: ExportFormat = .json
    var includeStatistics: Bool = true
    var includeTemplates: Bool = false
}

// MARK: - Outline Navigation
struct OutlineNavigation: Identifiable, Codable, Hashable {
    let id = UUID()
    var currentNode: UUID?
    var breadcrumb: [UUID]
    var expandedNodes: Set<UUID>
    var recentNodes: [UUID]
    var bookmarks: [OutlineBookmark]
    var searchHistory: [String]
    
    init() {
        self.currentNode = nil
        self.breadcrumb = []
        self.expandedNodes = []
        self.recentNodes = []
        self.bookmarks = []
        self.searchHistory = []
    }
}

struct OutlineBookmark: Identifiable, Codable, Hashable {
    let id = UUID()
    var nodeId: UUID
    var name: String
    var description: String
    var color: SceneColor
    var createdAt: Date
    
    init(nodeId: UUID, name: String, description: String = "") {
        self.nodeId = nodeId
        self.name = name
        self.description = description
        self.color = .yellow
        self.createdAt = Date()
    }
}

// MARK: - Outline Configuration
// OutlineConfiguration is defined in OutlineDatabase.swift

// MARK: - Outline Context Menu Actions
enum OutlineContextAction: String, CaseIterable {
    case addChild = "Add Child"
    case addSibling = "Add Sibling"
    case addAbove = "Add Above"
    case addBelow = "Add Below"
    case edit = "Edit"
    case duplicate = "Duplicate"
    case moveUp = "Move Up"
    case moveDown = "Move Down"
    case promote = "Promote"
    case demote = "Demote"
    case delete = "Delete"
    case bookmark = "Bookmark"
    case copy = "Copy"
    case paste = "Paste"
    case cut = "Cut"
    case selectAll = "Select All"
    case expandAll = "Expand All"
    case collapseAll = "Collapse All"
    case export = "Export"
    case `import` = "Import"
}

// MARK: - Outline Drag and Drop
struct OutlineDragItem: Identifiable, Codable, Hashable {
    let id = UUID()
    var nodeId: UUID
    var nodeType: NodeType
    var title: String
    var sourceIndex: Int
    var sourceParentId: UUID?
}

enum OutlineDropTarget: String, CaseIterable {
    case before = "Before"
    case after = "After"
    case inside = "Inside"
    case replace = "Replace"
}

// MARK: - Outline Keyboard Shortcuts
struct OutlineKeyboardShortcuts {
    static let addChild = "⌘N"
    static let addSibling = "⌘⇧N"
    static let delete = "⌫"
    static let duplicate = "⌘D"
    static let moveUp = "⌘↑"
    static let moveDown = "⌘↓"
    static let promote = "⌘←"
    static let demote = "⌘→"
    static let expand = "→"
    static let collapse = "←"
    static let expandAll = "⌘→"
    static let collapseAll = "⌘←"
    static let selectAll = "⌘A"
    static let copy = "⌘C"
    static let paste = "⌘V"
    static let cut = "⌘X"
    static let undo = "⌘Z"
    static let redo = "⌘⇧Z"
    static let find = "⌘F"
    static let findNext = "⌘G"
    static let findPrevious = "⌘⇧G"
} 