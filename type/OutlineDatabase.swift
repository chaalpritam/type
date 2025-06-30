import Foundation
import SwiftUI

class OutlineDatabase: ObservableObject {
    @Published var outline: DocumentOutline
    @Published var configuration = OutlineConfiguration()
    @Published var navigation = OutlineNavigation()
    @Published var searchFilters = OutlineSearchFilters()
    @Published var statistics = OutlineStatistics(
        totalNodes: 0,
        totalSections: 0,
        totalWords: 0,
        averageWordsPerNode: 0,
        completedNodes: 0,
        nodesByType: [:],
        nodesByStatus: [:],
        nodesByPriority: [:],
        depthDistribution: [:],
        outlineHealth: OutlineHealth(
            overallHealth: 0.0,
            issues: [],
            recommendations: [],
            strengths: []
        )
    )
    @Published var selectedNodes: Set<UUID> = []
    @Published var templates: [OutlineTemplate] = []
    @Published var sections: [OutlineSection] = []
    
    private let userDefaults = UserDefaults.standard
    private let outlineKey = "OutlineDatabase.outline"
    private let configurationKey = "OutlineDatabase.configuration"
    private let navigationKey = "OutlineDatabase.navigation"
    private let templatesKey = "OutlineDatabase.templates"
    private let sectionsKey = "OutlineDatabase.sections"
    
    init() {
        self.outline = DocumentOutline(title: "Document Outline")
        loadData()
        updateStatistics()
        setupDefaultTemplates()
    }
    
    // MARK: - Outline Management
    
    func updateOutline(_ newOutline: DocumentOutline) {
        outline = newOutline
        outline.updatedAt = Date()
        saveOutline()
        updateStatistics()
    }
    
    func addNode(_ node: OutlineNode, to parentId: UUID? = nil) {
        if let parentId = parentId {
            addNodeToParent(node, parentId: parentId)
        } else {
            outline.rootNodes.append(node)
        }
        saveOutline()
        updateStatistics()
    }
    
    func updateNode(_ node: OutlineNode) {
        updateNodeInTree(node, in: &outline.rootNodes)
        saveOutline()
        updateStatistics()
    }
    
    func removeNode(_ nodeId: UUID) {
        removeNodeFromTree(nodeId, in: &outline.rootNodes)
        selectedNodes.remove(nodeId)
        saveOutline()
        updateStatistics()
    }
    
    func moveNode(_ nodeId: UUID, to targetId: UUID, position: OutlineDropTarget) {
        guard let node = findNode(nodeId, in: outline.rootNodes) else { return }
        guard let targetNode = findNode(targetId, in: outline.rootNodes) else { return }
        
        // Remove from current position
        removeNodeFromTree(nodeId, in: &outline.rootNodes)
        
        // Add to new position
        switch position {
        case .before:
            insertNodeBefore(node, targetId: targetId, in: &outline.rootNodes)
        case .after:
            insertNodeAfter(node, targetId: targetId, in: &outline.rootNodes)
        case .inside:
            addNodeToParent(node, parentId: targetId)
        case .replace:
            replaceNode(targetId, with: node, in: &outline.rootNodes)
        }
        
        saveOutline()
        updateStatistics()
    }
    
    // MARK: - Node Tree Operations
    
    private func addNodeToParent(_ node: OutlineNode, parentId: UUID) {
        addNodeToParentRecursive(node, parentId: parentId, in: &outline.rootNodes)
    }
    
    private func addNodeToParentRecursive(_ node: OutlineNode, parentId: UUID, in nodes: inout [OutlineNode]) {
        for i in nodes.indices {
            if nodes[i].id == parentId {
                var updatedNode = node
                updatedNode.parentId = parentId
                updatedNode.level = nodes[i].level + 1
                nodes[i].children.append(updatedNode)
                return
            }
            addNodeToParentRecursive(node, parentId: parentId, in: &nodes[i].children)
        }
    }
    
    private func updateNodeInTree(_ node: OutlineNode, in nodes: inout [OutlineNode]) {
        for i in nodes.indices {
            if nodes[i].id == node.id {
                nodes[i] = node
                return
            }
            updateNodeInTree(node, in: &nodes[i].children)
        }
    }
    
    private func removeNodeFromTree(_ nodeId: UUID, in nodes: inout [OutlineNode]) {
        nodes.removeAll { $0.id == nodeId }
        for i in nodes.indices {
            removeNodeFromTree(nodeId, in: &nodes[i].children)
        }
    }
    
    private func findNode(_ nodeId: UUID, in nodes: [OutlineNode]) -> OutlineNode? {
        for node in nodes {
            if node.id == nodeId {
                return node
            }
            if let found = findNode(nodeId, in: node.children) {
                return found
            }
        }
        return nil
    }
    
    private func insertNodeBefore(_ node: OutlineNode, targetId: UUID, in nodes: inout [OutlineNode]) {
        for i in nodes.indices {
            if nodes[i].id == targetId {
                nodes.insert(node, at: i)
                return
            }
            insertNodeBefore(node, targetId: targetId, in: &nodes[i].children)
        }
    }
    
    private func insertNodeAfter(_ node: OutlineNode, targetId: UUID, in nodes: inout [OutlineNode]) {
        for i in nodes.indices {
            if nodes[i].id == targetId {
                nodes.insert(node, at: i + 1)
                return
            }
            insertNodeAfter(node, targetId: targetId, in: &nodes[i].children)
        }
    }
    
    private func replaceNode(_ targetId: UUID, with node: OutlineNode, in nodes: inout [OutlineNode]) {
        for i in nodes.indices {
            if nodes[i].id == targetId {
                nodes[i] = node
                return
            }
            replaceNode(targetId, with: node, in: &nodes[i].children)
        }
    }
    
    // MARK: - Navigation
    
    func selectNode(_ nodeId: UUID) {
        selectedNodes.removeAll()
        selectedNodes.insert(nodeId)
        navigation.currentNode = nodeId
        updateBreadcrumb(for: nodeId)
        addToRecentNodes(nodeId)
        saveNavigation()
    }
    
    func selectMultipleNodes(_ nodeIds: Set<UUID>) {
        selectedNodes = nodeIds
        if let firstNode = nodeIds.first {
            navigation.currentNode = firstNode
            updateBreadcrumb(for: firstNode)
        }
        saveNavigation()
    }
    
    func expandNode(_ nodeId: UUID) {
        navigation.expandedNodes.insert(nodeId)
        saveNavigation()
    }
    
    func collapseNode(_ nodeId: UUID) {
        navigation.expandedNodes.remove(nodeId)
        saveNavigation()
    }
    
    func expandAll() {
        let allNodeIds = getAllNodeIds(outline.rootNodes)
        navigation.expandedNodes = Set(allNodeIds)
        saveNavigation()
    }
    
    func collapseAll() {
        navigation.expandedNodes.removeAll()
        saveNavigation()
    }
    
    private func updateBreadcrumb(for nodeId: UUID) {
        navigation.breadcrumb = getBreadcrumb(for: nodeId, in: outline.rootNodes)
    }
    
    private func getBreadcrumb(for nodeId: UUID, in nodes: [OutlineNode]) -> [UUID] {
        for node in nodes {
            if node.id == nodeId {
                return [node.id]
            }
            let childBreadcrumb = getBreadcrumb(for: nodeId, in: node.children)
            if !childBreadcrumb.isEmpty {
                return [node.id] + childBreadcrumb
            }
        }
        return []
    }
    
    private func getAllNodeIds(_ nodes: [OutlineNode]) -> [UUID] {
        var ids: [UUID] = []
        for node in nodes {
            ids.append(node.id)
            ids.append(contentsOf: getAllNodeIds(node.children))
        }
        return ids
    }
    
    private func addToRecentNodes(_ nodeId: UUID) {
        navigation.recentNodes.removeAll { $0 == nodeId }
        navigation.recentNodes.insert(nodeId, at: 0)
        if navigation.recentNodes.count > 20 {
            navigation.recentNodes = Array(navigation.recentNodes.prefix(20))
        }
    }
    
    // MARK: - Search and Filtering
    
    func searchNodes(_ query: String) -> [OutlineNode] {
        guard !query.isEmpty else { return getAllNodes(outline.rootNodes) }
        
        let filteredNodes = getAllNodes(outline.rootNodes).filter { node in
            node.title.localizedCaseInsensitiveContains(query) ||
            node.content.localizedCaseInsensitiveContains(query) ||
            node.metadata.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
        
        navigation.searchHistory.removeAll { $0 == query }
        navigation.searchHistory.insert(query, at: 0)
        if navigation.searchHistory.count > 20 {
            navigation.searchHistory = Array(navigation.searchHistory.prefix(20))
        }
        saveNavigation()
        
        return filteredNodes
    }
    
    func filteredNodes() -> [OutlineNode] {
        var filtered = getAllNodes(outline.rootNodes)
        
        // Apply search filters
        if !searchFilters.searchText.isEmpty {
            filtered = filtered.filter { node in
                node.title.localizedCaseInsensitiveContains(searchFilters.searchText) ||
                node.content.localizedCaseInsensitiveContains(searchFilters.searchText)
            }
        }
        
        if let nodeType = searchFilters.nodeType {
            filtered = filtered.filter { $0.nodeType == nodeType }
        }
        
        if let status = searchFilters.status {
            filtered = filtered.filter { $0.metadata.status == status }
        }
        
        if let priority = searchFilters.priority {
            filtered = filtered.filter { $0.metadata.priority == priority }
        }
        
        if let level = searchFilters.level {
            filtered = filtered.filter { $0.level == level }
        }
        
        if !searchFilters.tags.isEmpty {
            filtered = filtered.filter { node in
                !Set(node.metadata.tags).isDisjoint(with: Set(searchFilters.tags))
            }
        }
        
        if let isCompleted = searchFilters.isCompleted {
            filtered = filtered.filter { $0.metadata.isCompleted == isCompleted }
        }
        
        if let isImportant = searchFilters.isImportant {
            filtered = filtered.filter { $0.metadata.isImportant == isImportant }
        }
        
        // Apply visibility filters
        if !searchFilters.showCompleted {
            filtered = filtered.filter { !$0.metadata.isCompleted }
        }
        
        if !searchFilters.showDrafts {
            filtered = filtered.filter { $0.metadata.status != .draft }
        }
        
        if !searchFilters.showArchived {
            filtered = filtered.filter { $0.metadata.status != .archived }
        }
        
        // Sort results
        filtered.sort { first, second in
            let comparison: Bool
            switch searchFilters.sortBy {
            case .order:
                comparison = first.order < second.order
            case .alphabetical:
                comparison = first.title < second.title
            case .wordCount:
                comparison = first.metadata.wordCount > second.metadata.wordCount
            case .status:
                comparison = first.metadata.status.rawValue < second.metadata.status.rawValue
            case .priority:
                comparison = first.metadata.priority.rawValue > second.metadata.priority.rawValue
            case .createdAt:
                comparison = first.createdAt < second.createdAt
            case .updatedAt:
                comparison = first.updatedAt < second.updatedAt
            }
            return searchFilters.sortOrder == .ascending ? comparison : !comparison
        }
        
        return filtered
    }
    
    private func getAllNodes(_ nodes: [OutlineNode]) -> [OutlineNode] {
        var allNodes: [OutlineNode] = []
        for node in nodes {
            allNodes.append(node)
            allNodes.append(contentsOf: getAllNodes(node.children))
        }
        return allNodes
    }
    
    // MARK: - Templates
    
    func applyTemplate(_ template: OutlineTemplate) {
        outline.rootNodes = template.structure
        saveOutline()
        updateStatistics()
    }
    
    func saveAsTemplate(_ name: String, templateType: TemplateType) {
        let template = OutlineTemplate(name: name, templateType: templateType)
        template.structure = outline.rootNodes
        templates.append(template)
        saveTemplates()
    }
    
    private func setupDefaultTemplates() {
        if templates.isEmpty {
            let threeActTemplate = OutlineTemplate(name: "Three Act Structure", templateType: .threeAct)
            threeActTemplate.structure = createThreeActStructure()
            templates.append(threeActTemplate)
            
            let heroJourneyTemplate = OutlineTemplate(name: "Hero's Journey", templateType: .heroJourney)
            heroJourneyTemplate.structure = createHeroJourneyStructure()
            templates.append(heroJourneyTemplate)
            
            saveTemplates()
        }
    }
    
    private func createThreeActStructure() -> [OutlineNode] {
        let act1 = OutlineNode(title: "Act 1: Setup", nodeType: .act, level: 0, order: 1)
        let act2 = OutlineNode(title: "Act 2: Confrontation", nodeType: .act, level: 0, order: 2)
        let act3 = OutlineNode(title: "Act 3: Resolution", nodeType: .act, level: 0, order: 3)
        
        return [act1, act2, act3]
    }
    
    private func createHeroJourneyStructure() -> [OutlineNode] {
        let ordinaryWorld = OutlineNode(title: "Ordinary World", nodeType: .scene, level: 0, order: 1)
        let callToAdventure = OutlineNode(title: "Call to Adventure", nodeType: .scene, level: 0, order: 2)
        let refusal = OutlineNode(title: "Refusal of the Call", nodeType: .scene, level: 0, order: 3)
        let meetingMentor = OutlineNode(title: "Meeting the Mentor", nodeType: .scene, level: 0, order: 4)
        let crossingThreshold = OutlineNode(title: "Crossing the Threshold", nodeType: .scene, level: 0, order: 5)
        let tests = OutlineNode(title: "Tests, Allies, Enemies", nodeType: .scene, level: 0, order: 6)
        let approach = OutlineNode(title: "Approach to the Inmost Cave", nodeType: .scene, level: 0, order: 7)
        let ordeal = OutlineNode(title: "The Ordeal", nodeType: .scene, level: 0, order: 8)
        let reward = OutlineNode(title: "The Reward", nodeType: .scene, level: 0, order: 9)
        let roadBack = OutlineNode(title: "The Road Back", nodeType: .scene, level: 0, order: 10)
        let resurrection = OutlineNode(title: "The Resurrection", nodeType: .scene, level: 0, order: 11)
        let returnElixir = OutlineNode(title: "Return with the Elixir", nodeType: .scene, level: 0, order: 12)
        
        return [ordinaryWorld, callToAdventure, refusal, meetingMentor, crossingThreshold, tests, approach, ordeal, reward, roadBack, resurrection, returnElixir]
    }
    
    // MARK: - Statistics
    
    private func updateStatistics() {
        let allNodes = getAllNodes(outline.rootNodes)
        let totalNodes = allNodes.count
        let totalWords = allNodes.reduce(0) { $0 + $1.metadata.wordCount }
        let averageWordsPerNode = totalNodes > 0 ? Double(totalWords) / Double(totalNodes) : 0
        let completedNodes = allNodes.filter { $0.metadata.isCompleted }.count
        
        var nodesByType: [NodeType: Int] = [:]
        for type in NodeType.allCases {
            nodesByType[type] = allNodes.filter { $0.nodeType == type }.count
        }
        
        var nodesByStatus: [OutlineStatus: Int] = [:]
        for status in OutlineStatus.allCases {
            nodesByStatus[status] = allNodes.filter { $0.metadata.status == status }.count
        }
        
        var nodesByPriority: [OutlinePriority: Int] = [:]
        for priority in OutlinePriority.allCases {
            nodesByPriority[priority] = allNodes.filter { $0.metadata.priority == priority }.count
        }
        
        var depthDistribution: [Int: Int] = [:]
        for node in allNodes {
            depthDistribution[node.level, default: 0] += 1
        }
        
        let outlineHealth = analyzeOutlineHealth()
        
        statistics = OutlineStatistics(
            totalNodes: totalNodes,
            totalSections: sections.count,
            totalWords: totalWords,
            averageWordsPerNode: averageWordsPerNode,
            completedNodes: completedNodes,
            nodesByType: nodesByType,
            nodesByStatus: nodesByStatus,
            nodesByPriority: nodesByPriority,
            depthDistribution: depthDistribution,
            outlineHealth: outlineHealth
        )
    }
    
    private func analyzeOutlineHealth() -> OutlineHealth {
        var issues: [OutlineIssue] = []
        var recommendations: [String] = []
        var strengths: [String] = []
        var healthScore = 1.0
        
        let allNodes = getAllNodes(outline.rootNodes)
        
        // Check for empty nodes
        let emptyNodes = allNodes.filter { $0.title.isEmpty && $0.content.isEmpty }
        if !emptyNodes.isEmpty {
            issues.append(.emptyNodes)
            recommendations.append("Fill in empty nodes")
            healthScore -= 0.2
        }
        
        // Check for unbalanced structure
        let maxDepth = allNodes.map { $0.level }.max() ?? 0
        let minDepth = allNodes.map { $0.level }.min() ?? 0
        if maxDepth - minDepth > 5 {
            issues.append(.unbalancedStructure)
            recommendations.append("Balance the hierarchy levels")
            healthScore -= 0.15
        }
        
        // Check for missing content
        let nodesWithContent = allNodes.filter { !$0.content.isEmpty }
        let contentRatio = allNodes.isEmpty ? 0 : Double(nodesWithContent.count) / Double(allNodes.count)
        if contentRatio < 0.5 {
            issues.append(.missingContent)
            recommendations.append("Add content to more nodes")
            healthScore -= 0.25
        }
        
        // Check for inconsistent levels
        let levelCounts = Dictionary(grouping: allNodes, by: { $0.level }).mapValues { $0.count }
        let averageLevelCount = levelCounts.values.reduce(0, +) / max(1, levelCounts.count)
        let inconsistentLevels = levelCounts.values.filter { abs($0 - averageLevelCount) > averageLevelCount * 0.5 }
        if !inconsistentLevels.isEmpty {
            issues.append(.inconsistentLevels)
            recommendations.append("Balance node distribution across levels")
            healthScore -= 0.1
        }
        
        // Identify strengths
        if allNodes.count > 10 {
            strengths.append("Comprehensive outline structure")
        }
        
        if contentRatio > 0.8 {
            strengths.append("Well-developed content")
        }
        
        if maxDepth <= 3 {
            strengths.append("Clear hierarchy")
        }
        
        return OutlineHealth(
            overallHealth: max(0.0, healthScore),
            issues: issues,
            recommendations: recommendations,
            strengths: strengths
        )
    }
    
    // MARK: - Export/Import
    
    func exportOutline() -> Data? {
        return try? JSONEncoder().encode(outline)
    }
    
    func importOutline(from data: Data) -> Bool {
        guard let decoded = try? JSONDecoder().decode(DocumentOutline.self, from: data) else {
            return false
        }
        outline = decoded
        saveOutline()
        updateStatistics()
        return true
    }
    
    // MARK: - Persistence
    
    private func saveOutline() {
        if let encoded = try? JSONEncoder().encode(outline) {
            userDefaults.set(encoded, forKey: outlineKey)
        }
    }
    
    private func saveConfiguration() {
        if let encoded = try? JSONEncoder().encode(configuration) {
            userDefaults.set(encoded, forKey: configurationKey)
        }
    }
    
    private func saveNavigation() {
        if let encoded = try? JSONEncoder().encode(navigation) {
            userDefaults.set(encoded, forKey: navigationKey)
        }
    }
    
    private func saveTemplates() {
        if let encoded = try? JSONEncoder().encode(templates) {
            userDefaults.set(encoded, forKey: templatesKey)
        }
    }
    
    private func saveSections() {
        if let encoded = try? JSONEncoder().encode(sections) {
            userDefaults.set(encoded, forKey: sectionsKey)
        }
    }
    
    private func loadData() {
        // Load outline
        if let data = userDefaults.data(forKey: outlineKey),
           let decoded = try? JSONDecoder().decode(DocumentOutline.self, from: data) {
            outline = decoded
        }
        
        // Load configuration
        if let data = userDefaults.data(forKey: configurationKey),
           let decoded = try? JSONDecoder().decode(OutlineConfiguration.self, from: data) {
            configuration = decoded
        }
        
        // Load navigation
        if let data = userDefaults.data(forKey: navigationKey),
           let decoded = try? JSONDecoder().decode(OutlineNavigation.self, from: data) {
            navigation = decoded
        }
        
        // Load templates
        if let data = userDefaults.data(forKey: templatesKey),
           let decoded = try? JSONDecoder().decode([OutlineTemplate].self, from: data) {
            templates = decoded
        }
        
        // Load sections
        if let data = userDefaults.data(forKey: sectionsKey),
           let decoded = try? JSONDecoder().decode([OutlineSection].self, from: data) {
            sections = decoded
        }
    }
} 