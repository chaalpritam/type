//
//  EnhancedStatisticsView.swift
//  type
//
//  Enhanced statistics dashboard for user engagement and retention
//

import SwiftUI

// MARK: - Enhanced Statistics View
struct EnhancedStatisticsView: View {
    @ObservedObject var statisticsService: StatisticsService
    var characterDB: CharacterDatabase?
    var sceneDB: SceneDatabase?

    @State private var selectedTab: StatisticsTab = .overview

    var body: some View {
        VStack(spacing: 0) {
            // Tab Selector
            Picker("Statistics View", selection: $selectedTab) {
                ForEach(StatisticsTab.allCases) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // Content
            ScrollView {
                VStack(spacing: 16) {
                    switch selectedTab {
                    case .overview:
                        OverviewTab(statisticsService: statisticsService, characterDB: characterDB, sceneDB: sceneDB)
                    case .sessions:
                        SessionsTab(statisticsService: statisticsService)
                    case .goals:
                        GoalsTab(statisticsService: statisticsService)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Statistics Tab
enum StatisticsTab: String, CaseIterable, Identifiable {
    case overview
    case sessions
    case goals

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .sessions: return "Sessions"
        case .goals: return "Goals"
        }
    }
}

// MARK: - Overview Tab
struct OverviewTab: View {
    @ObservedObject var statisticsService: StatisticsService
    var characterDB: CharacterDatabase?
    var sceneDB: SceneDatabase?

    var body: some View {
        VStack(spacing: 16) {
            // Streak Card
            StreakCard(currentStreak: statisticsService.currentStreak,
                      longestStreak: statisticsService.longestStreak,
                      encouragement: statisticsService.getStreakEncouragement())

            // Quick Stats Grid
            QuickStatsGrid(statisticsService: statisticsService, characterDB: characterDB, sceneDB: sceneDB)

            // Weekly Activity Chart
            WeeklyActivityChart(weeklyWordCount: statisticsService.weeklyWordCount)

            // Productivity Insight
            ProductivityInsightCard(insight: statisticsService.getProductivityInsight())

            // Current Session (if active)
            if statisticsService.currentSessionStartTime != nil {
                CurrentSessionCard(statisticsService: statisticsService)
            }
        }
    }
}

// MARK: - Streak Card
struct StreakCard: View {
    let currentStreak: Int
    let longestStreak: Int
    let encouragement: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(currentStreak > 0 ? .orange : .gray)
                    .font(.title2)
                Text("Writing Streak")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 24) {
                VStack(alignment: .leading) {
                    Text("\(currentStreak)")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundColor(currentStreak > 0 ? .orange : .gray)
                    Text("Current")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading) {
                    Text("\(longestStreak)")
                        .font(.system(.title, design: .rounded, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text("Best")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Text(encouragement)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

// MARK: - Quick Stats Grid
struct QuickStatsGrid: View {
    @ObservedObject var statisticsService: StatisticsService
    var characterDB: CharacterDatabase?
    var sceneDB: SceneDatabase?

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "Words", value: "\(statisticsService.wordCount)", icon: "doc.text.fill", color: .blue)
            StatCard(title: "Pages", value: "\(statisticsService.pageCount)", icon: "doc.fill", color: .green)
            StatCard(title: "Today", value: "\(statisticsService.currentDailyWords)", icon: "calendar", color: .purple)
            StatCard(title: "Sessions", value: "\(statisticsService.totalWritingSessions)", icon: "clock.fill", color: .orange)

            if let characterDB = characterDB {
                StatCard(title: "Characters", value: "\(characterDB.statistics.totalCharacters)", icon: "person.2.fill", color: .pink)
            }

            if let sceneDB = sceneDB {
                StatCard(title: "Scenes", value: "\(sceneDB.statistics.totalScenes)", icon: "film.fill", color: .red)
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.system(.title2, design: .rounded, weight: .semibold))

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Weekly Activity Chart
struct WeeklyActivityChart: View {
    let weeklyWordCount: [Int]

    private var maxWords: Int {
        weeklyWordCount.max() ?? 1
    }

    private var dayLabels: [String] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).reversed().map { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return "" }
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return formatter.string(from: date)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 7 Days")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<weeklyWordCount.count, id: \.self) { index in
                    VStack(spacing: 4) {
                        // Bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(weeklyWordCount[index] > 0 ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: max(4, CGFloat(weeklyWordCount[index]) / CGFloat(maxWords) * 80))

                        // Day label
                        Text(dayLabels[index])
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 100)

            Text("Total: \(weeklyWordCount.reduce(0, +)) words this week")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

// MARK: - Productivity Insight Card
struct ProductivityInsightCard: View {
    let insight: String

    var body: some View {
        HStack {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
            Text(insight)
                .font(.subheadline)
            Spacer()
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Current Session Card
struct CurrentSessionCard: View {
    @ObservedObject var statisticsService: StatisticsService
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var currentDuration: TimeInterval = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.green)
                Text("Current Session")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 24) {
                VStack(alignment: .leading) {
                    Text(formatDuration(currentDuration))
                        .font(.system(.title2, design: .monospaced, weight: .semibold))
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading) {
                    Text("\(statisticsService.getCurrentSessionWords())")
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                    Text("Words")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .onReceive(timer) { _ in
            currentDuration = statisticsService.getCurrentSessionDuration()
        }
        .onAppear {
            currentDuration = statisticsService.getCurrentSessionDuration()
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// MARK: - Sessions Tab
struct SessionsTab: View {
    @ObservedObject var statisticsService: StatisticsService

    private var recentSessions: [WritingSession] {
        Array(statisticsService.sessionHistory.sorted(by: { $0.date > $1.date }).prefix(20))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Summary Cards
            HStack(spacing: 12) {
                StatCard(title: "Total Time", value: formatTotalTime(), icon: "clock.fill", color: .blue)
                StatCard(title: "Avg Session", value: formatAvgSession(), icon: "chart.bar.fill", color: .green)
            }

            // Sessions List
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Sessions")
                    .font(.headline)

                if recentSessions.isEmpty {
                    Text("No sessions yet. Start writing to track your progress!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(recentSessions) { session in
                        SessionRow(session: session)
                    }
                }
            }
        }
    }

    private func formatTotalTime() -> String {
        let hours = Int(statisticsService.totalWritingTime) / 3600
        if hours > 0 {
            return "\(hours)h"
        } else {
            let minutes = Int(statisticsService.totalWritingTime) / 60
            return "\(minutes)m"
        }
    }

    private func formatAvgSession() -> String {
        let minutes = Int(statisticsService.averageSessionDuration) / 60
        return "\(minutes)m"
    }
}

// MARK: - Session Row
struct SessionRow: View {
    let session: WritingSession

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formatDate(session.date))
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Text("\(session.wordsWritten) words • \(formatDuration(session.duration))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if session.wordsPerMinute > 0 {
                Text("\(Int(session.wordsPerMinute)) wpm")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes > 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Goals Tab
struct GoalsTab: View {
    @ObservedObject var statisticsService: StatisticsService
    @State private var customGoal: String = ""
    @State private var targetWordCount: Int = 90000 // Feature film standard

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Daily Goal
            DailyGoalCard(statisticsService: statisticsService, customGoal: $customGoal)

            // Project Goal
            ProjectGoalCard(statisticsService: statisticsService, targetWordCount: $targetWordCount)

            // Milestones
            MilestonesCard(statisticsService: statisticsService)
        }
    }
}

// MARK: - Daily Goal Card
struct DailyGoalCard: View {
    @ObservedObject var statisticsService: StatisticsService
    @Binding var customGoal: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Goal")
                .font(.headline)

            // Progress Circle
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: statisticsService.writingGoalProgress)
                        .stroke(statisticsService.writingGoalStatus.color, lineWidth: 8)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(Int(statisticsService.writingGoalProgress * 100))%")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                        Text(statisticsService.writingGoalStatus.description)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(statisticsService.currentDailyWords) / \(statisticsService.dailyWordGoal) words")
                        .font(.subheadline)

                    Text("\(statisticsService.dailyWordGoal - statisticsService.currentDailyWords) words to go")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            // Goal Setter
            HStack {
                TextField("Set daily goal", text: $customGoal)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)

                Button("Update") {
                    if let goal = Int(customGoal), goal > 0 {
                        statisticsService.setDailyWordGoal(goal)
                        customGoal = ""
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

// MARK: - Project Goal Card
struct ProjectGoalCard: View {
    @ObservedObject var statisticsService: StatisticsService
    @Binding var targetWordCount: Int

    var progress: Double {
        guard targetWordCount > 0 else { return 0 }
        return min(1.0, Double(statisticsService.wordCount) / Double(targetWordCount))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Project Goal")
                .font(.headline)

            Text("\(statisticsService.wordCount) / \(targetWordCount) words")
                .font(.title3)

            ProgressView(value: progress)
                .tint(.blue)

            Text(statisticsService.getTimeEstimateToComplete(targetWordCount: targetWordCount))
                .font(.caption)
                .foregroundColor(.secondary)

            // Quick presets
            HStack {
                ForEach([30000, 60000, 90000, 120000], id: \.self) { preset in
                    Button("\(preset/1000)k") {
                        targetWordCount = preset
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

// MARK: - Milestones Card
struct MilestonesCard: View {
    @ObservedObject var statisticsService: StatisticsService

    private var milestones: [(title: String, value: Int, achieved: Bool)] {
        let wordCount = statisticsService.wordCount
        return [
            ("First 1,000 words", 1000, wordCount >= 1000),
            ("Short script (10k)", 10000, wordCount >= 10000),
            ("TV episode (30k)", 30000, wordCount >= 30000),
            ("Feature film (90k)", 90000, wordCount >= 90000),
            ("Epic screenplay (120k)", 120000, wordCount >= 120000)
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.headline)

            ForEach(milestones.indices, id: \.self) { index in
                let milestone = milestones[index]
                HStack {
                    Image(systemName: milestone.achieved ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(milestone.achieved ? .green : .gray)

                    Text(milestone.title)
                        .font(.subheadline)
                        .foregroundColor(milestone.achieved ? .primary : .secondary)

                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}
