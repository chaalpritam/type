import SwiftUI
import AppKit

// MARK: - Fountain Syntax Highlighter View
/// SwiftUI view for displaying syntax-highlighted Fountain text
struct FountainSyntaxHighlighter: View {
    let text: String
    let font: Font
    let baseColor: Color
    
    var body: some View {
        Text(attributedString)
            .font(font)
            .lineLimit(nil)
    }
    
    private var attributedString: AttributedString {
        var attributed = AttributedString(text)
        
        // Apply base styling
        attributed.foregroundColor = baseColor
        
        // Highlight force scene headings
        highlightPattern(
            in: &attributed,
            pattern: #"^!(?:INT|EXT|INT/EXT|I/E)\.?\s+.*$"#,
            color: .blue,
            weight: .bold
        )
        
        // Highlight force action
        highlightPattern(
            in: &attributed,
            pattern: #"^@.*$"#,
            color: .purple,
            weight: .semibold
        )
        
        // Highlight scene headings
        highlightPattern(
            in: &attributed,
            pattern: #"^(?:INT|EXT|INT/EXT|I/E)\.?\s+.*$"#,
            color: .blue
        )
        
        // Highlight dual dialogue characters
        highlightPattern(
            in: &attributed,
            pattern: #"^[A-Z][A-Z\s]+\^$"#,
            color: .orange,
            weight: .bold
        )
        
        // Highlight character names
        highlightPattern(
            in: &attributed,
            pattern: #"^[A-Z][A-Z\s]+$"#,
            color: .purple
        )
        
        // Highlight parentheticals
        highlightPattern(
            in: &attributed,
            pattern: #"^\(.*\)$"#,
            color: .orange
        )
        
        // Highlight enhanced transitions
        highlightPattern(
            in: &attributed,
            pattern: #"^(?:FADE OUT|FADE TO BLACK|CUT TO|DISSOLVE TO|SMASH CUT TO|JUMP CUT TO|MATCH CUT TO|FADE IN|FADE OUT|CUT TO BLACK|END|THE END|IRIS IN|IRIS OUT|WIPE TO|DISSOLVE|FADE|CUT|SMASH CUT|JUMP CUT|MATCH CUT|IRIS|WIPE).*$"#,
            color: .red
        )
        
        // Highlight sections
        highlightPattern(
            in: &attributed,
            pattern: #"^#+\s+.*$"#,
            color: .green
        )
        
        // Highlight synopsis
        highlightPattern(
            in: &attributed,
            pattern: #"^=\s+.*$"#,
            color: .gray
        )
        
        // Highlight notes
        highlightPattern(
            in: &attributed,
            pattern: #"^\[\[.*\]\]$"#,
            color: .gray
        )
        
        // Highlight centered text
        highlightPattern(
            in: &attributed,
            pattern: #"^>\s+.*\s+<$"#,
            color: .blue
        )
        
        // Highlight lyrics
        highlightPattern(
            in: &attributed,
            pattern: #"^~.*~$"#,
            color: .pink,
            italic: true
        )
        
        // Highlight title page elements
        highlightPattern(
            in: &attributed,
            pattern: #"^[A-Za-z\s]+:\s+.*$"#,
            color: .brown
        )
        
        // Highlight emphasis within dialogue
        highlightEmphasis(in: &attributed)
        
        return attributed
    }
    
    private func highlightPattern(
        in attributed: inout AttributedString,
        pattern: String,
        color: Color,
        weight: Font.Weight = .regular,
        italic: Bool = false
    ) {
        let lines = text.components(separatedBy: .newlines)
        var currentPosition = attributed.startIndex
        
        for line in lines {
            if let range = line.range(of: pattern, options: .regularExpression) {
                let startOffset = line.distance(from: line.startIndex, to: range.lowerBound)
                let endOffset = line.distance(from: line.startIndex, to: range.upperBound)
                
                let startIndex = attributed.index(currentPosition, offsetByCharacters: startOffset)
                let endIndex = attributed.index(currentPosition, offsetByCharacters: endOffset)
                
                if startIndex < endIndex && endIndex <= attributed.endIndex {
                    attributed[startIndex..<endIndex].foregroundColor = color
                    var fontToApply = font
                    switch weight {
                    case .bold: fontToApply = fontToApply.bold()
                    case .semibold: fontToApply = fontToApply.weight(.semibold)
                    default: break
                    }
                    if italic {
                        fontToApply = fontToApply.italic()
                    }
                    attributed[startIndex..<endIndex].font = fontToApply
                }
            }
            // Move to next line
            if let newlineRange = attributed[currentPosition...].range(of: "\n") {
                currentPosition = newlineRange.upperBound
            } else {
                break
            }
        }
    }
    
    private func highlightEmphasis(in attributed: inout AttributedString) {
        // Bold italic (**text** or __text__)
        highlightEmphasisPattern(
            in: &attributed,
            pattern: #"\*\*([^*]+)\*\*|__([^_]+)__"#,
            weight: .bold,
            italic: true
        )
        // Bold (*text*)
        highlightEmphasisPattern(
            in: &attributed,
            pattern: #"\*([^*]+)\*"#,
            weight: .bold
        )
        // Italic (_text_)
        highlightEmphasisPattern(
            in: &attributed,
            pattern: #"_([^_]+)_"#,
            italic: true
        )
    }
    
    private func highlightEmphasisPattern(
        in attributed: inout AttributedString,
        pattern: String,
        weight: Font.Weight = .regular,
        italic: Bool = false
    ) {
        let string = String(attributed.characters)
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
        let nsString = string as NSString
        let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: nsString.length))
        let baseFont = font
        for match in matches {
            guard match.numberOfRanges > 1 else { continue }
            let matchRange = match.range(at: 1)
            if let swiftRange = Range(matchRange, in: string) {
                let startOffset = string.distance(from: string.startIndex, to: swiftRange.lowerBound)
                let length = string.distance(from: swiftRange.lowerBound, to: swiftRange.upperBound)
                let start = attributed.index(attributed.startIndex, offsetByCharacters: startOffset)
                let end = attributed.index(start, offsetByCharacters: length)
                var fontToApply = baseFont
                switch weight {
                case .bold: fontToApply = fontToApply.bold()
                case .semibold: fontToApply = fontToApply.weight(.semibold)
                default: break
                }
                if italic {
                    fontToApply = fontToApply.italic()
                }
                attributed[start..<end].font = fontToApply
            }
        }
    }
}

// MARK: - NSAttributedString Highlighting
/// Extension for highlighting NSMutableAttributedString
/// Used by DocumentController for editor highlighting
extension FountainSyntaxHighlighter {
    
    /// Highlight an NSMutableAttributedString with parsed Fountain elements
    /// This method is used by DocumentController for real-time syntax highlighting
    func highlight(_ attributedString: NSMutableAttributedString, elements: [FountainElement]) {
        // Define colors for element types
        let colors: [FountainElementType: NSColor] = [
            .sceneHeading: NSColor.systemBlue,
            .forceSceneHeading: NSColor.systemBlue,
            .character: NSColor.systemPurple,
            .dialogue: NSColor.labelColor,
            .parenthetical: NSColor.systemOrange,
            .transition: NSColor.systemRed,
            .section: NSColor.systemGreen,
            .synopsis: NSColor.systemGray,
            .note: NSColor.systemGray,
            .centered: NSColor.systemBlue,
            .lyrics: NSColor.systemPink,
            .action: NSColor.labelColor,
            .titlePage: NSColor.systemBrown,
            .boneyard: NSColor.systemGray,
            .pageBreak: NSColor.systemGray
        ]
        
        // Apply highlighting for each element
        for element in elements {
            guard let range = element.range,
                  range.location + range.length <= attributedString.length else { continue }
            
            // Set foreground color
            if let color = colors[element.type] {
                attributedString.addAttribute(.foregroundColor, value: color, range: range)
            }
            
            // Apply bold for scene headings and characters
            if element.type == .sceneHeading || element.type == .forceSceneHeading || element.type == .character {
                if let font = NSFont(name: "Courier Prime Bold", size: 12) ?? NSFont.boldSystemFont(ofSize: 12) as NSFont? {
                    attributedString.addAttribute(.font, value: font, range: range)
                }
            }
            
            // Apply italic for lyrics and synopsis
            if element.type == .lyrics || element.type == .synopsis {
                if let font = NSFont(name: "Courier Prime Italic", size: 12) ?? NSFont.systemFont(ofSize: 12) as NSFont? {
                    attributedString.addAttribute(.font, value: font, range: range)
                }
            }
        }
        
        // Highlight inline emphasis markers
        highlightInlineEmphasis(attributedString)
    }
    
    /// Highlight inline emphasis (bold, italic, underline)
    private func highlightInlineEmphasis(_ attributedString: NSMutableAttributedString) {
        let text = attributedString.string
        
        // Bold italic: ***text*** or ___text___
        highlightPattern(
            in: attributedString,
            text: text,
            pattern: #"\*\*\*([^*]+)\*\*\*|___([^_]+)___"#,
            traits: [.bold, .italic]
        )
        
        // Bold: **text**
        highlightPattern(
            in: attributedString,
            text: text,
            pattern: #"\*\*([^*]+)\*\*"#,
            traits: [.bold]
        )
        
        // Italic: *text*
        highlightPattern(
            in: attributedString,
            text: text,
            pattern: #"\*([^*]+)\*"#,
            traits: [.italic]
        )
        
        // Underline: _text_
        highlightPattern(
            in: attributedString,
            text: text,
            pattern: #"_([^_]+)_"#,
            underline: true
        )
    }
    
    private func highlightPattern(
        in attributedString: NSMutableAttributedString,
        text: String,
        pattern: String,
        traits: NSFontDescriptor.SymbolicTraits = [],
        underline: Bool = false
    ) {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            let fullRange = match.range
            
            // Apply font traits
            if !traits.isEmpty {
                if let existingFont = attributedString.attribute(.font, at: fullRange.location, effectiveRange: nil) as? NSFont {
                    let descriptor = existingFont.fontDescriptor.withSymbolicTraits(traits)
                    if let newFont = NSFont(descriptor: descriptor, size: existingFont.pointSize) {
                        attributedString.addAttribute(.font, value: newFont, range: fullRange)
                    }
                }
            }
            
            // Apply underline
            if underline {
                attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: fullRange)
            }
        }
    }
}

#Preview {
    let sampleText = """
    Title: The Great Screenplay
    Author: John Doe
    :

    # ACT ONE

    = This is the beginning of our story

    !INT. COFFEE SHOP - DAY

    @Sarah sits at a corner table, typing furiously on her laptop.

    SARAH
    (without looking up)
    I can't believe I'm *finally* writing this screenplay.

    MIKE
    (approaching)
    Hey, Sarah! How's the writing going?

    SARAH^
    (looking up, surprised)
    Mike! I didn't expect to see you here.

    ~La la la, singing a song~

    > THE END <

    [[This is a private note]]
    """
    
    return FountainSyntaxHighlighter(
        text: sampleText,
        font: .system(size: 14, design: .serif),
        baseColor: .black
    )
    .padding()
    .background(Color.white)
} 