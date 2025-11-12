import SwiftUI
import Combine

// MARK: - Advanced Editor Features Manager
@MainActor
class AdvancedEditorFeatures: ObservableObject {
    // MARK: - Published Properties
    @Published var isFocusMode: Bool = false
    @Published var isTypewriterMode: Bool = false
    @Published var multipleCursors: [TextCursor] = []
    @Published var showWritingStats: Bool = false
    @Published var writingPace: WritingPace = .normal
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var autoScrollTimer: Timer?
    private var lastCursorPosition: Int = 0
    
    // MARK: - Focus Mode
    func toggleFocusMode() {
        isFocusMode.toggle()
        if isFocusMode {
            // Hide all UI elements except editor
            NotificationCenter.default.post(name: .focusModeEnabled, object: nil)
        } else {
            // Restore UI elements
            NotificationCenter.default.post(name: .focusModeDisabled, object: nil)
        }
    }
    
    // MARK: - Typewriter Mode
    func toggleTypewriterMode() {
        isTypewriterMode.toggle()
        if isTypewriterMode {
            startAutoScroll()
        } else {
            stopAutoScroll()
        }
    }
    
    private func startAutoScroll() {
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.performAutoScroll()
        }
    }
    
    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    private func performAutoScroll() {
        // Auto-scroll logic will be implemented in the editor view
        NotificationCenter.default.post(name: .typewriterModeScroll, object: nil)
    }
    
    // MARK: - Multiple Cursors
    func addCursor(at position: Int) {
        let newCursor = TextCursor(position: position, id: UUID())
        multipleCursors.append(newCursor)
    }
    
    func removeCursor(_ cursor: TextCursor) {
        multipleCursors.removeAll { $0.id == cursor.id }
    }
    
    func clearAllCursors() {
        multipleCursors.removeAll()
    }
    
    func updateCursorPosition(_ cursor: TextCursor, to position: Int) {
        if let index = multipleCursors.firstIndex(where: { $0.id == cursor.id }) {
            multipleCursors[index].position = position
        }
    }
    
    // MARK: - Writing Statistics
    func toggleWritingStats() {
        showWritingStats.toggle()
    }
    
    func updateWritingPace(_ pace: WritingPace) {
        writingPace = pace
    }
    
    // MARK: - Cleanup
    deinit {
        autoScrollTimer?.invalidate()
    }
}

// MARK: - Text Cursor Model
struct TextCursor: Identifiable, Equatable {
    let id: UUID
    var position: Int
    var selection: NSRange?
    
    init(position: Int, id: UUID = UUID()) {
        self.id = id
        self.position = position
        self.selection = nil
    }
    
    static func == (lhs: TextCursor, rhs: TextCursor) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Writing Pace
enum WritingPace: String, CaseIterable {
    case slow = "Slow"
    case normal = "Normal"
    case fast = "Fast"
    
    var scrollSpeed: Double {
        switch self {
        case .slow: return 0.5
        case .normal: return 1.0
        case .fast: return 2.0
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let focusModeEnabled = Notification.Name("focusModeEnabled")
    static let focusModeDisabled = Notification.Name("focusModeDisabled")
    static let typewriterModeScroll = Notification.Name("typewriterModeScroll")
}

// MARK: - Focus Mode View
struct FocusModeView: View {
    @ObservedObject var coordinator: EditorCoordinator
    @ObservedObject var advancedFeatures: AdvancedEditorFeatures
    @State private var showMinimalUI: Bool = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            // Editor
            VStack(spacing: 0) {
                // Minimal toolbar (only in focus mode)
                if showMinimalUI {
                    FocusModeToolbar(
                        coordinator: coordinator,
                        advancedFeatures: advancedFeatures
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Main editor
                FocusModeEditor(
                    text: $coordinator.text,
                    coordinator: coordinator,
                    advancedFeatures: advancedFeatures
                )
                
                // Writing statistics overlay
                if advancedFeatures.showWritingStats {
                    WritingStatsOverlay(coordinator: coordinator)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                showMinimalUI.toggle()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .focusModeEnabled)) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                showMinimalUI = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .focusModeDisabled)) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                showMinimalUI = true
            }
        }
    }
}

// MARK: - Focus Mode Toolbar
struct FocusModeToolbar: View {
    @ObservedObject var coordinator: EditorCoordinator
    @ObservedObject var advancedFeatures: AdvancedEditorFeatures
    
    var body: some View {
        HStack(spacing: 16) {
            // Word count
            Text("\(coordinator.wordCount) words")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            // Writing pace
            Picker("Writing Pace", selection: $advancedFeatures.writingPace) {
                ForEach(WritingPace.allCases, id: \.self) { pace in
                    Text(pace.rawValue).tag(pace)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 200)
            
            // Stats toggle
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    advancedFeatures.toggleWritingStats()
                }
            }) {
                Image(systemName: advancedFeatures.showWritingStats ? "chart.bar.fill" : "chart.bar")
                    .foregroundColor(.white)
            }
            
            // Exit focus mode
            Button("Exit Focus") {
                advancedFeatures.toggleFocusMode()
            }
            .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.8))
        .background(.ultraThinMaterial)
    }
}

// MARK: - Focus Mode Editor
struct FocusModeEditor: View {
    @Binding var text: String
    @ObservedObject var coordinator: EditorCoordinator
    @ObservedObject var advancedFeatures: AdvancedEditorFeatures
    @FocusState private var isFocused: Bool
    @State private var scrollProxy: ScrollViewProxy?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Typewriter mode centered text
                    if advancedFeatures.isTypewriterMode {
                        TypewriterModeText(
                            text: $text,
                            coordinator: coordinator,
                            advancedFeatures: advancedFeatures
                        )
                    } else {
                        // Normal editor
                        EnhancedFountainTextEditor(
                            text: $text,
                            placeholder: "Just write...",
                            showLineNumbers: false,
                            onTextChange: { newText in
                                coordinator.updateText(newText)
                            }
                        )
                    }
                }
            }
            .onAppear {
                scrollProxy = proxy
                isFocused = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .typewriterModeScroll)) { _ in
                if advancedFeatures.isTypewriterMode {
                    performTypewriterScroll(proxy: proxy)
                }
            }
        }
    }
    
    private func performTypewriterScroll(proxy: ScrollViewProxy) {
        // Calculate cursor position and scroll to center it
        // This is a simplified implementation
        withAnimation(.easeInOut(duration: 0.3)) {
            // Scroll to keep cursor centered
        }
    }
}

// MARK: - Typewriter Mode Text
struct TypewriterModeText: View {
    @Binding var text: String
    @ObservedObject var coordinator: EditorCoordinator
    @ObservedObject var advancedFeatures: AdvancedEditorFeatures
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Top spacing for centering
            Spacer()
                .frame(height: 200)
            
            // Centered text editor
            TextEditor(text: $text)
                .font(.system(size: 20, weight: .regular, design: .serif))
                .foregroundColor(.white)
                .background(Color.clear)
                .focused($isFocused)
                .scrollContentBackground(.hidden)
                .frame(maxWidth: 600)
                .onChange(of: text) { _, newText in
                    coordinator.updateText(newText)
                }
                .onAppear {
                    isFocused = true
                }
            
            // Bottom spacing for centering
            Spacer()
                .frame(height: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Writing Stats Overlay
struct WritingStatsOverlay: View {
    @ObservedObject var coordinator: EditorCoordinator
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                StatItem(title: "Words", value: "\(coordinator.wordCount)")
                StatItem(title: "Pages", value: "\(coordinator.pageCount)")
                StatItem(title: "Characters", value: "\(coordinator.characterCount)")
            }
            
            // Writing progress (if goals are set)
            if coordinator.wordCount > 0 {
                ProgressView(value: Double(coordinator.wordCount), total: 1000)
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .frame(width: 200)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.8))
        .background(.ultraThinMaterial)
        .cornerRadius(8)
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Multiple Cursors Manager
class MultipleCursorsManager: ObservableObject {
    @Published var cursors: [TextCursor] = []
    
    func addCursor(at position: Int) {
        let cursor = TextCursor(position: position)
        cursors.append(cursor)
    }
    
    func removeCursor(_ cursor: TextCursor) {
        cursors.removeAll { $0.id == cursor.id }
    }
    
    func clearAllCursors() {
        cursors.removeAll()
    }
    
    func updateCursorPosition(_ cursor: TextCursor, to position: Int) {
        if let index = cursors.firstIndex(where: { $0.id == cursor.id }) {
            cursors[index].position = position
        }
    }
}

// MARK: - Multiple Cursors Editor
struct MultipleCursorsEditor: View {
    @Binding var text: String
    @ObservedObject var cursorsManager: MultipleCursorsManager
    @ObservedObject var coordinator: EditorCoordinator
    
    var body: some View {
        ZStack {
            // Base editor
            EnhancedFountainTextEditor(
                text: $text,
                placeholder: "Just write...",
                showLineNumbers: true,
                onTextChange: { newText in
                    coordinator.updateText(newText)
                }
            )
            
            // Cursor overlays
            ForEach(cursorsManager.cursors) { cursor in
                CursorOverlay(cursor: cursor)
            }
        }
    }
}

// MARK: - Cursor Overlay
struct CursorOverlay: View {
    let cursor: TextCursor
    
    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: 2)
            .opacity(0.8)
            // Position would be calculated based on cursor position
    }
}

#Preview {
    let coordinator = EditorCoordinator(documentService: DocumentService())
    let advancedFeatures = AdvancedEditorFeatures()
    
    return FocusModeView(
        coordinator: coordinator,
        advancedFeatures: advancedFeatures
    )
} 