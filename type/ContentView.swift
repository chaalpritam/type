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
    
    // A4 proportions (width:height ratio of 1:√2 or approximately 1:1.414)
    private let a4AspectRatio: CGFloat = 1 / 1.414
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Find/Replace Bar
                    if showFindReplace {
                        FindReplaceView(isVisible: $showFindReplace, text: $text)
                    }
                    
                    HStack(spacing: 0) {
                        // Editor Panel
                        VStack {
                            // Enhanced Toolbar
                            HStack {
                                Text("Editor")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Statistics
                                HStack(spacing: 16) {
                                    StatisticView(label: "Words", value: "\(wordCount)")
                                    StatisticView(label: "Pages", value: "\(pageCount)")
                                    StatisticView(label: "Chars", value: "\(characterCount)")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                                
                                // Auto-completion toggle
                                Button(action: {
                                    showAutoCompletion.toggle()
                                }) {
                                    Image(systemName: showAutoCompletion ? "textformat.abc" : "textformat.abc.dottedunderline")
                                        .foregroundColor(.primary)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Find/Replace toggle
                                Button(action: {
                                    showFindReplace.toggle()
                                }) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.primary)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Line numbers toggle
                                Button(action: {
                                    showLineNumbers.toggle()
                                }) {
                                    Image(systemName: showLineNumbers ? "list.number" : "list.number.fill")
                                        .foregroundColor(.primary)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Undo/Redo buttons
                                Button(action: {
                                    if let prev = historyManager.undo() {
                                        text = prev
                                        updateStatistics(text: prev)
                                        canUndo = historyManager.canUndo
                                        canRedo = historyManager.canRedo
                                    }
                                }) {
                                    Image(systemName: "arrow.uturn.backward")
                                        .foregroundColor(canUndo ? .primary : .secondary)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(!canUndo)
                                
                                Button(action: {
                                    if let next = historyManager.redo() {
                                        text = next
                                        updateStatistics(text: next)
                                        canUndo = historyManager.canUndo
                                        canRedo = historyManager.canRedo
                                    }
                                }) {
                                    Image(systemName: "arrow.uturn.forward")
                                        .foregroundColor(canRedo ? .primary : .secondary)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(!canRedo)
                                
                                // Help button
                                Button(action: {
                                    showHelp = true
                                }) {
                                    Image(systemName: "questionmark.circle")
                                        .foregroundColor(.primary)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Preview toggle
                                Button(action: {
                                    showPreview.toggle()
                                }) {
                                    Image(systemName: showPreview ? "eye.slash" : "eye")
                                        .foregroundColor(.primary)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            
                            // Enhanced Editor
                            ZStack(alignment: .topLeading) {
                                // Paper background
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
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
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .frame(width: showPreview ? geometry.size.width * 0.5 : geometry.size.width)
                        
                        // Preview Panel
                        if showPreview {
                            VStack {
                                // Toolbar
                                HStack {
                                    Text("Preview")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    // Element count
                                    Text("\(fountainParser.elements.count) elements")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                
                                // Preview content
                                ScreenplayPreview(
                                    elements: fountainParser.elements,
                                    titlePage: fountainParser.titlePage
                                )
                                .background(Color.white)
                                .cornerRadius(2)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            }
                            .frame(width: geometry.size.width * 0.5)
                            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                        }
                    }
                }
            }
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
