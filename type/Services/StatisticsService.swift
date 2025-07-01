//
//  StatisticsService.swift
//  type
//
//  Statistics and writing goals logic migrated from ContentView.swift
//

import SwiftUI

// MARK: - Statistics Service
class StatisticsService: ObservableObject {
    @Published var wordCount: Int = 0
    @Published var pageCount: Int = 0
    @Published var characterCount: Int = 0
    @Published var currentDailyWords: Int = 0
    @Published var dailyWordGoal: Int = 1000
    @Published var showWritingGoals: Bool = false
    
    // MARK: - Statistics Calculation
    
    func updateStatistics(text: String) {
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        wordCount = words.count
        characterCount = text.count
        pageCount = max(1, wordCount / 250) // Rough estimate: 250 words per page
        
        // Update daily word count for writing goals
        currentDailyWords = wordCount
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