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
            color: .blue,
            weight: .bold
        )
        
        // Highlight character names
        highlightPattern(
            in: &attributed,
            pattern: #"^[A-Z][A-Z\s]+$"#,
            color: .purple,
            weight: .bold
        )
        
        // Highlight parentheticals
        highlightPattern(
            in: &attributed,
            pattern: #"^\(.*\)$"#,
            color: .orange,
            weight: .regular
        )
        
        // Highlight transitions
        highlightPattern(
            in: &attributed,
            pattern: #"^(?:FADE OUT|FADE TO BLACK|CUT TO|DISSOLVE TO|SMASH CUT TO|JUMP CUT TO|MATCH CUT TO|FADE IN|FADE OUT|CUT TO BLACK|END|THE END).*$"#,
            color: .red,
            weight: .bold
        )
        
        // Highlight sections
        highlightPattern(
            in: &attributed,
            pattern: #"^#+\s+.*$"#,
            color: .green,
            weight: .bold
        )
        
        // Highlight synopsis
        highlightPattern(
            in: &attributed,
            pattern: #"^=\s+.*$"#,
            color: .gray,
            weight: .italic
        )
        
        // Highlight notes
        highlightPattern(
            in: &attributed,
            pattern: #"^\[\[.*\]\]$"#,
            color: .secondary,
            weight: .regular
        )
        
        // Highlight centered text
        highlightPattern(
            in: &attributed,
            pattern: #"^>\s+.*\s+<$"#,
            color: .indigo,
            weight: .regular
        )
        
        // Highlight title page elements
        highlightPattern(
            in: &attributed,
            pattern: #"^[A-Za-z\s]+:\s+.*$"#,
            color: .brown,
            weight: .medium
        )
        
        return attributed
    }
    
    private func highlightPattern(
        in attributed: inout AttributedString,
        pattern: String,
        color: Color,
        weight: Font.Weight
    ) {
        let lines = attributed.characters.split(separator: "\n")
        var currentIndex = attributed.startIndex
        
        for line in lines {
            let lineString = String(line)
            
            if let range = lineString.range(of: pattern, options: .regularExpression) {
                let startIndex = attributed.index(currentIndex, offsetBy: lineString.distance(from: lineString.startIndex, to: range.lowerBound))
                let endIndex = attributed.index(currentIndex, offsetBy: lineString.distance(from: lineString.startIndex, to: range.upperBound))
                
                if startIndex < endIndex && endIndex <= attributed.endIndex {
                    attributed[startIndex..<endIndex].foregroundColor = color
                    attributed[startIndex..<endIndex].font = font.weight(weight)
                }
            }
            
            // Move to next line
            if let newlineIndex = attributed[currentIndex...].firstIndex(of: "\n") {
                currentIndex = attributed.index(after: newlineIndex)
            } else {
                break
            }
        }
    }
}

// Extension to support font weight in AttributedString
extension AttributeScopes.SwiftUIAttributes {
    struct FontAttribute: AttributeScopes.SwiftUIAttributes {
        typealias Value = Font
    }
}

extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.SwiftUIAttributes, T>) -> T {
        return self[T.self]
    }
}

extension AttributeScopes.SwiftUIAttributes {
    var font: FontAttribute.Type { FontAttribute.self }
}

extension AttributeScopes.SwiftUIAttributes.FontAttribute: CodableAttributedStringKey {
    typealias Value = Font
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