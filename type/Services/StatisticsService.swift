//
//  StatisticsService.swift
//  type
//
//  Statistics and writing goals logic migrated from ContentView.swift
//

import SwiftUI

// MARK: - Writing Session
struct WritingSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let wordsWritten: Int
    let duration: TimeInterval // in seconds
    let startWordCount: Int
    let endWordCount: Int

    init(id: UUID = UUID(), date: Date = Date(), wordsWritten: Int, duration: TimeInterval, startWordCount: Int, endWordCount: Int) {
        self.id = id
        self.date = date
        self.wordsWritten = wordsWritten
        self.duration = duration
        self.startWordCount = startWordCount
        self.endWordCount = endWordCount
    }

    var wordsPerMinute: Double {
        guard duration > 0 else { return 0 }
        return Double(wordsWritten) / (duration / 60.0)
    }
}

// MARK: - Statistics Service
class StatisticsService: ObservableObject {
    // Basic stats
    @Published var wordCount: Int = 0
    @Published var pageCount: Int = 0
    @Published var characterCount: Int = 0

    // Writing goals
    @Published var currentDailyWords: Int = 0
    @Published var dailyWordGoal: Int = 1000
    @Published var showWritingGoals: Bool = false

    // Session tracking
    @Published var currentSessionStartTime: Date?
    @Published var currentSessionStartWordCount: Int = 0
    @Published var sessionHistory: [WritingSession] = []
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0

    // Advanced statistics
    @Published var totalWritingSessions: Int = 0
    @Published var totalWritingTime: TimeInterval = 0
    @Published var averageWordsPerSession: Double = 0
    @Published var averageSessionDuration: TimeInterval = 0
    @Published var todayWritingTime: TimeInterval = 0
    @Published var weeklyWordCount: [Int] = Array(repeating: 0, count: 7) // Last 7 days

    private let userDefaults = UserDefaults.standard
    private let sessionsKey = "StatisticsService.sessions"
    private let streakKey = "StatisticsService.currentStreak"
    private let longestStreakKey = "StatisticsService.longestStreak"
    private let lastWriteDateKey = "StatisticsService.lastWriteDate"

    init() {
        loadSessionHistory()
        updateStreakData()
    }

    // MARK: - Statistics Calculation

    func updateStatistics(text: String) {
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let previousWordCount = wordCount

        wordCount = words.count
        characterCount = text.count
        pageCount = max(1, wordCount / 250) // Rough estimate: 250 words per page

        // Start session if not already started and user is writing
        if currentSessionStartTime == nil && wordCount > previousWordCount {
            startSession()
        }

        // Update streak if writing today
        if wordCount > previousWordCount {
            updateStreakOnWrite()
        }

        // Update daily words (for writing goals)
        updateDailyWordCount()
    }

    // MARK: - Session Management

    func startSession() {
        currentSessionStartTime = Date()
        currentSessionStartWordCount = wordCount
    }

    func endSession() {
        guard let startTime = currentSessionStartTime else { return }

        let duration = Date().timeIntervalSince(startTime)
        let wordsWritten = max(0, wordCount - currentSessionStartWordCount)

        // Only save sessions with meaningful activity (>= 10 words or >= 1 minute)
        if wordsWritten >= 10 || duration >= 60 {
            let session = WritingSession(
                date: startTime,
                wordsWritten: wordsWritten,
                duration: duration,
                startWordCount: currentSessionStartWordCount,
                endWordCount: wordCount
            )

            sessionHistory.append(session)
            saveSessionHistory()
            updateAggregateStats()
        }

        currentSessionStartTime = nil
        currentSessionStartWordCount = 0
    }

    func getCurrentSessionDuration() -> TimeInterval {
        guard let startTime = currentSessionStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }

    func getCurrentSessionWords() -> Int {
        guard currentSessionStartTime != nil else { return 0 }
        return max(0, wordCount - currentSessionStartWordCount)
    }

    // MARK: - Streak Management

    private func updateStreakOnWrite() {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastWriteDate = userDefaults.object(forKey: lastWriteDateKey) as? Date {
            let lastWrite = Calendar.current.startOfDay(for: lastWriteDate)
            let daysDifference = Calendar.current.dateComponents([.day], from: lastWrite, to: today).day ?? 0

            if daysDifference == 0 {
                // Already wrote today, streak continues
                return
            } else if daysDifference == 1 {
                // Wrote yesterday, increment streak
                currentStreak += 1
                userDefaults.set(currentStreak, forKey: streakKey)

                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                    userDefaults.set(longestStreak, forKey: longestStreakKey)
                }
            } else {
                // Streak broken
                currentStreak = 1
                userDefaults.set(currentStreak, forKey: streakKey)
            }
        } else {
            // First time writing
            currentStreak = 1
            userDefaults.set(currentStreak, forKey: streakKey)
        }

        userDefaults.set(today, forKey: lastWriteDateKey)
    }

    private func updateStreakData() {
        currentStreak = userDefaults.integer(forKey: streakKey)
        longestStreak = userDefaults.integer(forKey: longestStreakKey)

        // Check if streak should be reset
        if let lastWriteDate = userDefaults.object(forKey: lastWriteDateKey) as? Date {
            let today = Calendar.current.startOfDay(for: Date())
            let lastWrite = Calendar.current.startOfDay(for: lastWriteDate)
            let daysDifference = Calendar.current.dateComponents([.day], from: lastWrite, to: today).day ?? 0

            if daysDifference > 1 {
                // Streak broken
                currentStreak = 0
                userDefaults.set(0, forKey: streakKey)
            }
        }
    }

    // MARK: - Daily Word Count

    private func updateDailyWordCount() {
        let today = Calendar.current.startOfDay(for: Date())
        let todaySessions = sessionHistory.filter { session in
            Calendar.current.isDate(session.date, inSameDayAs: today)
        }

        currentDailyWords = todaySessions.reduce(0) { $0 + $1.wordsWritten }

        // Update weekly word counts
        updateWeeklyWordCounts()
    }

    private func updateWeeklyWordCounts() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        weeklyWordCount = (0..<7).map { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { return 0 }
            let daySessions = sessionHistory.filter { session in
                calendar.isDate(session.date, inSameDayAs: date)
            }
            return daySessions.reduce(0) { $0 + $1.wordsWritten }
        }.reversed()
    }

    // MARK: - Aggregate Statistics

    private func updateAggregateStats() {
        totalWritingSessions = sessionHistory.count
        totalWritingTime = sessionHistory.reduce(0) { $0 + $1.duration }

        let totalWords = sessionHistory.reduce(0) { $0 + $1.wordsWritten }
        averageWordsPerSession = totalWritingSessions > 0 ? Double(totalWords) / Double(totalWritingSessions) : 0
        averageSessionDuration = totalWritingSessions > 0 ? totalWritingTime / Double(totalWritingSessions) : 0

        // Today's writing time
        let today = Calendar.current.startOfDay(for: Date())
        let todaySessions = sessionHistory.filter { session in
            Calendar.current.isDate(session.date, inSameDayAs: today)
        }
        todayWritingTime = todaySessions.reduce(0) { $0 + $1.duration }

        updateDailyWordCount()
    }

    // MARK: - Character & Scene Statistics Integration

    func getCharacterStatsSummary(from characterDB: CharacterDatabase?) -> String {
        guard let stats = characterDB?.statistics else { return "No data" }
        return "\(stats.totalCharacters) characters, \(stats.charactersWithDialogue) with dialogue"
    }

    func getSceneStatsSummary(from sceneDB: SceneDatabase?) -> String {
        guard let stats = sceneDB?.statistics else { return "No data" }
        return "\(stats.totalScenes) scenes, \(Int(stats.averageSceneLength)) avg words/scene"
    }

    func getDialogueToActionRatio(from sceneDB: SceneDatabase?) -> Double {
        guard let stats = sceneDB?.statistics else { return 0 }
        let totalDialogue = stats.totalDialogueCount
        let totalWords = stats.totalWordCount
        guard totalWords > 0 else { return 0 }
        return Double(totalDialogue) / Double(totalWords)
    }

    // MARK: - Writing Goals

    func setDailyWordGoal(_ goal: Int) {
        dailyWordGoal = goal
    }

    func toggleWritingGoals() {
        showWritingGoals.toggle()
    }

    var writingGoalProgress: Double {
        min(Double(currentDailyWords) / Double(dailyWordGoal), 1.0)
    }

    var writingGoalStatus: WritingGoalStatus {
        if writingGoalProgress >= 1.0 {
            return .completed
        } else if writingGoalProgress >= 0.7 {
            return .onTrack
        } else {
            return .behind
        }
    }

    // MARK: - Helpful Metrics

    func getProductivityInsight() -> String {
        guard totalWritingSessions > 0 else {
            return "Start writing to track your productivity!"
        }

        if averageWordsPerSession > 500 {
            return "Great productivity! You average \(Int(averageWordsPerSession)) words per session."
        } else if averageWordsPerSession > 250 {
            return "Good pace! Average \(Int(averageWordsPerSession)) words per session."
        } else {
            return "Keep going! Every word counts."
        }
    }

    func getStreakEncouragement() -> String {
        if currentStreak == 0 {
            return "Write today to start your streak!"
        } else if currentStreak == 1 {
            return "Day 1 of your streak! Keep it going tomorrow."
        } else if currentStreak < 7 {
            return "\(currentStreak) day streak! You're building momentum."
        } else if currentStreak < 30 {
            return "Amazing! \(currentStreak) day streak!"
        } else {
            return "Incredible! \(currentStreak) day streak! You're a writing machine!"
        }
    }

    func getTimeEstimateToComplete(targetWordCount: Int) -> String {
        guard averageWordsPerSession > 0 else {
            return "Start writing to get estimates"
        }

        let wordsRemaining = max(0, targetWordCount - wordCount)
        let sessionsNeeded = ceil(Double(wordsRemaining) / averageWordsPerSession)

        if sessionsNeeded == 0 {
            return "Target reached!"
        } else if sessionsNeeded == 1 {
            return "About 1 more session to reach \(targetWordCount) words"
        } else {
            return "About \(Int(sessionsNeeded)) more sessions to reach \(targetWordCount) words"
        }
    }

    // MARK: - Persistence

    private func saveSessionHistory() {
        // Keep only last 90 days of sessions to avoid excessive data
        let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        sessionHistory = sessionHistory.filter { $0.date >= ninetyDaysAgo }

        if let encoded = try? JSONEncoder().encode(sessionHistory) {
            userDefaults.set(encoded, forKey: sessionsKey)
        }
    }

    private func loadSessionHistory() {
        if let data = userDefaults.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([WritingSession].self, from: data) {
            sessionHistory = decoded
            updateAggregateStats()
        }
    }
}

// MARK: - Cleanup Extension
extension StatisticsService {
    /// Cleanup method for proper resource release
    func cleanup() {
        Logger.app.debug("StatisticsService cleanup")
        // End current session before cleanup
        endSession()
        // Note: We don't reset historical data (sessions, streaks) on cleanup
        // Only reset current session state
        wordCount = 0
        pageCount = 0
        characterCount = 0
        currentSessionStartTime = nil
        currentSessionStartWordCount = 0
    }
}

// MARK: - Writing Goal Status
enum WritingGoalStatus {
    case behind
    case onTrack
    case completed
    
    var color: Color {
        switch self {
        case .behind:
            return .blue
        case .onTrack:
            return .orange
        case .completed:
            return .green
        }
    }
    
    var description: String {
        switch self {
        case .behind:
            return "Behind Schedule"
        case .onTrack:
            return "On Track"
        case .completed:
            return "Goal Achieved!"
        }
    }
} 