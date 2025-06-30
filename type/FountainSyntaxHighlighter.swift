import SwiftUI

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
            pattern: #"^!(?:INT|EXT|INT\/EXT|I\/E)\.?\s+.*$"#,
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
            pattern: #"^(?:INT|EXT|INT\/EXT|I\/E)\.?\s+.*$"#,
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
            color: .secondary
        )
        
        // Highlight centered text
        highlightPattern(
            in: &attributed,
            pattern: #"^>\s+.*\s+<$"#,
            color: .indigo
        )
        
        // Highlight lyrics
        highlightPattern(
            in: &attributed,
            pattern: #"^~.*~$"#,
            color: .pink,
            style: .italic
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
        style: Font.Style = .normal
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
                    attributed[startIndex..<endIndex].font = font.weight(weight)
                    if style == .italic {
                        attributed[startIndex..<endIndex].font = font.italic()
                    }
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
        // Highlight bold italic (**text** or __text__)
        highlightEmphasisPattern(
            in: &attributed,
            pattern: #"\*\*([^*]+)\*\*|__([^_]+)__"#,
            weight: .bold,
            style: .italic
        )
        
        // Highlight bold (*text*)
        highlightEmphasisPattern(
            in: &attributed,
            pattern: #"\*([^*]+)\*"#,
            weight: .bold
        )
        
        // Highlight italic (_text_)
        highlightEmphasisPattern(
            in: &attributed,
            pattern: #"_([^_]+)_"#,
            style: .italic
        )
    }
    
    private func highlightEmphasisPattern(
        in attributed: inout AttributedString,
        pattern: String,
        weight: Font.Weight = .regular,
        style: Font.Style = .normal
    ) {
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(attributed.startIndex..., in: attributed)
        
        regex?.enumerateMatches(in: attributed.description, range: range) { match, _, _ in
            guard let match = match,
                  let range = Range(match.range, in: attributed.description) else { return }
            
            let attributedRange = AttributedString(attributed.description[range]).startIndex..<AttributedString(attributed.description[range]).endIndex
            
            if let startIndex = attributed.index(attributed.startIndex, offsetByCharacters: range.lowerBound.utf16Offset(in: attributed.description)),
               let endIndex = attributed.index(attributed.startIndex, offsetByCharacters: range.upperBound.utf16Offset(in: attributed.description)) {
                
                attributed[startIndex..<endIndex].font = font.weight(weight)
                if style == .italic {
                    attributed[startIndex..<endIndex].font = font.italic()
                }
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