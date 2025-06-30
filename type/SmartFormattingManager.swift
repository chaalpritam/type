import Foundation

class SmartFormattingManager: ObservableObject {
    @Published var autoCapitalizeCharacters: Bool = true
    @Published var autoFormatSpacing: Bool = true
    @Published var autoFormatTransitions: Bool = true
    
    private var characterNames: Set<String> = []
    
    func formatText(_ text: String) -> String {
        var formattedText = text
        
        if autoCapitalizeCharacters {
            formattedText = capitalizeCharacterNames(formattedText)
        }
        
        if autoFormatSpacing {
            formattedText = formatSpacing(formattedText)
        }
        
        if autoFormatTransitions {
            formattedText = formatTransitions(formattedText)
        }
        
        return formattedText
    }
    
    func updateCharacterNames(from text: String) {
        characterNames.removeAll()
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Extract character names (ALL CAPS)
            if trimmed.range(of: #"^[A-Z][A-Z\s]+$"#, options: .regularExpression) != nil {
                characterNames.insert(trimmed)
            }
        }
    }
    
    private func capitalizeCharacterNames(_ text: String) -> String {
        var formattedText = text
        let lines = formattedText.components(separatedBy: .newlines)
        var updatedLines: [String] = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Check if this looks like a character name (ALL CAPS with spaces)
            if trimmed.range(of: #"^[A-Za-z][A-Za-z\s]+$"#, options: .regularExpression) != nil {
                // If it's not already all caps and not empty, capitalize it
                if !trimmed.isEmpty && trimmed != trimmed.uppercased() {
                    let capitalized = trimmed.uppercased()
                    updatedLines.append(line.replacingOccurrences(of: trimmed, with: capitalized))
                    characterNames.insert(capitalized)
                    continue
                }
            }
            
            updatedLines.append(line)
        }
        
        return updatedLines.joined(separator: "\n")
    }
    
    private func formatSpacing(_ text: String) -> String {
        var formattedText = text
        let lines = formattedText.components(separatedBy: .newlines)
        var updatedLines: [String] = []
        
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Add proper spacing after scene headings
            if trimmed.range(of: #"^(?:INT|EXT|INT\/EXT|I\/E)\.?\s+.*$"#, options: .regularExpression) != nil {
                updatedLines.append(line)
                // Add extra line after scene heading if not already present
                if index + 1 < lines.count {
                    let nextLine = lines[index + 1].trimmingCharacters(in: .whitespaces)
                    if !nextLine.isEmpty {
                        updatedLines.append("")
                    }
                }
                continue
            }
            
            // Add proper spacing after transitions
            if trimmed.range(of: #"^(?:FADE OUT|FADE TO BLACK|CUT TO|DISSOLVE TO|SMASH CUT TO|JUMP CUT TO|MATCH CUT TO|FADE IN|FADE OUT|CUT TO BLACK|END|THE END).*$"#, options: .regularExpression) != nil {
                updatedLines.append(line)
                // Add extra line after transition if not already present
                if index + 1 < lines.count {
                    let nextLine = lines[index + 1].trimmingCharacters(in: .whitespaces)
                    if !nextLine.isEmpty {
                        updatedLines.append("")
                    }
                }
                continue
            }
            
            updatedLines.append(line)
        }
        
        return updatedLines.joined(separator: "\n")
    }
    
    private func formatTransitions(_ text: String) -> String {
        var formattedText = text
        let lines = formattedText.components(separatedBy: .newlines)
        var updatedLines: [String] = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Auto-capitalize common transitions
            let commonTransitions = [
                "fade in", "fade out", "fade to black", "cut to", "dissolve to",
                "smash cut to", "jump cut to", "match cut to", "the end", "end"
            ]
            
            for transition in commonTransitions {
                if trimmed.lowercased() == transition {
                    updatedLines.append(line.replacingOccurrences(of: trimmed, with: transition.uppercased()))
                    break
                }
            }
            
            if updatedLines.count == lines.count {
                break
            }
            
            if updatedLines.count < lines.count {
                updatedLines.append(line)
            }
        }
        
        return updatedLines.joined(separator: "\n")
    }
    
    func applySmartFormatting(to text: String, onLineChange: Int) -> String {
        // Only apply formatting to the current line or nearby context
        let lines = text.components(separatedBy: .newlines)
        guard lineChange < lines.count else { return text }
        
        var updatedLines = lines
        
        // Apply formatting to the current line and maybe the previous line
        let startIndex = max(0, lineChange - 1)
        let endIndex = min(lines.count, lineChange + 2)
        
        for i in startIndex..<endIndex {
            let line = lines[i]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Auto-capitalize character names
            if autoCapitalizeCharacters && trimmed.range(of: #"^[A-Za-z][A-Za-z\s]+$"#, options: .regularExpression) != nil {
                if !trimmed.isEmpty && trimmed != trimmed.uppercased() {
                    let capitalized = trimmed.uppercased()
                    updatedLines[i] = line.replacingOccurrences(of: trimmed, with: capitalized)
                    characterNames.insert(capitalized)
                }
            }
            
            // Auto-capitalize transitions
            if autoFormatTransitions {
                let commonTransitions = [
                    "fade in", "fade out", "fade to black", "cut to", "dissolve to",
                    "smash cut to", "jump cut to", "match cut to", "the end", "end"
                ]
                
                for transition in commonTransitions {
                    if trimmed.lowercased() == transition {
                        updatedLines[i] = line.replacingOccurrences(of: trimmed, with: transition.uppercased())
                        break
                    }
                }
            }
        }
        
        return updatedLines.joined(separator: "\n")
    }
} 