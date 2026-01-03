import SwiftUI
import AppKit

// MARK: - Clean Fountain Syntax Highlighter
/// A minimalist syntax highlighter that de-emphasizes Fountain markup
/// Makes markup symbols nearly invisible while keeping content prominent
struct CleanFountainSyntaxHighlighter: View {
    let text: String
    let font: Font
    let baseColor: Color

    // Cache for attributed string to avoid redundant highlighting
    @State private var cachedText: String = ""
    @State private var cachedAttributedString: AttributedString = AttributedString("")

    var body: some View {
        Text(currentAttributedString)
            .font(font)
            .lineSpacing(ScreenplayTypography.standardLineSpacing)
            .lineLimit(nil)
    }

    private var currentAttributedString: AttributedString {
        // Return cached version if text hasn't changed
        if text == cachedText {
            return cachedAttributedString
        }

        // Otherwise, compute new attributed string
        let attributed = computeAttributedString()

        // Update cache
        Task { @MainActor in
            cachedText = text
            cachedAttributedString = attributed
        }

        return attributed
    }

    private func computeAttributedString() -> AttributedString {
        var attributed = AttributedString(text)

        // Apply base styling - make content prominent
        attributed.foregroundColor = baseColor

        // De-emphasize markup symbols by making them very light gray
        let markupColor = Color.gray.opacity(0.3)

        // Hide scene heading prefixes (INT., EXT., etc.) but keep location
        hidePattern(
            in: &attributed,
            pattern: #"^(INT\.|EXT\.|INT/EXT\.|I/E\.)\s+"#,
            markupColor: markupColor,
            contentColor: .blue,
            contentWeight: .semibold
        )

        // Hide force markers (! and @)
        hidePattern(
            in: &attributed,
            pattern: #"^[!@]"#,
            markupColor: markupColor
        )

        // Hide section markers (#)
        hidePattern(
            in: &attributed,
            pattern: #"^#+\s+"#,
            markupColor: markupColor,
            contentColor: .green,
            contentWeight: .bold
        )

        // Hide synopsis marker (=)
        hidePattern(
            in: &attributed,
            pattern: #"^=\s+"#,
            markupColor: markupColor,
            contentColor: .gray
        )

        // Hide note brackets ([[ ]])
        hidePattern(
            in: &attributed,
            pattern: #"^\[\[|\]\]$"#,
            markupColor: markupColor,
            contentColor: .gray.opacity(0.7)
        )

        // Hide centered text markers (> <)
        hidePattern(
            in: &attributed,
            pattern: #"^>\s+|\s+<$"#,
            markupColor: markupColor,
            contentColor: .blue
        )

        // Hide lyrics markers (~)
        hidePattern(
            in: &attributed,
            pattern: #"^~|~$"#,
            markupColor: markupColor,
            contentColor: .pink
        )

        // Character names - show prominently without hiding anything
        highlightPattern(
            in: &attributed,
            pattern: #"^[A-Z][A-Z\s]+(\^)?$"#,
            color: .purple,
            weight: .semibold
        )

        // Parentheticals - slightly de-emphasize the parentheses
        highlightParenthetical(in: &attributed)

        // Transitions - show in red
        highlightPattern(
            in: &attributed,
            pattern: #"^(?:FADE OUT|FADE TO BLACK|CUT TO|DISSOLVE TO|SMASH CUT TO|JUMP CUT TO|MATCH CUT TO|FADE IN|CUT TO BLACK|END|THE END|IRIS IN|IRIS OUT|WIPE TO|DISSOLVE|FADE|CUT|SMASH CUT|JUMP CUT|MATCH CUT|IRIS|WIPE).*$"#,
            color: .red.opacity(0.8)
        )

        // Hide emphasis markers but apply formatting
        hideEmphasisMarkers(in: &attributed)

        // Title page keys - de-emphasize colons
        hidePattern(
            in: &attributed,
            pattern: #"^([A-Za-z\s]+)(:)\s+"#,
            markupColor: markupColor,
            contentColor: .brown.opacity(0.8)
        )

        return attributed
    }

    /// Hide markup pattern while keeping content visible
    private func hidePattern(
        in attributed: inout AttributedString,
        pattern: String,
        markupColor: Color,
        contentColor: Color? = nil,
        contentWeight: Font.Weight = .regular
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
                    // Make markup very subtle
                    attributed[startIndex..<endIndex].foregroundColor = markupColor
                }

                // If there's content color specified, apply it to the rest of the line
                if let contentColor = contentColor {
                    let lineEndOffset = line.count
                    let lineEndIndex = attributed.index(currentPosition, offsetByCharacters: lineEndOffset)

                    if endIndex < lineEndIndex && lineEndIndex <= attributed.endIndex {
                        attributed[endIndex..<lineEndIndex].foregroundColor = contentColor
                        if contentWeight != .regular {
                            attributed[endIndex..<lineEndIndex].font = font.weight(contentWeight)
                        }
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

    /// Standard highlighting for patterns
    private func highlightPattern(
        in attributed: inout AttributedString,
        pattern: String,
        color: Color,
        weight: Font.Weight = .regular
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
                    if weight != .regular {
                        attributed[startIndex..<endIndex].font = font.weight(weight)
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

    /// De-emphasize parentheses in parentheticals
    private func highlightParenthetical(in attributed: inout AttributedString) {
        let lines = text.components(separatedBy: .newlines)
        var currentPosition = attributed.startIndex
        let markupColor = Color.gray.opacity(0.3)

        for line in lines {
            if let fullRange = line.range(of: #"^\((.*)\)$"#, options: .regularExpression) {
                // Make the parentheses subtle
                let startParenOffset = line.distance(from: line.startIndex, to: fullRange.lowerBound)
                let startParenIndex = attributed.index(currentPosition, offsetByCharacters: startParenOffset)
                let afterStartParenIndex = attributed.index(startParenIndex, offsetByCharacters: 1)

                if startParenIndex < afterStartParenIndex && afterStartParenIndex <= attributed.endIndex {
                    attributed[startParenIndex..<afterStartParenIndex].foregroundColor = markupColor
                }

                // Find closing paren
                if let closingParenIndex = line.lastIndex(of: ")") {
                    let closingOffset = line.distance(from: line.startIndex, to: closingParenIndex)
                    let closingStart = attributed.index(currentPosition, offsetByCharacters: closingOffset)
                    let closingEnd = attributed.index(closingStart, offsetByCharacters: 1)

                    if closingStart < closingEnd && closingEnd <= attributed.endIndex {
                        attributed[closingStart..<closingEnd].foregroundColor = markupColor
                    }
                }

                // Make content orange
                let contentStartOffset = startParenOffset + 1
                let contentEndOffset = line.distance(from: line.startIndex, to: line.index(before: line.endIndex))

                if contentStartOffset < contentEndOffset {
                    let contentStart = attributed.index(currentPosition, offsetByCharacters: contentStartOffset)
                    let contentEnd = attributed.index(currentPosition, offsetByCharacters: contentEndOffset)

                    if contentStart < contentEnd && contentEnd <= attributed.endIndex {
                        attributed[contentStart..<contentEnd].foregroundColor = .orange.opacity(0.9)
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

    /// Hide emphasis markers (*, _, **, etc.) but apply the formatting
    private func hideEmphasisMarkers(in attributed: inout AttributedString) {
        let string = String(attributed.characters)
        let markupColor = Color.gray.opacity(0.2)

        // Bold italic: ***text*** or ___text___
        hideEmphasisPattern(
            in: &attributed,
            text: string,
            pattern: #"\*\*\*([^*]+)\*\*\*|___([^_]+)___"#,
            weight: .bold,
            italic: true,
            markupColor: markupColor
        )

        // Bold: **text**
        hideEmphasisPattern(
            in: &attributed,
            text: string,
            pattern: #"\*\*([^*]+)\*\*"#,
            weight: .bold,
            markupColor: markupColor
        )

        // Italic: *text*
        hideEmphasisPattern(
            in: &attributed,
            text: string,
            pattern: #"\*([^*]+)\*"#,
            italic: true,
            markupColor: markupColor
        )

        // Underline: _text_
        hideEmphasisPattern(
            in: &attributed,
            text: string,
            pattern: #"_([^_]+)_"#,
            italic: true,
            markupColor: markupColor
        )
    }

    /// Hide emphasis pattern markers while applying formatting to content
    private func hideEmphasisPattern(
        in attributed: inout AttributedString,
        text: String,
        pattern: String,
        weight: Font.Weight = .regular,
        italic: Bool = false,
        markupColor: Color
    ) {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))

        for match in matches {
            let fullRange = match.range

            // Make the entire range (including markers) formatted
            if let swiftRange = Range(fullRange, in: text) {
                let startOffset = text.distance(from: text.startIndex, to: swiftRange.lowerBound)
                let length = text.distance(from: swiftRange.lowerBound, to: swiftRange.upperBound)
                let start = attributed.index(attributed.startIndex, offsetByCharacters: startOffset)
                let end = attributed.index(start, offsetByCharacters: length)

                if start < end && end <= attributed.endIndex {
                    var fontToApply = font
                    if weight != .regular {
                        fontToApply = fontToApply.weight(weight)
                    }
                    if italic {
                        fontToApply = fontToApply.italic()
                    }

                    // Apply formatting to content
                    if match.numberOfRanges > 1 {
                        let contentRange = match.range(at: 1)
                        if let contentSwiftRange = Range(contentRange, in: text) {
                            let contentStartOffset = text.distance(from: text.startIndex, to: contentSwiftRange.lowerBound)
                            let contentLength = text.distance(from: contentSwiftRange.lowerBound, to: contentSwiftRange.upperBound)
                            let contentStart = attributed.index(attributed.startIndex, offsetByCharacters: contentStartOffset)
                            let contentEnd = attributed.index(contentStart, offsetByCharacters: contentLength)

                            if contentStart < contentEnd && contentEnd <= attributed.endIndex {
                                attributed[contentStart..<contentEnd].font = fontToApply
                            }
                        }
                    }

                    // Make markers very subtle
                    // First few chars (opening markers)
                    let markerLength = (fullRange.length - (match.numberOfRanges > 1 ? match.range(at: 1).length : 0)) / 2
                    if markerLength > 0 {
                        let openMarkerEnd = attributed.index(start, offsetByCharacters: markerLength)
                        if openMarkerEnd <= end {
                            attributed[start..<openMarkerEnd].foregroundColor = markupColor
                        }

                        // Last few chars (closing markers)
                        let closeMarkerStart = attributed.index(end, offsetByCharacters: -markerLength)
                        if closeMarkerStart >= start && closeMarkerStart < end {
                            attributed[closeMarkerStart..<end].foregroundColor = markupColor
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let sampleText = """
    Title: The Great Screenplay
    Author: John Doe

    # ACT ONE

    = This is the beginning of our story

    INT. COFFEE SHOP - DAY

    Sarah sits at a corner table, typing furiously on her laptop.

    SARAH
    (without looking up)
    I can't believe I'm *finally* writing this **amazing** screenplay.

    MIKE
    (approaching)
    Hey, Sarah! How's the writing going?

    > THE END <

    [[This is a private note]]
    """

    return CleanFountainSyntaxHighlighter(
        text: sampleText,
        font: .system(size: 16, design: .serif),
        baseColor: .black
    )
    .padding()
    .background(Color.white)
}
