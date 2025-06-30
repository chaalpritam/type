//
//  ContentView.swift
//  type
//
//  Created by Chaal Pritam on 15/04/25.
//

import SwiftUI

struct ContentView: View {
    @State private var text: String = ""
    @State private var showPlaceholder: Bool = true
    @State private var showPreview: Bool = true
    @State private var showHelp: Bool = false
    @State private var showLineNumbers: Bool = true
    @State private var showFindReplace: Bool = false
    @State private var showAutoCompletion: Bool = true
    @FocusState private var isTextFieldFocused: Bool
    @StateObject private var fountainParser = FountainParser()
    @StateObject private var historyManager = TextHistoryManager()
    @StateObject private var autoCompletionManager = AutoCompletionManager()
    @StateObject private var smartFormattingManager = SmartFormattingManager()
    
    // Enhanced editor state
    @State private var wordCount: Int = 0
    @State private var pageCount: Int = 0
    @State private var characterCount: Int = 0
    @State private var canUndo: Bool = false
    @State private var canRedo: Bool = false
    
    // Toolbar states
    @State private var selectedFont: String = "Courier"
    @State private var fontSize: CGFloat = 12
    @State private var showStatistics: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top Toolbar
                TopToolbar(
                    showPreview: $showPreview,
                    showLineNumbers: $showLineNumbers,
                    showFindReplace: $showFindReplace,
                    showHelp: $showHelp,
                    canUndo: canUndo,
                    canRedo: canRedo,
                    onUndo: performUndo,
                    onRedo: performRedo,
                    selectedFont: $selectedFont,
                    fontSize: $fontSize
                )
                
                // Find/Replace Bar
                if showFindReplace {
                    FindReplaceView(isVisible: $showFindReplace, text: $text)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Main Content Area
                HStack(spacing: 0) {
                    // Editor Panel
                    VStack(spacing: 0) {
                        // Editor Header
                        EditorHeader(
                            wordCount: wordCount,
                            pageCount: pageCount,
                            characterCount: characterCount,
                            showStatistics: showStatistics,
                            showAutoCompletion: $showAutoCompletion
                        )
                        
                        // Editor Content
                        ZStack(alignment: .topLeading) {
                            // Paper background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                            // Enhanced Fountain Text Editor
                            EnhancedFountainTextEditor(
                                text: $text,
                                placeholder: "Just write...",
                                showLineNumbers: showLineNumbers,
                                onTextChange: { newText in
                                    updateStatistics(text: newText)
                                    historyManager.addToHistory(newText)
                                    canUndo = historyManager.canUndo
                                    canRedo = historyManager.canRedo
                                    
                                    // Update auto-completion
                                    autoCompletionManager.updateSuggestions(for: newText, at: 0)
                                    
                                    // Apply smart formatting
                                    let formattedText = smartFormattingManager.formatText(newText)
                                    if formattedText != newText {
                                        text = formattedText
                                    }
                                }
                            )
                            .onChange(of: text) { oldValue, newValue in
                                showPlaceholder = newValue.isEmpty
                                // Parse Fountain syntax in real-time
                                fountainParser.parse(newValue)
                                updateStatistics(text: newValue)
                            }
                            
                            // Auto-completion suggestions overlay
                            if showAutoCompletion && autoCompletionManager.showSuggestions {
                                AutoCompletionOverlay(
                                    suggestions: autoCompletionManager.suggestions,
                                    selectedIndex: autoCompletionManager.selectedIndex,
                                    onSelect: { suggestion in
                                        // TODO: Insert suggestion at cursor position
                                        autoCompletionManager.hideSuggestions()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .frame(width: showPreview ? geometry.size.width * 0.5 : geometry.size.width)
                    
                    // Preview Panel
                    if showPreview {
                        VStack(spacing: 0) {
                            // Preview Header
                            PreviewHeader(elementCount: fountainParser.elements.count)
                            
                            // Preview content
                            ScreenplayPreview(
                                elements: fountainParser.elements,
                                titlePage: fountainParser.titlePage
                            )
                            .background(Color.white)
                            .cornerRadius(4)
                            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                        .frame(width: geometry.size.width * 0.5)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.98))
                    }
                }
                
                // Bottom Status Bar
                BottomStatusBar(
                    wordCount: wordCount,
                    pageCount: pageCount,
                    characterCount: characterCount,
                    showStatistics: $showStatistics,
                    smartFormattingManager: smartFormattingManager
                )
            }
            .background(Color(red: 0.94, green: 0.94, blue: 0.96))
            .onAppear {
                isTextFieldFocused = true
                
                // Load sample Fountain content
                text = """
                Title: The Great Screenplay
                Author: John Doe
                Draft: First Draft
                :

                # ACT ONE

                = This is the beginning of our story

                INT. COFFEE SHOP - DAY

                Sarah sits at a corner table, typing furiously on her laptop. The coffee shop is bustling with activity.

                SARAH
                (without looking up)
                I can't believe I'm finally writing this screenplay.

                She takes a sip of her coffee and continues typing.

                MIKE
                (approaching)
                Hey, Sarah! How's the writing going?

                SARAH
                (looking up, surprised)
                Mike! I didn't expect to see you here.

                > THE END <
                """
                
                updateStatistics(text: text)
                historyManager.addToHistory(text)
                canUndo = historyManager.canUndo
                canRedo = historyManager.canRedo
            }
            .sheet(isPresented: $showHelp) {
                FountainHelpView(isPresented: $showHelp)
            }
        }
    }
    
    private func performUndo() {
        if let prev = historyManager.undo() {
            text = prev
            updateStatistics(text: prev)
            canUndo = historyManager.canUndo
            canRedo = historyManager.canRedo
        }
    }
    
    private func performRedo() {
        if let next = historyManager.redo() {
            text = next
            updateStatistics(text: next)
            canUndo = historyManager.canUndo
            canRedo = historyManager.canRedo
        }
    }
    
    private func updateStatistics(text: String) {
        // Word count (excluding Fountain syntax elements)
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty && !$0.hasPrefix("#") && !$0.hasPrefix("=") && !$0.hasPrefix("[[") && !$0.hasPrefix(">") }
        wordCount = words.count
        
        // Character count (excluding whitespace)
        characterCount = text.replacingOccurrences(of: "\\s", with: "", options: .regularExpression).count
        
        // Page count (rough estimate: ~55 lines per page for screenplay format)
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
        pageCount = max(1, (lines.count / 55) + 1)
    }
}

// MARK: - Top Toolbar
struct TopToolbar: View {
    @Binding var showPreview: Bool
    @Binding var showLineNumbers: Bool
    @Binding var showFindReplace: Bool
    @Binding var showHelp: Bool
    let canUndo: Bool
    let canRedo: Bool
    let onUndo: () -> Void
    let onRedo: () -> Void
    @Binding var selectedFont: String
    @Binding var fontSize: CGFloat
    
    var body: some View {
        HStack(spacing: 16) {
            // File Operations
            HStack(spacing: 8) {
                Button(action: {}) {
                    Image(systemName: "doc.badge.plus")
                    Text("New")
                }
                .buttonStyle(ToolbarButtonStyle())
                
                Button(action: {}) {
                    Image(systemName: "folder")
                    Text("Open")
                }
                .buttonStyle(ToolbarButtonStyle())
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save")
                }
                .buttonStyle(ToolbarButtonStyle())
            }
            
            Divider()
                .frame(height: 20)
            
            // Edit Operations
            HStack(spacing: 8) {
                Button(action: onUndo) {
                    Image(systemName: "arrow.uturn.backward")
                }
                .buttonStyle(ToolbarButtonStyle())
                .disabled(!canUndo)
                
                Button(action: onRedo) {
                    Image(systemName: "arrow.uturn.forward")
                }
                .buttonStyle(ToolbarButtonStyle())
                .disabled(!canRedo)
                
                Button(action: { showFindReplace.toggle() }) {
                    Image(systemName: "magnifyingglass")
                }
                .buttonStyle(ToolbarButtonStyle())
            }
            
            Divider()
                .frame(height: 20)
            
            // Formatting Options
            HStack(spacing: 8) {
                Picker("Font", selection: $selectedFont) {
                    Text("Courier").tag("Courier")
                    Text("Courier New").tag("Courier New")
                    Text("Monaco").tag("Monaco")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 120)
                
                HStack(spacing: 4) {
                    Button(action: { fontSize = max(8, fontSize - 1) }) {
                        Image(systemName: "textformat.size.smaller")
                    }
                    .buttonStyle(ToolbarButtonStyle())
                    
                    Text("\(Int(fontSize))")
                        .font(.caption)
                        .frame(width: 30)
                    
                    Button(action: { fontSize = min(24, fontSize + 1) }) {
                        Image(systemName: "textformat.size.larger")
                    }
                    .buttonStyle(ToolbarButtonStyle())
                }
            }
            
            Spacer()
            
            // View Controls
            HStack(spacing: 8) {
                Button(action: { showLineNumbers.toggle() }) {
                    Image(systemName: showLineNumbers ? "list.number" : "list.number.fill")
                }
                .buttonStyle(ToolbarButtonStyle())
                
                Button(action: { showHelp = true }) {
                    Image(systemName: "questionmark.circle")
                }
                .buttonStyle(ToolbarButtonStyle())
                
                Button(action: { showPreview.toggle() }) {
                    Image(systemName: showPreview ? "eye.slash" : "eye")
                }
                .buttonStyle(ToolbarButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separatorColor)),
            alignment: .bottom
        )
    }
}

// MARK: - Editor Header
struct EditorHeader: View {
    let wordCount: Int
    let pageCount: Int
    let characterCount: Int
    let showStatistics: Bool
    @Binding var showAutoCompletion: Bool
    
    var body: some View {
        HStack {
            Text("Editor")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            if showStatistics {
                HStack(spacing: 16) {
                    StatisticView(label: "Words", value: "\(wordCount)")
                    StatisticView(label: "Pages", value: "\(pageCount)")
                    StatisticView(label: "Chars", value: "\(characterCount)")
                }
            }
            
            Button(action: { showAutoCompletion.toggle() }) {
                Image(systemName: showAutoCompletion ? "textformat.abc" : "textformat.abc.dottedunderline")
                    .foregroundColor(.primary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.controlBackgroundColor))
    }
}

// MARK: - Preview Header
struct PreviewHeader: View {
    let elementCount: Int
    
    var body: some View {
        HStack {
            Text("Preview")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(elementCount) elements")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.controlBackgroundColor))
    }
}

// MARK: - Bottom Status Bar
struct BottomStatusBar: View {
    let wordCount: Int
    let pageCount: Int
    let characterCount: Int
    @Binding var showStatistics: Bool
    let smartFormattingManager: SmartFormattingManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Smart formatting status
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .foregroundColor(.blue)
                Text("Smart formatting enabled")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Center - Statistics toggle
            Button(action: { showStatistics.toggle() }) {
                HStack(spacing: 4) {
                    Image(systemName: showStatistics ? "chart.bar" : "chart.bar.fill")
                    Text("Stats")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Right side - Additional info
            HStack(spacing: 16) {
                Text("Fountain Format")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Ready")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(Color(.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separatorColor)),
            alignment: .top
        )
    }
}

// MARK: - Toolbar Button Style
struct ToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .foregroundColor(configuration.isPressed ? .secondary : .primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(configuration.isPressed ? Color(.controlColor) : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Supporting Views
struct AutoCompletionOverlay: View {
    let suggestions: [String]
    let selectedIndex: Int
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(suggestions.enumerated()), id: \.offset) { index, suggestion in
                Button(action: {
                    onSelect(suggestion)
                }) {
                    Text(suggestion)
                        .font(.system(size: 14))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(index == selectedIndex ? Color.blue.opacity(0.2) : Color.clear)
                }
                .buttonStyle(PlainButtonStyle())
                
                if index < suggestions.count - 1 {
                    Divider()
                }
            }
        }
        .background(Color(.windowBackgroundColor))
        .cornerRadius(6)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .frame(maxWidth: 300)
        .offset(y: 30)
    }
}

struct StatisticView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
