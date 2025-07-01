import SwiftUI

struct FountainHelpView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title
                    Text("Fountain Syntax Guide")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                    
                    // Title Page
                    SyntaxSection(
                        title: "Title Page",
                        description: "Add metadata at the top of your screenplay",
                        examples: [
                            "Title: Your Screenplay Title",
                            "Author: Your Name",
                            "Draft: First Draft",
                            ":"
                        ]
                    )
                    
                    // Scene Headings
                    SyntaxSection(
                        title: "Scene Headings",
                        description: "Define locations and times",
                        examples: [
                            "INT. COFFEE SHOP - DAY",
                            "EXT. PARK - NIGHT",
                            "INT./EXT. CAR - DAY"
                        ]
                    )
                    
                    // Force Elements
                    SyntaxSection(
                        title: "Force Elements",
                        description: "Override automatic formatting",
                        examples: [
                            "!INT. COFFEE SHOP - DAY (force scene heading)",
                            "@This is forced action text",
                            "!This forces a scene heading even if it doesn't match the pattern"
                        ]
                    )
                    
                    // Action
                    SyntaxSection(
                        title: "Action",
                        description: "Describe what happens on screen",
                        examples: [
                            "Sarah sits at a corner table, typing furiously on her laptop.",
                            "The coffee shop is bustling with activity."
                        ]
                    )
                    
                    // Character Names
                    SyntaxSection(
                        title: "Character Names",
                        description: "Write character names in ALL CAPS",
                        examples: [
                            "SARAH",
                            "MIKE",
                            "JOHN DOE"
                        ]
                    )
                    
                    // Dual Dialogue
                    SyntaxSection(
                        title: "Dual Dialogue",
                        description: "Two characters speaking simultaneously",
                        examples: [
                            "SARAH",
                            "I can't believe this!",
                            "MIKE^",
                            "Me neither!"
                        ]
                    )
                    
                    // Dialogue
                    SyntaxSection(
                        title: "Dialogue",
                        description: "Write dialogue after character names",
                        examples: [
                            "SARAH",
                            "I can't believe I'm finally writing this screenplay."
                        ]
                    )
                    
                    // Emphasis
                    SyntaxSection(
                        title: "Emphasis",
                        description: "Add emphasis to dialogue",
                        examples: [
                            "*This is bold text*",
                            "_This is italic text_",
                            "**This is bold italic text**",
                            "__This is also bold italic__"
                        ]
                    )
                    
                    // Parentheticals
                    SyntaxSection(
                        title: "Parentheticals",
                        description: "Add character direction in parentheses",
                        examples: [
                            "(without looking up)",
                            "(approaching)",
                            "(looking up, surprised)"
                        ]
                    )
                    
                    // Lyrics
                    SyntaxSection(
                        title: "Lyrics",
                        description: "Add song lyrics to your screenplay",
                        examples: [
                            "~La la la, singing a song~",
                            "~Happy birthday to you~"
                        ]
                    )
                    
                    // Transitions
                    SyntaxSection(
                        title: "Transitions",
                        description: "Scene transition instructions",
                        examples: [
                            "FADE OUT",
                            "CUT TO:",
                            "DISSOLVE TO:",
                            "SMASH CUT TO:",
                            "JUMP CUT TO:",
                            "IRIS IN",
                            "WIPE TO:",
                            "THE END"
                        ]
                    )
                    
                    // Sections
                    SyntaxSection(
                        title: "Sections",
                        description: "Organize your screenplay with sections",
                        examples: [
                            "# ACT ONE",
                            "## Scene 1",
                            "### Subsection"
                        ]
                    )
                    
                    // Synopsis
                    SyntaxSection(
                        title: "Synopsis",
                        description: "Add synopsis text (not shown in final screenplay)",
                        examples: [
                            "= This is the beginning of our story"
                        ]
                    )
                    
                    // Notes
                    SyntaxSection(
                        title: "Notes",
                        description: "Add private notes (not shown in final screenplay)",
                        examples: [
                            "[[This is a private note]]"
                        ]
                    )
                    
                    // Centered Text
                    SyntaxSection(
                        title: "Centered Text",
                        description: "Center text on the page",
                        examples: [
                            "> THE END <"
                        ]
                    )
                    
                    // Page Breaks
                    SyntaxSection(
                        title: "Page Breaks",
                        description: "Force a page break",
                        examples: [
                            "==="
                        ]
                    )
                }
                .padding()
            }
            .navigationTitle("Fountain Help")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct SyntaxSection: View {
    let title: String
    let description: String
    let examples: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(examples, id: \.self) { example in
                    Text(example)
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }
            }
        }
    }
}

#Preview {
    FountainHelpView(isPresented: .constant(true))
} 