import SwiftUI

// MARK: - Minimap View
struct MinimapView: View {
    @ObservedObject var coordinator: EditorCoordinator
    @State private var isVisible: Bool = true
    @State private var scale: CGFloat = 0.1
    @State private var scrollPosition: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Minimap controls
            MinimapControlsView(
                isVisible: $isVisible,
                scale: $scale
            )
            
            // Minimap content
            if isVisible {
                MinimapContentView(
                    text: coordinator.text,
                    scale: scale,
                    scrollPosition: $scrollPosition,
                    onScroll: { position in
                        // Handle minimap scroll
                        scrollToPosition(position)
                    }
                )
            }
        }
        .frame(width: 200)
        .background(Color(.systemGray6))
        .border(Color(.systemGray4), width: 0.5)
    }
    
    private func scrollToPosition(_ position: CGFloat) {
        // Scroll the main editor to the specified position
        // This would need to be implemented with the actual editor scroll
        scrollPosition = position
    }
}

// MARK: - Minimap Controls View
struct MinimapControlsView: View {
    @Binding var isVisible: Bool
    @Binding var scale: CGFloat
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isVisible.toggle()
                }
            }) {
                Image(systemName: isVisible ? "eye.fill" : "eye")
                    .foregroundColor(isVisible ? .blue : .primary)
            }
            .help("Toggle Minimap")
            
            Divider()
            
            // Scale controls
            HStack(spacing: 4) {
                Button("-") {
                    scale = max(0.05, scale - 0.02)
                }
                .buttonStyle(.bordered)
                .disabled(scale <= 0.05)
                
                Text("\(Int(scale * 100))%")
                    .font(.caption)
                    .frame(width: 40)
                
                Button("+") {
                    scale = min(0.3, scale + 0.02)
                }
                .buttonStyle(.bordered)
                .disabled(scale >= 0.3)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray5))
    }
}

// MARK: - Minimap Content View
struct MinimapContentView: View {
    let text: String
    let scale: CGFloat
    @Binding var scrollPosition: CGFloat
    let onScroll: (CGFloat) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Document overview
                MinimapDocumentView(
                    text: text,
                    scale: scale,
                    onScroll: onScroll
                )
            }
        }
        .frame(height: 400)
    }
}

// MARK: - Minimap Document View
struct MinimapDocumentView: View {
    let text: String
    let scale: CGFloat
    let onScroll: (CGFloat) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(getDocumentStructure().enumerated()), id: \.offset) { index, element in
                MinimapElementView(
                    element: element,
                    scale: scale,
                    onTap: {
                        onScroll(CGFloat(index) * 20) // Approximate scroll position
                    }
                )
            }
        }
        .scaleEffect(scale)
    }
    
    private func getDocumentStructure() -> [MinimapElement] {
        let lines = text.components(separatedBy: .newlines)
        var elements: [MinimapElement] = []
        
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.hasPrefix("#") {
                // Section
                elements.append(MinimapElement(
                    type: .section,
                    title: trimmedLine.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespaces),
                    lineNumber: index
                ))
            } else if trimmedLine.range(of: #"^(?:INT|EXT|INT\/EXT|I\/E)\.?\s+.*$"#, options: .regularExpression) != nil {
                // Scene
                elements.append(MinimapElement(
                    type: .scene,
                    title: trimmedLine,
                    lineNumber: index
                ))
            } else if trimmedLine.range(of: #"^[A-Z][A-Z\s]+$"#, options: .regularExpression) != nil {
                // Character
                elements.append(MinimapElement(
                    type: .character,
                    title: trimmedLine,
                    lineNumber: index
                ))
            } else if !trimmedLine.isEmpty {
                // Action/Dialogue
                elements.append(MinimapElement(
                    type: .action,
                    title: String(trimmedLine.prefix(50)),
                    lineNumber: index
                ))
            }
        }
        
        return elements
    }
}

// MARK: - Minimap Element View
struct MinimapElementView: View {
    let element: MinimapElement
    let scale: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            // Element indicator
            Circle()
                .fill(elementColor)
                .frame(width: 6, height: 6)
            
            // Element title
            Text(element.title)
                .font(.system(size: 8, weight: .regular, design: .monospaced))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(elementBackground)
        .cornerRadius(2)
        .onTapGesture {
            onTap()
        }
    }
    
    private var elementColor: Color {
        switch element.type {
        case .section:
            return .blue
        case .scene:
            return .green
        case .character:
            return .purple
        case .action:
            return .gray
        }
    }
    
    private var elementBackground: Color {
        switch element.type {
        case .section:
            return .blue.opacity(0.1)
        case .scene:
            return .green.opacity(0.1)
        case .character:
            return .purple.opacity(0.1)
        case .action:
            return .gray.opacity(0.1)
        }
    }
}

// MARK: - Minimap Element Model
struct MinimapElement {
    let type: MinimapElementType
    let title: String
    let lineNumber: Int
}

// MARK: - Minimap Element Type
enum MinimapElementType {
    case section
    case scene
    case character
    case action
}

// MARK: - Minimap Navigation View
struct MinimapNavigationView: View {
    @ObservedObject var coordinator: EditorCoordinator
    @State private var searchText: String = ""
    @State private var searchResults: [MinimapElement] = []
    
    var body: some View {
        VStack(spacing: 8) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search in document...", text: $searchText)
                    .textFieldStyle(.plain)
                    .onChange(of: searchText) { _, newValue in
                        performSearch(newValue)
                    }
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                        searchResults.removeAll()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.systemGray6))
            .cornerRadius(6)
            
            // Search results
            if !searchResults.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(Array(searchResults.enumerated()), id: \.offset) { index, result in
                            SearchResultRow(
                                result: result,
                                onTap: {
                                    navigateToElement(result)
                                }
                            )
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            
            Spacer()
        }
        .padding(8)
    }
    
    private func performSearch(_ query: String) {
        guard !query.isEmpty else {
            searchResults.removeAll()
            return
        }
        
        let lines = coordinator.text.components(separatedBy: .newlines)
        searchResults.removeAll()
        
        for (index, line) in lines.enumerated() {
            if line.localizedCaseInsensitiveContains(query) {
                let element = MinimapElement(
                    type: determineElementType(line),
                    title: line.trimmingCharacters(in: .whitespaces),
                    lineNumber: index
                )
                searchResults.append(element)
            }
        }
    }
    
    private func determineElementType(_ line: String) -> MinimapElementType {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        
        if trimmedLine.hasPrefix("#") {
            return .section
        } else if trimmedLine.range(of: #"^(?:INT|EXT|INT\/EXT|I\/E)\.?\s+.*$"#, options: .regularExpression) != nil {
            return .scene
        } else if trimmedLine.range(of: #"^[A-Z][A-Z\s]+$"#, options: .regularExpression) != nil {
            return .character
        } else {
            return .action
        }
    }
    
    private func navigateToElement(_ element: MinimapElement) {
        // Navigate to the element in the main editor
        // This would need to be implemented with actual editor navigation
        print("Navigate to line \(element.lineNumber): \(element.title)")
    }
}

// MARK: - Search Result Row
struct SearchResultRow: View {
    let result: MinimapElement
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // Element type indicator
            Circle()
                .fill(elementColor)
                .frame(width: 8, height: 8)
            
            // Element content
            VStack(alignment: .leading, spacing: 2) {
                Text(result.title)
                    .font(.caption)
                    .lineLimit(1)
                
                Text("Line \(result.lineNumber + 1)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(4)
        .onTapGesture {
            onTap()
        }
    }
    
    private var elementColor: Color {
        switch result.type {
        case .section:
            return .blue
        case .scene:
            return .green
        case .character:
            return .purple
        case .action:
            return .gray
        }
    }
}

#Preview {
    let coordinator = EditorCoordinator(documentService: DocumentService())
    
    return MinimapView(coordinator: coordinator)
        .frame(width: 200, height: 500)
        .background(Color.white)
        .padding()
} 