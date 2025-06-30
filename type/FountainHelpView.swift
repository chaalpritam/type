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
                    
                    // Dialogue
                    SyntaxSection(
                        title: "Dialogue",
                        description: "Write dialogue after character names",
                        examples: [
                            "SARAH",
                            "I can't believe I'm finally writing this screenplay."
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
                    
                    // Transitions
                    SyntaxSection(
                        title: "Transitions",
                        description: "Scene transition instructions",
                        examples: [
                            "FADE OUT",
                            "CUT TO:",
                            "DISSOLVE TO:",
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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