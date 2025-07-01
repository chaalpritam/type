import Foundation
import Data.CharacterModels

class AutoCompletionManager: ObservableObject {
    @Published var suggestions: [String] = []
    @Published var showSuggestions: Bool = false
    @Published var selectedIndex: Int = 0
    
    private var characterNames: Set<String> = []
    private var sceneHeadings: Set<String> = []
    private var transitions: Set<String> = []
    
    // Common screenplay transitions
    private let commonTransitions = [
        "FADE IN", "FADE OUT", "FADE TO BLACK", "CUT TO", "DISSOLVE TO",
        "SMASH CUT TO", "JUMP CUT TO", "MATCH CUT TO", "THE END", "END"
    ]
    
    init() {
        transitions = Set(commonTransitions)
    }
    
    func updateSuggestions(for text: String, at cursorPosition: Int) {
        let lines = text.components(separatedBy: .newlines)
        let currentLine = getCurrentLine(text: text, cursorPosition: cursorPosition)
        
        // Extract screenplay elements from existing text
        extractElements(from: lines)
        
        // Generate suggestions based on context
        suggestions = generateSuggestions(for: currentLine, at: cursorPosition)
        showSuggestions = !suggestions.isEmpty
        selectedIndex = 0
    }
    
    private func getCurrentLine(text: String, cursorPosition: Int) -> String {
        let lines = text.components(separatedBy: .newlines)
        var currentPos = 0
        
        for (index, line) in lines.enumerated() {
            if currentPos + line.count + 1 > cursorPosition {
                return line
            }
            currentPos += line.count + 1 // +1 for newline
        }
        
        return lines.last ?? ""
    }
    
    private func extractElements(from lines: [String]) {
        characterNames.removeAll()
        sceneHeadings.removeAll()
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Extract character names (ALL CAPS)
            if trimmed.range(of: #"^[A-Z][A-Z\s]+$"#, options: .regularExpression) != nil {
                characterNames.insert(trimmed)
            }
            
            // Extract scene headings
            if trimmed.range(of: #"^(?:INT|EXT|INT\/EXT|I\/E)\.?\s+.*$"#, options: .regularExpression) != nil {
                sceneHeadings.insert(trimmed)
            }
        }
    }
    
    private func generateSuggestions(for currentLine: String, at cursorPosition: Int) -> [String] {
        let trimmed = currentLine.trimmingCharacters(in: .whitespaces)
        var suggestions: [String] = []
        
        // If line is empty or starts with common patterns, suggest based on context
        if trimmed.isEmpty || trimmed.hasPrefix("INT") || trimmed.hasPrefix("EXT") {
            // Suggest scene headings
            suggestions.append(contentsOf: sceneHeadings)
            suggestions.append("INT. LOCATION - DAY")
            suggestions.append("EXT. LOCATION - NIGHT")
            suggestions.append("INT./EXT. LOCATION - DAY")
        } else if trimmed.isEmpty || trimmed.range(of: #"^[A-Z]*$"#, options: .regularExpression) != nil {
            // Suggest character names
            suggestions.append(contentsOf: characterNames)
        } else if trimmed.isEmpty || trimmed.hasPrefix("(") {
            // Suggest common parentheticals
            suggestions.append("(without looking up)")
            suggestions.append("(approaching)")
            suggestions.append("(looking up)")
            suggestions.append("(surprised)")
            suggestions.append("(angry)")
            suggestions.append("(whispering)")
        } else if trimmed.isEmpty || transitions.contains(where: { trimmed.uppercased().hasPrefix($0) }) {
            // Suggest transitions
            suggestions.append(contentsOf: transitions)
        }
        
        // Filter suggestions based on what's already typed
        if !trimmed.isEmpty {
            suggestions = suggestions.filter { $0.lowercased().contains(trimmed.lowercased()) }
        }
        
        return Array(suggestions.prefix(10)) // Limit to 10 suggestions
    }
    
    func selectNext() {
        if !suggestions.isEmpty {
            selectedIndex = (selectedIndex + 1) % suggestions.count
        }
    }
    
    func selectPrevious() {
        if !suggestions.isEmpty {
            selectedIndex = selectedIndex == 0 ? suggestions.count - 1 : selectedIndex - 1
        }
    }
    
    func getSelectedSuggestion() -> String? {
        guard !suggestions.isEmpty && selectedIndex < suggestions.count else { return nil }
        return suggestions[selectedIndex]
    }
    
    func hideSuggestions() {
        showSuggestions = false
        suggestions.removeAll()
    }
} 