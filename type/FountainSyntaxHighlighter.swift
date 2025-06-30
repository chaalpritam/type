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
        
        // Highlight scene headings
        highlightPattern(
            in: &attributed,
            pattern: #"^(?:INT|EXT|INT\/EXT|I\/E)\.?\s+.*$"#,
            color: .blue
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
        
        // Highlight transitions
        highlightPattern(
            in: &attributed,
            pattern: #"^(?:FADE OUT|FADE TO BLACK|CUT TO|DISSOLVE TO|SMASH CUT TO|JUMP CUT TO|MATCH CUT TO|FADE IN|FADE OUT|CUT TO BLACK|END|THE END).*$"#,
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
        
        // Highlight title page elements
        highlightPattern(
            in: &attributed,
            pattern: #"^[A-Za-z\s]+:\s+.*$"#,
            color: .brown
        )
        
        return attributed
    }
    
    private func highlightPattern(
        in attributed: inout AttributedString,
        pattern: String,
        color: Color
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
}

#Preview {
    let sampleText = """
    Title: The Great Screenplay
    Author: John Doe
    :

    # ACT ONE

    = This is the beginning of our story

    INT. COFFEE SHOP - DAY

    Sarah sits at a corner table, typing furiously on her laptop.

    SARAH
    (without looking up)
    I can't believe I'm finally writing this screenplay.

    > THE END <
    """
    
    return FountainSyntaxHighlighter(
        text: sampleText,
        font: .system(size: 14, design: .serif),
        baseColor: .black
    )
    .padding()
    .background(Color.white)
} 