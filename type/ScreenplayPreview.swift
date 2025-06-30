import SwiftUI

struct ScreenplayPreview: View {
    let elements: [FountainElement]
    let titlePage: [String: String]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Title Page
                if !titlePage.isEmpty {
                    TitlePageView(titlePage: titlePage)
                        .padding(.bottom, 40)
                }
                
                // Screenplay Content
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(elements) { element in
                        ScreenplayElementView(element: element)
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 40)
        }
        .background(Color.white)
    }
}

struct TitlePageView: View {
    let titlePage: [String: String]
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            if let title = titlePage["Title"] {
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            
            // Author
            if let author = titlePage["Author"] {
                Text("by")
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .foregroundColor(.secondary)
                
                Text(author)
                    .font(.system(size: 18, weight: .medium, design: .serif))
            }
            
            // Other title page elements
            ForEach(Array(titlePage.keys.sorted()), id: \.self) { key in
                if key != "Title" && key != "Author" {
                    VStack(spacing: 4) {
                        Text(key)
                            .font(.system(size: 12, weight: .medium, design: .serif))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Text(titlePage[key] ?? "")
                            .font(.system(size: 14, weight: .regular, design: .serif))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct ScreenplayElementView: View {
    let element: FountainElement
    
    var body: some View {
        switch element.type {
        case .sceneHeading:
            SceneHeadingView(text: element.text)
        case .action:
            ActionView(text: element.text)
        case .character:
            CharacterView(text: element.text)
        case .dialogue:
            DialogueView(text: element.text)
        case .parenthetical:
            ParentheticalView(text: element.text)
        case .transition:
            TransitionView(text: element.text)
        case .section:
            SectionView(text: element.text)
        case .synopsis:
            SynopsisView(text: element.text)
        case .note:
            NoteView(text: element.text)
        case .centered:
            CenteredView(text: element.text)
        case .pageBreak:
            PageBreakView()
        case .titlePage:
            EmptyView()
        }
    }
}

struct SceneHeadingView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .bold, design: .serif))
            .foregroundColor(.black)
            .padding(.top, 20)
            .padding(.bottom, 10)
    }
}

struct ActionView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .regular, design: .serif))
            .foregroundColor(.black)
            .lineLimit(nil)
            .padding(.vertical, 4)
    }
}

struct CharacterView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .bold, design: .serif))
            .foregroundColor(.black)
            .padding(.top, 12)
            .padding(.leading, 40)
    }
}

struct DialogueView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .regular, design: .serif))
            .foregroundColor(.black)
            .padding(.leading, 40)
            .padding(.trailing, 40)
            .padding(.bottom, 8)
    }
}

struct ParentheticalView: View {
    let text: String
    
    var body: some View {
        Text("(\(text))")
            .font(.system(size: 12, weight: .regular, design: .serif))
            .foregroundColor(.black)
            .padding(.leading, 50)
            .padding(.trailing, 50)
            .padding(.bottom, 4)
    }
}

struct TransitionView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .bold, design: .serif))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 20)
            .padding(.bottom, 10)
    }
}

struct SectionView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .bold, design: .serif))
            .foregroundColor(.blue)
            .padding(.top, 16)
            .padding(.bottom, 8)
    }
}

struct SynopsisView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .italic, design: .serif))
            .foregroundColor(.secondary)
            .padding(.vertical, 4)
    }
}

struct NoteView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .regular, design: .monospaced))
            .foregroundColor(.gray)
            .padding(.vertical, 2)
    }
}

struct CenteredView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .regular, design: .serif))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 8)
    }
}

struct PageBreakView: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 1)
            .padding(.vertical, 20)
    }
}

#Preview {
    let sampleElements = [
        FountainElement(type: .sceneHeading, text: "INT. COFFEE SHOP - DAY", originalText: "INT. COFFEE SHOP - DAY", lineNumber: 1),
        FountainElement(type: .action, text: "Sarah sits at a corner table, typing furiously on her laptop. The coffee shop is bustling with activity.", originalText: "Sarah sits at a corner table, typing furiously on her laptop. The coffee shop is bustling with activity.", lineNumber: 2),
        FountainElement(type: .character, text: "SARAH", originalText: "SARAH", lineNumber: 3),
        FountainElement(type: .parenthetical, text: "without looking up", originalText: "(without looking up)", lineNumber: 4),
        FountainElement(type: .dialogue, text: "I can't believe I'm finally writing this screenplay.", originalText: "I can't believe I'm finally writing this screenplay.", lineNumber: 5)
    ]
    
    let sampleTitlePage = [
        "Title": "The Great Screenplay",
        "Author": "John Doe",
        "Draft": "First Draft"
    ]
    
    return ScreenplayPreview(elements: sampleElements, titlePage: sampleTitlePage)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
} 