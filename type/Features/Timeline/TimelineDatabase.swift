import Foundation
import SwiftUI
import AppKit

class TimelineDatabase: ObservableObject {
    @Published var timeline: StoryTimeline
    @Published var configuration = TimelineConfiguration()
    @Published var statistics = TimelineStatistics(
        totalScenes: 0,
        totalActs: 0,
        totalBeats: 0,
        totalMilestones: 0,
        averageActLength: 0,
        storyStructure: StoryStructure(
            actBreakdown: [:],
            beatDistribution: [:],
            structureType: .threeAct,
            balanceScore: 0.0,
            completeness: 0.0
        ),
        pacingAnalysis: PacingAnalysis(
            overallPacing: .steady,
            actPacing: [:],
            sceneDensity: [:],
            tensionCurve: [],
            momentumPoints: []
        ),
        characterArcs: [],
        themeDevelopment: [],
        timelineHealth: TimelineHealth(
            overallHealth: 0.0,
            issues: [],
            recommendations: [],
            strengths: []
        )
    )
    @Published var selectedElement: (any TimelineElement)?
    @Published var showConnections = true
    @Published var showNotes = true
    @Published var zoomLevel: Double = 1.0
    @Published var panOffset: CGPoint = .zero
    
    private let userDefaults = UserDefaults.standard
    private let timelineKey = "TimelineDatabase.timeline"
    private let configurationKey = "TimelineDatabase.configuration"
    
    init() {
        self.timeline = StoryTimeline(title: "Story Timeline")
        loadData()
        updateStatistics()
    }
    
    // MARK: - Timeline Management
    
    func updateTimeline(_ newTimeline: StoryTimeline) {
        timeline = newTimeline
        timeline.updatedAt = Date()
        saveTimeline()
        updateStatistics()
    }
    
    func addScene(_ scene: Scene, at position: TimelinePosition) {
        let timelineScene = TimelineScene(scene: scene, position: position)
        timeline.scenes.append(timelineScene)
        saveTimeline()
        updateStatistics()
    }
    
    func updateScene(_ timelineScene: TimelineScene) {
        if let index = timeline.scenes.firstIndex(where: { $0.id == timelineScene.id }) {
            timeline.scenes[index] = timelineScene
            saveTimeline()
            updateStatistics()
        }
    }
    
    func removeScene(_ timelineScene: TimelineScene) {
        timeline.scenes.removeAll { $0.id == timelineScene.id }
        saveTimeline()
        updateStatistics()
    }
    
    // MARK: - Act Management
    
    func addAct(_ act: StoryAct) {
        timeline.acts.append(act)
        saveTimeline()
        updateStatistics()
    }
    
    func updateAct(_ act: StoryAct) {
        if let index = timeline.acts.firstIndex(where: { $0.id == act.id }) {
            timeline.acts[index] = act
            saveTimeline()
            updateStatistics()
        }
    }
    
    func removeAct(_ act: StoryAct) {
        timeline.acts.removeAll { $0.id == act.id }
        saveTimeline()
        updateStatistics()
    }
    
    // MARK: - Beat Management
    
    func addBeat(_ beat: StoryBeat) {
        timeline.storyBeats.append(beat)
        saveTimeline()
        updateStatistics()
    }
    
    func updateBeat(_ beat: StoryBeat) {
        if let index = timeline.storyBeats.firstIndex(where: { $0.id == beat.id }) {
            timeline.storyBeats[index] = beat
            saveTimeline()
            updateStatistics()
        }
    }
    
    func removeBeat(_ beat: StoryBeat) {
        timeline.storyBeats.removeAll { $0.id == beat.id }
        saveTimeline()
        updateStatistics()
    }
    
    // MARK: - Milestone Management
    
    func addMilestone(_ milestone: StoryMilestone) {
        timeline.milestones.append(milestone)
        saveTimeline()
        updateStatistics()
    }
    
    func updateMilestone(_ milestone: StoryMilestone) {
        if let index = timeline.milestones.firstIndex(where: { $0.id == milestone.id }) {
            timeline.milestones[index] = milestone
            saveTimeline()
            updateStatistics()
        }
    }
    
    func removeMilestone(_ milestone: StoryMilestone) {
        timeline.milestones.removeAll { $0.id == milestone.id }
        saveTimeline()
        updateStatistics()
    }
    
    // MARK: - Connection Management
    
    func addConnection(_ connection: SceneConnection) {
        // Add connection to both scenes
        if let fromIndex = timeline.scenes.firstIndex(where: { $0.scene.sceneNumber == connection.fromScene }) {
            timeline.scenes[fromIndex].connections.append(connection)
        }
        saveTimeline()
        updateStatistics()
    }
    
    func removeConnection(_ connection: SceneConnection) {
        // Remove connection from both scenes
        for i in timeline.scenes.indices {
            timeline.scenes[i].connections.removeAll { $0.id == connection.id }
        }
        saveTimeline()
        updateStatistics()
    }
    
    // MARK: - Visual Notes Management
    
    func addVisualNote(_ note: VisualNote, to scene: TimelineScene) {
        if let index = timeline.scenes.firstIndex(where: { $0.id == scene.id }) {
            timeline.scenes[index].visualNotes.append(note)
            saveTimeline()
        }
    }
    
    func removeVisualNote(_ note: VisualNote, from scene: TimelineScene) {
        if let index = timeline.scenes.firstIndex(where: { $0.id == scene.id }) {
            timeline.scenes[index].visualNotes.removeAll { $0.id == note.id }
            saveTimeline()
        }
    }
    
    // MARK: - Story Structure Analysis
    
    func analyzeStoryStructure() -> StoryStructure {
        let actBreakdown = Dictionary(grouping: timeline.scenes, by: { $0.position.act })
            .mapValues { $0.count }
        
        let beatDistribution = Dictionary(grouping: timeline.storyBeats, by: { $0.beatType })
            .mapValues { $0.count }
        
        let structureType = determineStructureType()
        let balanceScore = calculateBalanceScore()
        let completeness = calculateCompleteness()
        
        return StoryStructure(
            actBreakdown: actBreakdown,
            beatDistribution: beatDistribution,
            structureType: structureType,
            balanceScore: balanceScore,
            completeness: completeness
        )
    }
    
    private func determineStructureType() -> StructureType {
        let actCount = timeline.acts.count
        let beatTypes = Set(timeline.storyBeats.map { $0.beatType })
        
        if actCount == 3 && beatTypes.contains(.incitingIncident) && beatTypes.contains(.climax) {
            return .threeAct
        } else if actCount == 5 {
            return .fiveAct
        } else if beatTypes.contains(.incitingIncident) && beatTypes.contains(.midpoint) && beatTypes.contains(.climax) {
            return .saveTheCat
        } else {
            return .custom
        }
    }
    
    private func calculateBalanceScore() -> Double {
        guard !timeline.acts.isEmpty else { return 0.0 }
        
        let actScenes = timeline.acts.map { act in
            timeline.scenes.filter { $0.position.act == act.actNumber }.count
        }
        
        let totalScenes = actScenes.reduce(0, +)
        let expectedPerAct = Double(totalScenes) / Double(timeline.acts.count)
        
        let variance = actScenes.map { abs(Double($0) - expectedPerAct) }.reduce(0, +)
        let maxVariance = Double(totalScenes) * 0.5
        
        return max(0.0, 1.0 - (variance / maxVariance))
    }
    
    private func calculateCompleteness() -> Double {
        var score = 0.0
        var totalChecks = 0
        
        // Check for essential beats
        let essentialBeats: [BeatType] = [.incitingIncident, .midpoint, .climax]
        for beat in essentialBeats {
            totalChecks += 1
            if timeline.storyBeats.contains(where: { $0.beatType == beat }) {
                score += 1.0
            }
        }
        
        // Check for acts
        totalChecks += 1
        if !timeline.acts.isEmpty {
            score += 1.0
        }
        
        // Check for scenes
        totalChecks += 1
        if !timeline.scenes.isEmpty {
            score += 1.0
        }
        
        return totalChecks > 0 ? score / Double(totalChecks) : 0.0
    }
    
    // MARK: - Pacing Analysis
    
    func analyzePacing() -> PacingAnalysis {
        let overallPacing = determineOverallPacing()
        let actPacing = analyzeActPacing()
        let sceneDensity = calculateSceneDensity()
        let tensionCurve = calculateTensionCurve()
        let momentumPoints = findMomentumPoints()
        
        return PacingAnalysis(
            overallPacing: overallPacing,
            actPacing: actPacing,
            sceneDensity: sceneDensity,
            tensionCurve: tensionCurve,
            momentumPoints: momentumPoints
        )
    }
    
    private func determineOverallPacing() -> PacingType {
        let totalScenes = timeline.scenes.count
        let totalWords = timeline.scenes.reduce(0) { $0 + $1.scene.wordCount }
        let averageWordsPerScene = totalScenes > 0 ? Double(totalWords) / Double(totalScenes) : 0
        
        if averageWordsPerScene < 200 {
            return .fast
        } else if averageWordsPerScene < 400 {
            return .steady
        } else if averageWordsPerScene < 600 {
            return .slow
        } else {
            return .intense
        }
    }
    
    private func analyzeActPacing() -> [Int: PacingType] {
        var actPacing: [Int: PacingType] = [:]
        
        for act in timeline.acts {
            let actScenes = timeline.scenes.filter { $0.position.act == act.actNumber }
            let totalWords = actScenes.reduce(0) { $0 + $1.scene.wordCount }
            let averageWords = actScenes.isEmpty ? 0 : Double(totalWords) / Double(actScenes.count)
            
            if averageWords < 200 {
                actPacing[act.actNumber] = .fast
            } else if averageWords < 400 {
                actPacing[act.actNumber] = .steady
            } else if averageWords < 600 {
                actPacing[act.actNumber] = .slow
            } else {
                actPacing[act.actNumber] = .intense
            }
        }
        
        return actPacing
    }
    
    private func calculateSceneDensity() -> [Int: Double] {
        var density: [Int: Double] = [:]
        
        for scene in timeline.scenes {
            let wordCount = scene.scene.wordCount
            let dialogueCount = scene.scene.dialogueCount
            let actionCount = scene.scene.actionCount
            
            // Calculate density based on content distribution
            let totalElements = dialogueCount + actionCount
            let densityScore = totalElements > 0 ? Double(wordCount) / Double(totalElements) : 0
            density[scene.scene.sceneNumber ?? 0] = densityScore
        }
        
        return density
    }
    
    private func calculateTensionCurve() -> [Double] {
        return timeline.scenes.enumerated().map { index, timelineScene in
            var tension = 0.0
            
            // Base tension from scene importance
            switch timelineScene.importance {
            case .low: tension += 0.2
            case .medium: tension += 0.5
            case .high: tension += 0.8
            case .critical: tension += 1.0
            }
            
            // Tension from story function
            switch timelineScene.storyFunction {
            case .setup: tension += 0.1
            case .development: tension += 0.3
            case .conflict: tension += 0.7
            case .resolution: tension += 0.4
            case .transition: tension += 0.2
            case .climax: tension += 1.0
            case .denouement: tension += 0.3
            }
            
            // Tension from position in story
            let progress = Double(index) / Double(max(1, timeline.scenes.count - 1))
            tension += progress * 0.3
            
            return min(1.0, tension)
        }
    }
    
    private func findMomentumPoints() -> [Int] {
        let tensionCurve = calculateTensionCurve()
        var momentumPoints: [Int] = []
        
        for (index, tension) in tensionCurve.enumerated() {
            if tension > 0.7 {
                momentumPoints.append(index)
            }
        }
        
        return momentumPoints
    }
    
    // MARK: - Character Arc Analysis
    
    func analyzeCharacterArcs() -> [CharacterArcProgress] {
        // This would integrate with the CharacterDatabase
        // For now, return empty array
        return []
    }
    
    // MARK: - Theme Development Analysis
    
    func analyzeThemeDevelopment() -> [ThemeProgress] {
        // This would analyze themes across scenes
        // For now, return empty array
        return []
    }
    
    // MARK: - Timeline Health Analysis
    
    func analyzeTimelineHealth() -> TimelineHealth {
        var issues: [TimelineIssue] = []
        var recommendations: [String] = []
        var strengths: [String] = []
        var healthScore = 1.0
        
        // Check for structure issues
        if timeline.acts.isEmpty {
            issues.append(.structureGap)
            recommendations.append("Add story acts to provide structure")
            healthScore -= 0.3
        } else {
            strengths.append("Story has clear act structure")
        }
        
        // Check for pacing issues
        let pacing = analyzePacing()
        if pacing.overallPacing == .slow && timeline.scenes.count > 20 {
            issues.append(.pacingIssue)
            recommendations.append("Consider tightening pacing in longer scenes")
            healthScore -= 0.2
        }
        
        // Check for missing beats
        let essentialBeats: [BeatType] = [.incitingIncident, .midpoint, .climax]
        for beat in essentialBeats {
            if !timeline.storyBeats.contains(where: { $0.beatType == beat }) {
                issues.append(.beatMissing)
                recommendations.append("Add \(beat.rawValue) beat")
                healthScore -= 0.1
            }
        }
        
        // Check for act balance
        let balanceScore = calculateBalanceScore()
        if balanceScore < 0.7 {
            issues.append(.actImbalance)
            recommendations.append("Balance scene distribution across acts")
            healthScore -= 0.2
        }
        
        return TimelineHealth(
            overallHealth: max(0.0, healthScore),
            issues: issues,
            recommendations: recommendations,
            strengths: strengths
        )
    }
    
    // MARK: - Auto-Generation
    
    func autoGenerateStructure() {
        // Auto-generate three-act structure
        let totalScenes = timeline.scenes.count
        if totalScenes > 0 {
            let act1Scenes = totalScenes / 4
            let act2Scenes = totalScenes / 2
            let act3Scenes = totalScenes - act1Scenes - act2Scenes
            
            // Create acts
            let act1 = StoryAct(name: "Act 1: Setup", actNumber: 1)
            let act2 = StoryAct(name: "Act 2: Confrontation", actNumber: 2)
            let act3 = StoryAct(name: "Act 3: Resolution", actNumber: 3)
            
            timeline.acts = [act1, act2, act3]
            
            // Assign scenes to acts
            for (index, var timelineScene) in timeline.scenes.enumerated() {
                if index < act1Scenes {
                    timelineScene.position.act = 1
                } else if index < act1Scenes + act2Scenes {
                    timelineScene.position.act = 2
                } else {
                    timelineScene.position.act = 3
                }
                // Update the scene in the array
                timeline.scenes[index] = timelineScene
            }
            
            // Auto-generate essential beats
            let incitingIncident = StoryBeat(
                name: "Inciting Incident",
                beatType: .incitingIncident,
                position: TimelinePosition(act: 1, percentage: 0.25)
            )
            
            let midpoint = StoryBeat(
                name: "Midpoint",
                beatType: .midpoint,
                position: TimelinePosition(act: 2, percentage: 0.5)
            )
            
            let climax = StoryBeat(
                name: "Climax",
                beatType: .climax,
                position: TimelinePosition(act: 3, percentage: 0.75)
            )
            
            timeline.storyBeats = [incitingIncident, midpoint, climax]
            
            saveTimeline()
            updateStatistics()
        }
    }
    
    // MARK: - Export/Import
    
    func exportTimeline() -> Data? {
        return try? JSONEncoder().encode(timeline)
    }
    
    func importTimeline(from data: Data) -> Bool {
        guard let decoded = try? JSONDecoder().decode(StoryTimeline.self, from: data) else {
            return false
        }
        timeline = decoded
        saveTimeline()
        updateStatistics()
        return true
    }
    
    func exportAsImage() -> NSImage? {
        // This would render the timeline as an image
        // For now, return nil
        return nil
    }
    
    // MARK: - Statistics Update
    
    private func updateStatistics() {
        let storyStructure = analyzeStoryStructure()
        let pacingAnalysis = analyzePacing()
        let characterArcs = analyzeCharacterArcs()
        let themeDevelopment = analyzeThemeDevelopment()
        let timelineHealth = analyzeTimelineHealth()
        
        let averageActLength = timeline.acts.isEmpty ? 0 : Double(timeline.scenes.count) / Double(timeline.acts.count)
        
        statistics = TimelineStatistics(
            totalScenes: timeline.scenes.count,
            totalActs: timeline.acts.count,
            totalBeats: timeline.storyBeats.count,
            totalMilestones: timeline.milestones.count,
            averageActLength: averageActLength,
            storyStructure: storyStructure,
            pacingAnalysis: pacingAnalysis,
            characterArcs: characterArcs,
            themeDevelopment: themeDevelopment,
            timelineHealth: timelineHealth
        )
    }
    
    // MARK: - Persistence
    
    private func saveTimeline() {
        if let encoded = try? JSONEncoder().encode(timeline) {
            userDefaults.set(encoded, forKey: timelineKey)
        }
    }
    
    private func saveConfiguration() {
        if let encoded = try? JSONEncoder().encode(configuration) {
            userDefaults.set(encoded, forKey: configurationKey)
        }
    }
    
    private func loadData() {
        // Load timeline
        if let data = userDefaults.data(forKey: timelineKey),
           let decoded = try? JSONDecoder().decode(StoryTimeline.self, from: data) {
            timeline = decoded
        }
        
        // Load configuration
        if let data = userDefaults.data(forKey: configurationKey),
           let decoded = try? JSONDecoder().decode(TimelineConfiguration.self, from: data) {
            configuration = decoded
        }
    }
}

// MARK: - Timeline Element Protocol
protocol TimelineElement: Identifiable {
    var id: UUID { get }
    var position: TimelinePosition { get }
}

extension TimelineScene: TimelineElement {}
extension StoryBeat: TimelineElement {}
extension StoryMilestone: TimelineElement {} 