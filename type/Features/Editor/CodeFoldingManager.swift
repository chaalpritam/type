import SwiftUI
import Foundation

// MARK: - Code Folding Manager
@MainActor
class CodeFoldingManager: ObservableObject {
    // MARK: - Published Properties
    @Published var foldedSections: Set<String> = []
    @Published var foldedScenes: Set<String> = []
    @Published var showFoldingControls: Bool = true
    
    // MARK: - Published Properties
    @Published var sectionRanges: [String: NSRange] = [:]
    @Published var sceneRanges: [String: NSRange] = [:]
    
    // MARK: - Public Methods
    
    func toggleSection(_ sectionId: String) {
        if foldedSections.contains(sectionId) {
            foldedSections.remove(sectionId)
        } else {
            foldedSections.insert(sectionId)
        }
    }
    
    func toggleScene(_ sceneId: String) {
        if foldedScenes.contains(sceneId) {
            foldedScenes.remove(sceneId)
        } else {
            foldedScenes.insert(sceneId)
        }
    }
    
    func foldAllSections() {
        foldedSections = Set(sectionRanges.keys)
    }
    
    func unfoldAllSections() {
        foldedSections.removeAll()
    }
    
    func foldAllScenes() {
        foldedScenes = Set(sceneRanges.keys)
    }
    
    func unfoldAllScenes() {
        foldedScenes.removeAll()
    }
    
    func isSectionFolded(_ sectionId: String) -> Bool {
        return foldedSections.contains(sectionId)
    }
    
    func isSceneFolded(_ sceneId: String) -> Bool {
        return foldedScenes.contains(sceneId)
    }
    
    // MARK: - Parsing Methods
    
    func parseFoldingRanges(from text: String) {
        sectionRanges.removeAll()
        sceneRanges.removeAll()
        
        let lines = text.components(separatedBy: .newlines)
        var currentPosition = 0
        
        for (lineIndex, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Parse sections (# Section Name)
            if trimmedLine.hasPrefix("#") {
                let sectionId = "section_\(lineIndex)"
                let range = NSRange(location: currentPosition, length: line.count)
                sectionRanges[sectionId] = range
            }
            
            // Parse scenes (INT./EXT. LOCATION - TIME)
            if trimmedLine.range(of: #"^(?:INT|EXT|INT\/EXT|I\/E)\.?\s+.*$"#, options: .regularExpression) != nil {
                let sceneId = "scene_\(lineIndex)"
                let range = NSRange(location: currentPosition, length: line.count)
                sceneRanges[sceneId] = range
            }
            
            currentPosition += line.count + 1 // +1 for newline
        }
    }
    
    func getFoldedText(from originalText: String) -> String {
        var result = originalText
        let lines = originalText.components(separatedBy: .newlines)
        
        // Process sections
        for (sectionId, range) in sectionRanges {
            if isSectionFolded(sectionId) {
                result = foldRange(in: result, range: range, lines: lines)
            }
        }
        
        // Process scenes
        for (sceneId, range) in sceneRanges {
            if isSceneFolded(sceneId) {
                result = foldRange(in: result, range: range, lines: lines)
            }
        }
        
        return result
    }
    
    private func foldRange(in text: String, range: NSRange, lines: [String]) -> String {
        // Find the end of the section/scene
        let startLine = getLineNumber(from: range.location, lines: lines)
        let endLine = findEndOfSection(startLine: startLine, lines: lines)
        
        if endLine > startLine {
            // Create folded representation
            let foldedText = createFoldedText(startLine: startLine, endLine: endLine, lines: lines)
            
            // Replace the range with folded text
            let startIndex = text.index(text.startIndex, offsetBy: range.location)
            let endIndex = text.index(startIndex, offsetBy: range.length)
            
            return String(text[..<startIndex]) + foldedText + String(text[endIndex...])
        }
        
        return text
    }
    
    private func getLineNumber(from position: Int, lines: [String]) -> Int {
        var currentPosition = 0
        for (index, line) in lines.enumerated() {
            if currentPosition + line.count >= position {
                return index
            }
            currentPosition += line.count + 1
        }
        return 0
    }
    
    private func findEndOfSection(startLine: Int, lines: [String]) -> Int {
        for index in (startLine + 1)..<lines.count {
            let line = lines[index].trimmingCharacters(in: .whitespaces)
            
            // Check for next section or scene
            if line.hasPrefix("#") || line.range(of: #"^(?:INT|EXT|INT\/EXT|I\/E)\.?\s+.*$"#, options: .regularExpression) != nil {
                return index - 1
            }
        }
        return lines.count - 1
    }
    
    private func createFoldedText(startLine: Int, endLine: Int, lines: [String]) -> String {
        let originalLine = lines[startLine]
        let lineCount = endLine - startLine + 1
        
        return "\(originalLine) // ... (\(lineCount) lines folded)"
    }
}

// MARK: - Code Folding View
struct CodeFoldingView: View {
    @ObservedObject var foldingManager: CodeFoldingManager
    @ObservedObject var coordinator: EditorCoordinator
    
    var body: some View {
        VStack(spacing: 0) {
            // Folding controls
            if foldingManager.showFoldingControls {
                FoldingControlsView(foldingManager: foldingManager)
            }
            
            // Folding indicators
            FoldingIndicatorsView(foldingManager: foldingManager, coordinator: coordinator)
        }
    }
}

// MARK: - Folding Controls View
struct FoldingControlsView: View {
    @ObservedObject var foldingManager: CodeFoldingManager
    
    var body: some View {
        HStack(spacing: 8) {
            Button("Fold All Sections") {
                foldingManager.foldAllSections()
            }
            .buttonStyle(.bordered)
            
            Button("Unfold All Sections") {
                foldingManager.unfoldAllSections()
            }
            .buttonStyle(.bordered)
            
            Divider()
            
            Button("Fold All Scenes") {
                foldingManager.foldAllScenes()
            }
            .buttonStyle(.bordered)
            
            Button("Unfold All Scenes") {
                foldingManager.unfoldAllScenes()
            }
            .buttonStyle(.bordered)
            
            Spacer()
            
            Button(action: {
                foldingManager.showFoldingControls.toggle()
            }) {
                Image(systemName: "chevron.up")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .border(Color(.systemGray4), width: 0.5)
    }
}

// MARK: - Folding Indicators View
struct FoldingIndicatorsView: View {
    @ObservedObject var foldingManager: CodeFoldingManager
    @ObservedObject var coordinator: EditorCoordinator
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(foldingManager.sectionRanges.keys.sorted()), id: \.self) { sectionId in
                SectionFoldingIndicator(
                    sectionId: sectionId,
                    foldingManager: foldingManager,
                    coordinator: coordinator
                )
            }
            
            ForEach(Array(foldingManager.sceneRanges.keys.sorted()), id: \.self) { sceneId in
                SceneFoldingIndicator(
                    sceneId: sceneId,
                    foldingManager: foldingManager,
                    coordinator: coordinator
                )
            }
        }
    }
}

// MARK: - Section Folding Indicator
struct SectionFoldingIndicator: View {
    let sectionId: String
    @ObservedObject var foldingManager: CodeFoldingManager
    @ObservedObject var coordinator: EditorCoordinator
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                foldingManager.toggleSection(sectionId)
            }) {
                Image(systemName: foldingManager.isSectionFolded(sectionId) ? "chevron.right" : "chevron.down")
                    .foregroundColor(.blue)
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(.plain)
            
            Text(getSectionTitle())
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if foldingManager.isSectionFolded(sectionId) {
                Text("(folded)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(foldingManager.isSectionFolded(sectionId) ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(4)
    }
    
    private func getSectionTitle() -> String {
        // Extract section title from the text
        // This is a simplified implementation
        return "Section"
    }
}

// MARK: - Scene Folding Indicator
struct SceneFoldingIndicator: View {
    let sceneId: String
    @ObservedObject var foldingManager: CodeFoldingManager
    @ObservedObject var coordinator: EditorCoordinator
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                foldingManager.toggleScene(sceneId)
            }) {
                Image(systemName: foldingManager.isSceneFolded(sceneId) ? "chevron.right" : "chevron.down")
                    .foregroundColor(.green)
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(.plain)
            
            Text(getSceneTitle())
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if foldingManager.isSceneFolded(sceneId) {
                Text("(folded)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(foldingManager.isSceneFolded(sceneId) ? Color.green.opacity(0.1) : Color.clear)
        .cornerRadius(4)
    }
    
    private func getSceneTitle() -> String {
        // Extract scene title from the text
        // This is a simplified implementation
        return "Scene"
    }
}



#Preview {
    let foldingManager = CodeFoldingManager()
    let coordinator = EditorCoordinator(documentService: DocumentService())
    
    return CodeFoldingView(
        foldingManager: foldingManager,
        coordinator: coordinator
    )
    .frame(height: 200)
    .background(Color.white)
    .padding()
} 