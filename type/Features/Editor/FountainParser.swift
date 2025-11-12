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
    case forceSceneHeading
    case forceAction
    case lyrics
    case emphasis
    case dualDialogue
}

// MARK: - Fountain Element
struct FountainElement: Identifiable {
    let id = UUID()
    let type: FountainElementType
    let text: String
    let originalText: String
    let lineNumber: Int
    let emphasis: EmphasisType?
    let isDualDialogue: Bool
}

// MARK: - Emphasis Types
enum EmphasisType {
    case bold
    case italic
    case boldItalic
}

// MARK: - Fountain Parser
class FountainParser: ObservableObject {
    @Published var elements: [FountainElement] = []
    @Published var titlePage: [String: String] = [:]
    
    // Enhanced regular expressions for Fountain syntax
    private let sceneHeadingPattern = #"^(?:INT|EXT|INT\/EXT|I\/E)\.?\s+.*$"#
    private let forceSceneHeadingPattern = #"^!(?:INT|EXT|INT\/EXT|I\/E)\.?\s+.*$"#
    private let forceActionPattern = #"^@.*$"#
    private let characterPattern = #"^[A-Z][A-Z\s]+$"#
    private let dualDialoguePattern = #"^[A-Z][A-Z\s]+\^$"#
    private let parentheticalPattern = #"^\(.*\)$"#
    private let transitionPattern = #"^(?:FADE OUT|FADE TO BLACK|CUT TO|DISSOLVE TO|SMASH CUT TO|JUMP CUT TO|MATCH CUT TO|FADE IN|FADE OUT|CUT TO BLACK|END|THE END|IRIS IN|IRIS OUT|WIPE TO|DISSOLVE|FADE|CUT|SMASH CUT|JUMP CUT|MATCH CUT|IRIS|WIPE).*$"#
    private let sectionPattern = #"^#+\s+.*$"#
    private let synopsisPattern = #"^=\s+.*$"#
    private let notePattern = #"^\[\[.*\]\]$"#
    private let centeredPattern = #"^>\s+.*\s+<$"#
    private let pageBreakPattern = #"^={3,}$"#
    private let lyricsPattern = #"^~.*~$"#
    private let emphasisPattern = #"(\*[^*]+\*|_[^_]+_|\*\*[^*]+\*\*|__[^_]+__)"#
    
    func parse(_ text: String) {
        let lines = text.components(separatedBy: .newlines)
        var newElements: [FountainElement] = []
        var newTitlePage: [String: String] = [:]
        
        var isInTitlePage = true
        var lineNumber = 0
        var previousCharacter: String? = nil
        
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
            if let element = parseScreenplayLine(trimmedLine, lineNumber: lineNumber, previousCharacter: &previousCharacter) {
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
    
    private func parseScreenplayLine(_ line: String, lineNumber: Int, previousCharacter: inout String?) -> FountainElement? {
        // Check for page break
        if line.range(of: pageBreakPattern, options: .regularExpression) != nil {
            return FountainElement(type: .pageBreak, text: "", originalText: line, lineNumber: lineNumber, emphasis: nil, isDualDialogue: false)
        }
        
        // Check for force scene heading
        if line.range(of: forceSceneHeadingPattern, options: .regularExpression) != nil {
            let text = line.replacingOccurrences(of: "^!\\s*", with: "", options: .regularExpression)
            return FountainElement(type: .forceSceneHeading, text: text, originalText: line, lineNumber: lineNumber, emphasis: nil, isDualDialogue: false)
        }
        
        // Check for force action
        if line.range(of: forceActionPattern, options: .regularExpression) != nil {
            let text = line.replacingOccurrences(of: "^@\\s*", with: "", options: .regularExpression)
            return FountainElement(type: .forceAction, text: text, originalText: line, lineNumber: lineNumber, emphasis: nil, isDualDialogue: false)
        }
        
        // Check for lyrics
        if line.range(of: lyricsPattern, options: .regularExpression) != nil {
            let text = line.replacingOccurrences(of: "^~|~$", with: "", options: .regularExpression)
            return FountainElement(type: .lyrics, text: text, originalText: line, lineNumber: lineNumber, emphasis: nil, isDualDialogue: false)
        }
        
        // Check for centered text
        if line.range(of: centeredPattern, options: .regularExpression) != nil {
            let text = line.replacingOccurrences(of: "^>\\s+", with: "", options: .regularExpression)
                .replacingOccurrences(of: "\\s+<$", with: "", options: .regularExpression)
            return FountainElement(type: .centered, text: text, originalText: line, lineNumber: lineNumber, emphasis: nil, isDualDialogue: false)
        }
        
        // Check for notes
        if line.range(of: notePattern, options: .regularExpression) != nil {
            let text = line.replacingOccurrences(of: "^\\[\\[|\\]\\]$", with: "", options: .regularExpression)
            return FountainElement(type: .note, text: text, originalText: line, lineNumber: lineNumber, emphasis: nil, isDualDialogue: false)
        }
        
        // Check for synopsis
        if line.range(of: synopsisPattern, options: .regularExpression) != nil {
            let text = line.replacingOccurrences(of: "^=\\s+", with: "", options: .regularExpression)
            return FountainElement(type: .synopsis, text: text, originalText: line, lineNumber: lineNumber, emphasis: nil, isDualDialogue: false)
        }
        
        // Check for sections
        if line.range(of: sectionPattern, options: .regularExpression) != nil {
            _ = line.prefix(while: { $0 == "#" }).count
            let text = line.replacingOccurrences(of: "^#+\\s+", with: "", options: .regularExpression)
            return FountainElement(type: .section, text: text, originalText: line, lineNumber: lineNumber, emphasis: nil, isDualDialogue: false)
        }
        
        // Check for transitions
        if line.range(of: transitionPattern, options: .regularExpression) != nil {
            return FountainElement(type: .transition, text: line, originalText: line, lineNumber: lineNumber, emphasis: nil, isDualDialogue: false)
        }
        
        // Check for scene headings
        if line.range(of: sceneHeadingPattern, options: .regularExpression) != nil {
            return FountainElement(type: .sceneHeading, text: line, originalText: line, lineNumber: lineNumber, emphasis: nil, isDualDialogue: false)
        }
        
        // Check for dual dialogue character
        if line.range(of: dualDialoguePattern, options: .regularExpression) != nil {
            let characterName = line.replacingOccurrences(of: "\\^$", with: "", options: .regularExpression)
            previousCharacter = characterName
            return FountainElement(type: .character, text: characterName, originalText: line, lineNumber: lineNumber, emphasis: nil, isDualDialogue: true)
        }
        
        // Check for parentheticals
        if line.range(of: parentheticalPattern, options: .regularExpression) != nil {
            let text = line.replacingOccurrences(of: "^\\(|\\)$", with: "", options: .regularExpression)
            return FountainElement(type: .parenthetical, text: text, originalText: line, lineNumber: lineNumber, emphasis: nil, isDualDialogue: false)
        }
        
        // Check for character names
        if line.range(of: characterPattern, options: .regularExpression) != nil {
            previousCharacter = line
            return FountainElement(type: .character, text: line, originalText: line, lineNumber: lineNumber, emphasis: nil, isDualDialogue: false)
        }
        
        // Check for dialogue with emphasis
        if previousCharacter != nil {
            let emphasis = parseEmphasis(in: line)
            return FountainElement(type: .dialogue, text: line, originalText: line, lineNumber: lineNumber, emphasis: emphasis, isDualDialogue: false)
        }
        
        // Default to action
        return FountainElement(type: .action, text: line, originalText: line, lineNumber: lineNumber, emphasis: nil, isDualDialogue: false)
    }
    
    private func parseEmphasis(in text: String) -> EmphasisType? {
        // Check for bold italic (**text** or __text__)
        if text.range(of: #"\*\*[^*]+\*\*|__[^_]+__"#, options: .regularExpression) != nil {
            return .boldItalic
        }
        
        // Check for bold (*text*)
        if text.range(of: #"\*[^*]+\*"#, options: .regularExpression) != nil {
            return .bold
        }
        
        // Check for italic (_text_)
        if text.range(of: #"_[^_]+_"#, options: .regularExpression) != nil {
            return .italic
        }
        
        return nil
    }
    
    // Helper method to extract emphasis text
    func extractEmphasisText(from text: String) -> String {
        var result = text
        
        // Remove emphasis markers
        result = result.replacingOccurrences(of: #"\*\*([^*]+)\*\*"#, with: "$1", options: .regularExpression)
        result = result.replacingOccurrences(of: #"__([^_]+)__"#, with: "$1", options: .regularExpression)
        result = result.replacingOccurrences(of: #"\*([^*]+)\*"#, with: "$1", options: .regularExpression)
        result = result.replacingOccurrences(of: #"_([^_]+)_"#, with: "$1", options: .regularExpression)
        
        return result
    }
} 
