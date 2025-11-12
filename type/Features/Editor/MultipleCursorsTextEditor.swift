import SwiftUI
import AppKit

// MARK: - Multiple Cursors Text Editor
struct MultipleCursorsTextEditor: View {
    @Binding var text: String
    @ObservedObject var coordinator: EditorCoordinator
    @ObservedObject var cursorsManager: MultipleCursorsManager
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            // Base editor with syntax highlighting
            EnhancedFountainTextEditor(
                text: $text,
                placeholder: "Just write...",
                showLineNumbers: coordinator.showLineNumbers,
                onTextChange: { newText in
                    coordinator.updateText(newText)
                }
            )
            
            // Multiple cursors overlay
            if !cursorsManager.cursors.isEmpty {
                MultipleCursorsOverlay(
                    text: text,
                    cursors: cursorsManager.cursors,
                    onCursorUpdate: { cursor, newPosition in
                        cursorsManager.updateCursorPosition(cursor, to: newPosition)
                    }
                )
            }
        }
    }
    
    private func addCursorAtCurrentPosition() {
        // This would need to get the current cursor position from the text editor
        // For now, we'll add a cursor at a calculated position
        let estimatedPosition = text.count / 2
        cursorsManager.addCursor(at: estimatedPosition)
    }
    
    private func selectNextOccurrence() {
        // Find next occurrence of selected text
        // This is a simplified implementation
        if let selectedText = getSelectedText(), !selectedText.isEmpty {
            if let nextRange = findNextOccurrence(of: selectedText) {
                cursorsManager.addCursor(at: nextRange.location)
            }
        }
    }
    
    private func addCursorAbove() {
        // Add cursor on the line above
        // This is a simplified implementation
        let currentPosition = getCurrentCursorPosition()
        if let abovePosition = getPositionAbove(currentPosition) {
            cursorsManager.addCursor(at: abovePosition)
        }
    }
    
    private func addCursorBelow() {
        // Add cursor on the line below
        // This is a simplified implementation
        let currentPosition = getCurrentCursorPosition()
        if let belowPosition = getPositionBelow(currentPosition) {
            cursorsManager.addCursor(at: belowPosition)
        }
    }
    
    // MARK: - Helper Methods (Simplified implementations)
    
    private func getSelectedText() -> String? {
        // This would need to access the actual text selection
        // For now, return nil
        return nil
    }
    
    private func findNextOccurrence(of text: String) -> NSRange? {
        // This would search for the next occurrence
        // For now, return nil
        return nil
    }
    
    private func getCurrentCursorPosition() -> Int {
        // This would get the actual cursor position
        // For now, return a default value
        return text.count / 2
    }
    
    private func getPositionAbove(_ position: Int) -> Int? {
        // Calculate position on the line above
        let lines = text.components(separatedBy: .newlines)
        var currentLine = 0
        var currentPosition = 0
        
        for (lineIndex, line) in lines.enumerated() {
            if currentPosition + line.count >= position {
                if lineIndex > 0 {
                    let targetLine = lines[lineIndex - 1]
                    let column = position - currentPosition
                    return currentPosition - line.count - 1 + min(column, targetLine.count)
                }
                break
            }
            currentPosition += line.count + 1 // +1 for newline
            currentLine = lineIndex
        }
        
        return nil
    }
    
    private func getPositionBelow(_ position: Int) -> Int? {
        // Calculate position on the line below
        let lines = text.components(separatedBy: .newlines)
        var currentPosition = 0
        
        for (lineIndex, line) in lines.enumerated() {
            if currentPosition + line.count >= position {
                if lineIndex + 1 < lines.count {
                    let targetLine = lines[lineIndex + 1]
                    let column = position - currentPosition
                    return currentPosition + line.count + 1 + min(column, targetLine.count)
                }
                break
            }
            currentPosition += line.count + 1 // +1 for newline
        }
        
        return nil
    }
}

// MARK: - Multiple Cursors Overlay
struct MultipleCursorsOverlay: View {
    let text: String
    let cursors: [TextCursor]
    let onCursorUpdate: (TextCursor, Int) -> Void
    
    var body: some View {
        ZStack {
            ForEach(cursors) { cursor in
                CursorIndicator(
                    cursor: cursor,
                    text: text,
                    onUpdate: { newPosition in
                        onCursorUpdate(cursor, newPosition)
                    }
                )
            }
        }
        .allowsHitTesting(false) // Don't interfere with text input
    }
}

// MARK: - Cursor Indicator
struct CursorIndicator: View {
    let cursor: TextCursor
    let text: String
    let onUpdate: (Int) -> Void
    
    @State private var position: CGPoint = .zero
    
    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: 2, height: 20)
            .position(position)
            .opacity(0.8)
            .onAppear {
                updatePosition()
            }
            .onChange(of: cursor.position) { _, _ in
                updatePosition()
            }
    }
    
    private func updatePosition() {
        // Calculate position based on cursor position in text
        // This is a simplified implementation
        let estimatedPosition = calculatePositionFromTextIndex(cursor.position)
        position = estimatedPosition
    }
    
    private func calculatePositionFromTextIndex(_ index: Int) -> CGPoint {
        // This is a simplified calculation
        // In a real implementation, you'd need to:
        // 1. Calculate the line number
        // 2. Calculate the character position within that line
        // 3. Convert to screen coordinates
        
        let lines = text.components(separatedBy: .newlines)
        var currentIndex = 0
        var lineNumber = 0
        
        for line in lines {
            if currentIndex + line.count >= index {
                let column = index - currentIndex
                return CGPoint(
                    x: CGFloat(column) * 10 + 50, // Approximate character width
                    y: CGFloat(lineNumber) * 22 + 40 // Approximate line height
                )
            }
            currentIndex += line.count + 1
            lineNumber += 1
        }
        
        return CGPoint(x: 50, y: 40)
    }
}

// MARK: - Multiple Cursors Manager Extension
extension MultipleCursorsManager {
    func addCursorAtSelection() {
        // Add cursor at the current text selection
        // This would need to access the actual text selection
        let estimatedPosition = 0
        addCursor(at: estimatedPosition)
    }
    
    func moveCursor(_ cursor: TextCursor, by offset: Int) {
        let newPosition = max(0, cursor.position + offset)
        updateCursorPosition(cursor, to: newPosition)
    }
    
    func selectAllOccurrences(of text: String) {
        // Find all occurrences of the given text and add cursors
        let searchText = text.lowercased()
        let documentText = "" // This would be the actual document text
        
        var searchRange = documentText.startIndex..<documentText.endIndex
        while let range = documentText.range(of: searchText, range: searchRange) {
            let position = documentText.distance(from: documentText.startIndex, to: range.lowerBound)
            addCursor(at: position)
            searchRange = range.upperBound..<documentText.endIndex
        }
    }
}

#Preview {
    let coordinator = EditorCoordinator(documentService: DocumentService())
    let cursorsManager = MultipleCursorsManager()
    
    return MultipleCursorsTextEditor(
        text: .constant("INT. COFFEE SHOP - DAY\n\nSARAH\n(typing)\nHello world!"),
        coordinator: coordinator,
        cursorsManager: cursorsManager
    )
    .frame(height: 300)
    .background(Color.white)
    .padding()
} 