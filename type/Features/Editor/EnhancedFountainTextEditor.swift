import SwiftUI

struct EnhancedFountainTextEditor: View {
    @Binding var text: String
    let placeholder: String
    let showLineNumbers: Bool
    var hideMarkup: Bool = false  // Use clean view mode
    let onTextChange: (String) -> Void

    @FocusState private var isFocused: Bool
    @State private var lineCount: Int = 1

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Line numbers
            if showLineNumbers {
                LineNumbersView(lineCount: lineCount)
                    .frame(width: 50)
            }

            // Main editor
            ZStack(alignment: .topLeading) {
                // Background TextEditor for input - NO line spacing to keep cursor aligned
                TextEditor(text: $text)
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .foregroundColor(.clear) // Make text invisible
                    .background(Color.clear)
                    .focused($isFocused)
                    .scrollContentBackground(.hidden)
                    .padding(EdgeInsets(top: text.isEmpty ? 10 : 40, leading: showLineNumbers ? 10 : 40, bottom: 40, trailing: 40))
                    .onChange(of: text) { _, newText in
                        updateLineCount(text: newText)
                        onTextChange(newText)
                    }
                    .onAppear {
                        // Auto-focus the editor when it appears
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isFocused = true
                        }
                    }

                // Syntax highlighted overlay - choose between normal and clean mode
                if hideMarkup {
                    CleanFountainSyntaxHighlighter(
                        text: text.isEmpty ? placeholder : text,
                        font: .system(size: 18, weight: .regular, design: .serif),
                        baseColor: text.isEmpty ? Color(red: 0.5, green: 0.5, blue: 0.5) : .black
                    )
                    .padding(EdgeInsets(top: text.isEmpty ? 10 : 40, leading: showLineNumbers ? 10 : 40, bottom: 40, trailing: 40))
                    .allowsHitTesting(false) // Don't interfere with text input
                } else {
                    FountainSyntaxHighlighter(
                        text: text.isEmpty ? placeholder : text,
                        font: .system(size: 18, weight: .regular, design: .serif),
                        baseColor: text.isEmpty ? Color(red: 0.5, green: 0.5, blue: 0.5) : .black
                    )
                    .padding(EdgeInsets(top: text.isEmpty ? 10 : 40, leading: showLineNumbers ? 10 : 40, bottom: 40, trailing: 40))
                    .allowsHitTesting(false) // Don't interfere with text input
                }
            }
        }
        .background(ScreenplayPaperBackground()) // Background behind everything
        .onAppear {
            updateLineCount(text: text)
        }
    }
    
    private func updateLineCount(text: String) {
        let lines = text.components(separatedBy: .newlines)
        lineCount = max(1, lines.count)
    }
}

struct LineNumbersView: View {
    let lineCount: Int
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(1...lineCount, id: \.self) { lineNumber in
                Text("\(lineNumber)")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(height: 22, alignment: .trailing)
                    .padding(.trailing, 8)
            }
        }
        .padding(.top, 40) // Match the editor's top padding
        .padding(.bottom, 40) // Match the editor's bottom padding
    }
}

#Preview {
    EnhancedFountainTextEditor(
        text: .constant("INT. COFFEE SHOP - DAY\n\nSARAH\n(typing)\nHello world!"),
        placeholder: "Just write...",
        showLineNumbers: true,
        onTextChange: { _ in }
    )
    .frame(height: 300)
    .background(Color.white)
    .padding()
} 