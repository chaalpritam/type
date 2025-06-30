import Foundation

// MARK: - Fountain Element Types
enum FountainElementType {
    case titlePage
    case sceneHeading
    case action
    case character
    case dialogue
    case parenthetical
    case transition
    case section
    case synopsis
    case note
    case centered
    case pageBreak
}

// MARK: - Fountain Element
struct FountainElement: Identifiable {
    let id = UUID()
    let type: FountainElementType
    let text: String
    let originalText: String
    let lineNumber: Int
}

// MARK: - Fountain Parser
class FountainParser: ObservableObject {
    @Published var elements: [FountainElement] = []
    @Published var titlePage: [String: String] = [:]
    
    // Regular expressions for Fountain syntax
    private let sceneHeadingPattern = #"^(?:INT|EXT|INT\/EXT|I\/E)\.?\s+.*$"#
    private let characterPattern = #"^[A-Z][A-Z\s]+$"#
    private let parentheticalPattern = #"^\(.*\)$"#
    private let transitionPattern = #"^(?:FADE OUT|FADE TO BLACK|CUT TO|DISSOLVE TO|SMASH CUT TO|JUMP CUT TO|MATCH CUT TO|FADE IN|FADE OUT|CUT TO BLACK|END|THE END).*$"#
    private let sectionPattern = #"^#+\s+.*$"#
    private let synopsisPattern = #"^=\s+.*$"#
    private let notePattern = #"^\[\[.*\]\]$"#
    private let centeredPattern = #"^>\s+.*\s+<$"#
    private let pageBreakPattern = #"^={3,}$"#
    
    func parse(_ text: String) {
        let lines = text.components(separatedBy: .newlines)
        var newElements: [FountainElement] = []
        var newTitlePage: [String: String] = [:]
        
        var isInTitlePage = true
        var lineNumber = 0
        
        for line in lines {
            lineNumber += 1
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines
            if trimmedLine.isEmpty {
                continue
            }
            
            // Check for title page
            if isInTitlePage {
                if let titlePageElement = parseTitlePageLine(trimmedLine) {
                    newTitlePage[titlePageElement.key] = titlePageElement.value
                    continue
                } else if trimmedLine.hasPrefix(":") {
                    isInTitlePage = false
                    continue
                }
            }
            
            // Parse screenplay elements
            if let element = parseScreenplayLine(trimmedLine, lineNumber: lineNumber) {
                newElements.append(element)
            }
        }
        
        DispatchQueue.main.async {
            self.elements = newElements
            self.titlePage = newTitlePage
        }
    }
    
    private func parseTitlePageLine(_ line: String) -> (key: String, value: String)? {
        let components = line.components(separatedBy: ":")
        guard components.count >= 2 else { return nil }
        
        let key = components[0].trimmingCharacters(in: .whitespaces)
        let value = components.dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
        
        return (key: key, value: value)
    }
    
    private func parseScreenplayLine(_ line: String, lineNumber: Int) -> FountainElement? {
        // Check for page break
        if line.range(of: pageBreakPattern, options: .regularExpression) != nil {
            return FountainElement(type: .pageBreak, text: "", originalText: line, lineNumber: lineNumber)
        }
        
        // Check for centered text
        if line.range(of: centeredPattern, options: .regularExpression) != nil {
            let text = line.replacingOccurrences(of: "^>\\s+", with: "", options: .regularExpression)
                .replacingOccurrences(of: "\\s+<$", with: "", options: .regularExpression)
            return FountainElement(type: .centered, text: text, originalText: line, lineNumber: lineNumber)
        }
        
        // Check for notes
        if line.range(of: notePattern, options: .regularExpression) != nil {
            let text = line.replacingOccurrences(of: "^\\[\\[|\\]\\]$", with: "", options: .regularExpression)
            return FountainElement(type: .note, text: text, originalText: line, lineNumber: lineNumber)
        }
        
        // Check for synopsis
        if line.range(of: synopsisPattern, options: .regularExpression) != nil {
            let text = line.replacingOccurrences(of: "^=\\s+", with: "", options: .regularExpression)
            return FountainElement(type: .synopsis, text: text, originalText: line, lineNumber: lineNumber)
        }
        
        // Check for sections
        if line.range(of: sectionPattern, options: .regularExpression) != nil {
            let level = line.prefix(while: { $0 == "#" }).count
            let text = line.replacingOccurrences(of: "^#+\\s+", with: "", options: .regularExpression)
            return FountainElement(type: .section, text: text, originalText: line, lineNumber: lineNumber)
        }
        
        // Check for transitions
        if line.range(of: transitionPattern, options: .regularExpression) != nil {
            return FountainElement(type: .transition, text: line, originalText: line, lineNumber: lineNumber)
        }
        
        // Check for scene headings
        if line.range(of: sceneHeadingPattern, options: .regularExpression) != nil {
            return FountainElement(type: .sceneHeading, text: line, originalText: line, lineNumber: lineNumber)
        }
        
        // Check for parentheticals
        if line.range(of: parentheticalPattern, options: .regularExpression) != nil {
            let text = line.replacingOccurrences(of: "^\\(|\\)$", with: "", options: .regularExpression)
            return FountainElement(type: .parenthetical, text: text, originalText: line, lineNumber: lineNumber)
        }
        
        // Check for character names
        if line.range(of: characterPattern, options: .regularExpression) != nil {
            return FountainElement(type: .character, text: line, originalText: line, lineNumber: lineNumber)
        }
        
        // Default to action
        return FountainElement(type: .action, text: line, originalText: line, lineNumber: lineNumber)
    }
} 