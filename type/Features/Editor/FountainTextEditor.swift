import SwiftUI

struct FountainTextEditor: View {
    @Binding var text: String
    let placeholder: String
    var hideMarkup: Bool = false  // Use clean view mode
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Paper texture background
            ScreenplayPaperBackground()

            // Background TextEditor for input with line spacing
            TextEditor(text: $text)
                .font(ScreenplayTypography.editorFont())
                .foregroundColor(.clear) // Make text invisible
                .background(Color.clear)
                .focused($isFocused)
                .scrollContentBackground(.hidden)
                .lineSpacing(ScreenplayTypography.standardLineSpacing)
                .padding(EdgeInsets(top: text.isEmpty ? 10 : 40, leading: 40, bottom: 40, trailing: 40))

            // Syntax highlighted overlay - choose between normal and clean mode
            if hideMarkup {
                CleanFountainSyntaxHighlighter(
                    text: text.isEmpty ? placeholder : text,
                    font: ScreenplayTypography.editorFont(),
                    baseColor: text.isEmpty ? Color(red: 0.5, green: 0.5, blue: 0.5) : .black
                )
                .padding(EdgeInsets(top: text.isEmpty ? 10 : 40, leading: 40, bottom: 40, trailing: 40))
                .allowsHitTesting(false) // Don't interfere with text input
            } else {
                FountainSyntaxHighlighter(
                    text: text.isEmpty ? placeholder : text,
                    font: ScreenplayTypography.editorFont(),
                    baseColor: text.isEmpty ? Color(red: 0.5, green: 0.5, blue: 0.5) : .black
                )
                .padding(EdgeInsets(top: text.isEmpty ? 10 : 40, leading: 40, bottom: 40, trailing: 40))
                .allowsHitTesting(false) // Don't interfere with text input
            }
        }
    }
}

#Preview {
    FountainTextEditor(
        text: .constant("INT. COFFEE SHOP - DAY\n\nSARAH\n(typing)\nHello world!"),
        placeholder: "Just write..."
    )
    .frame(height: 300)
    .background(Color.white)
    .padding()
} 