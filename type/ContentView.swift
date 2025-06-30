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
    
    // Apple-style interface states
    @State private var selectedFont: String = "SF Mono"
    @State private var fontSize: CGFloat = 13
    @State private var showStatistics: Bool = true
    @State private var isFullScreen: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Apple-style background
                Color(.windowBackgroundColor)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Apple-style toolbar
                    AppleToolbar(
                        showPreview: $showPreview,
                        showLineNumbers: $showLineNumbers,
                        showFindReplace: $showFindReplace,
                        showHelp: $showHelp,
                        canUndo: canUndo,
                        canRedo: canRedo,
                        onUndo: performUndo,
                        onRedo: performRedo,
                        selectedFont: $selectedFont,
                        fontSize: $fontSize,
                        isFullScreen: $isFullScreen
                    )
                    
                    // Find/Replace Bar with Apple styling
                    if showFindReplace {
                        AppleFindReplaceView(isVisible: $showFindReplace, text: $text)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    }
                    
                    // Main Content Area
                    HStack(spacing: 0) {
                        // Editor Panel
                        VStack(spacing: 0) {
                            // Apple-style editor header
                            AppleEditorHeader(
                                wordCount: wordCount,
                                pageCount: pageCount,
                                characterCount: characterCount,
                                showStatistics: showStatistics,
                                showAutoCompletion: $showAutoCompletion
                            )
                            
                            // Apple-style editor content
                            ZStack(alignment: .topLeading) {
                                // Apple-style paper background
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.textBackgroundColor))
                                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                                // Enhanced Fountain Text Editor
                                EnhancedFountainTextEditor(
                                    text: $text,
                                    placeholder: "Start writing your screenplay...",
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
                                
                                // Apple-style auto-completion overlay
                                if showAutoCompletion && autoCompletionManager.showSuggestions {
                                    AppleAutoCompletionOverlay(
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
                            VStack(spacing: 0) {
                                // Apple-style preview header
                                ApplePreviewHeader(elementCount: fountainParser.elements.count)
                                
                                // Apple-style preview content
                                ScreenplayPreview(
                                    elements: fountainParser.elements,
                                    titlePage: fountainParser.titlePage
                                )
                                .background(Color(.textBackgroundColor))
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            }
                            .frame(width: geometry.size.width * 0.5)
                            .background(Color(.windowBackgroundColor))
                        }
                    }
                    
                    // Apple-style status bar
                    AppleStatusBar(
                        wordCount: wordCount,
                        pageCount: pageCount,
                        characterCount: characterCount,
                        showStatistics: $showStatistics,
                        smartFormattingManager: smartFormattingManager
                    )
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

// MARK: - Apple-style Toolbar
struct AppleToolbar: View {
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
    @Binding var isFullScreen: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // File operations with Apple styling
            HStack(spacing: 6) {
                AppleToolbarButton(
                    icon: "doc.badge.plus",
                    label: "New",
                    action: {}
                )
                
                AppleToolbarButton(
                    icon: "folder",
                    label: "Open",
                    action: {}
                )
                
                AppleToolbarButton(
                    icon: "square.and.arrow.down",
                    label: "Save",
                    action: {}
                )
            }
            
            AppleDivider()
            
            // Edit operations
            HStack(spacing: 6) {
                AppleToolbarButton(
                    icon: "arrow.uturn.backward",
                    action: onUndo
                )
                .disabled(!canUndo)
                
                AppleToolbarButton(
                    icon: "arrow.uturn.forward",
                    action: onRedo
                )
                .disabled(!canRedo)
                
                AppleToolbarButton(
                    icon: "magnifyingglass",
                    action: { showFindReplace.toggle() }
                )
            }
            
            AppleDivider()
            
            // Formatting options with Apple styling
            HStack(spacing: 8) {
                Picker("Font", selection: $selectedFont) {
                    Text("SF Mono").tag("SF Mono")
                    Text("Menlo").tag("Menlo")
                    Text("Monaco").tag("Monaco")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
                
                HStack(spacing: 4) {
                    AppleToolbarButton(
                        icon: "textformat.size.smaller",
                        action: { fontSize = max(10, fontSize - 1) }
                    )
                    
                    Text("\(Int(fontSize))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 25)
                    
                    AppleToolbarButton(
                        icon: "textformat.size.larger",
                        action: { fontSize = min(20, fontSize + 1) }
                    )
                }
            }
            
            Spacer()
            
            // View controls
            HStack(spacing: 6) {
                AppleToolbarButton(
                    icon: showLineNumbers ? "list.number" : "list.number.fill",
                    action: { showLineNumbers.toggle() }
                )
                
                AppleToolbarButton(
                    icon: "questionmark.circle",
                    action: { showHelp = true }
                )
                
                AppleToolbarButton(
                    icon: showPreview ? "eye.slash" : "eye",
                    action: { showPreview.toggle() }
                )
                
                AppleToolbarButton(
                    icon: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right",
                    action: { isFullScreen.toggle() }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separatorColor)),
            alignment: .bottom
        )
    }
}

// MARK: - Apple-style Components
struct AppleToolbarButton: View {
    let icon: String
    var label: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                if let label = label {
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                }
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(AppleButtonStyle())
    }
}

struct AppleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(configuration.isPressed ? Color(.controlColor) : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AppleDivider: View {
    var body: some View {
        Rectangle()
            .frame(width: 1, height: 16)
            .foregroundColor(Color(.separatorColor))
    }
}

// MARK: - Apple-style Editor Header
struct AppleEditorHeader: View {
    let wordCount: Int
    let pageCount: Int
    let characterCount: Int
    let showStatistics: Bool
    @Binding var showAutoCompletion: Bool
    
    var body: some View {
        HStack {
            Text("Editor")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            if showStatistics {
                HStack(spacing: 16) {
                    AppleStatisticView(label: "Words", value: "\(wordCount)")
                    AppleStatisticView(label: "Pages", value: "\(pageCount)")
                    AppleStatisticView(label: "Chars", value: "\(characterCount)")
                }
            }
            
            Button(action: { showAutoCompletion.toggle() }) {
                Image(systemName: showAutoCompletion ? "textformat.abc" : "textformat.abc.dottedunderline")
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
            }
            .buttonStyle(AppleButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Apple-style Preview Header
struct ApplePreviewHeader: View {
    let elementCount: Int
    
    var body: some View {
        HStack {
            Text("Preview")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(elementCount) elements")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Apple-style Status Bar
struct AppleStatusBar: View {
    let wordCount: Int
    let pageCount: Int
    let characterCount: Int
    @Binding var showStatistics: Bool
    let smartFormattingManager: SmartFormattingManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Smart formatting status
            HStack(spacing: 6) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 11))
                    .foregroundColor(.blue)
                Text("Smart formatting enabled")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Center - Statistics toggle
            Button(action: { showStatistics.toggle() }) {
                HStack(spacing: 4) {
                    Image(systemName: showStatistics ? "chart.bar" : "chart.bar.fill")
                        .font(.system(size: 11))
                    Text("Stats")
                        .font(.system(size: 11))
                }
                .foregroundColor(.secondary)
            }
            .buttonStyle(AppleButtonStyle())
            
            // Right side - Additional info
            HStack(spacing: 16) {
                Text("Fountain Format")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Ready")
                        .font(.system(size: 11))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separatorColor)),
            alignment: .top
        )
    }
}

// MARK: - Apple-style Supporting Views
struct AppleAutoCompletionOverlay: View {
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
                        .font(.system(size: 13))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(index == selectedIndex ? Color(.controlColor) : Color.clear)
                }
                .buttonStyle(PlainButtonStyle())
                
                if index < suggestions.count - 1 {
                    Divider()
                        .padding(.horizontal, 12)
                }
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .frame(maxWidth: 300)
        .offset(y: 30)
    }
}

struct AppleStatisticView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 12, weight: .semibold))
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Apple-style Find/Replace View
struct AppleFindReplaceView: View {
    @Binding var isVisible: Bool
    @Binding var text: String
    @State private var searchText: String = ""
    @State private var replaceText: String = ""
    @State private var caseSensitive: Bool = false
    @State private var useRegex: Bool = false
    @State private var searchResults: [Range<String.Index>] = []
    @State private var currentResultIndex: Int = 0
    
    var body: some View {
        HStack(spacing: 12) {
            // Find field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                TextField("Find", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 13))
                    .onChange(of: searchText) { _, _ in
                        performSearch()
                    }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(6)
            
            // Replace field
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                TextField("Replace", text: $replaceText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 13))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(6)
            
            // Options
            HStack(spacing: 8) {
                Toggle("Aa", isOn: $caseSensitive)
                    .toggleStyle(AppleToggleStyle())
                    .font(.system(size: 11))
                
                Toggle(".*", isOn: $useRegex)
                    .toggleStyle(AppleToggleStyle())
                    .font(.system(size: 11))
            }
            
            // Results count
            if !searchResults.isEmpty {
                Text("\(currentResultIndex + 1) of \(searchResults.count)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 6) {
                AppleToolbarButton(
                    icon: "arrow.up",
                    action: previousResult
                )
                .disabled(searchResults.isEmpty)
                
                AppleToolbarButton(
                    icon: "arrow.down",
                    action: nextResult
                )
                .disabled(searchResults.isEmpty)
                
                AppleToolbarButton(
                    icon: "arrow.triangle.2.circlepath",
                    action: replaceCurrent
                )
                .disabled(searchResults.isEmpty)
                
                AppleToolbarButton(
                    icon: "arrow.triangle.2.circlepath.circle",
                    action: replaceAll
                )
                .disabled(searchResults.isEmpty)
            }
            
            // Close button
            AppleToolbarButton(
                icon: "xmark",
                action: { isVisible = false }
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separatorColor)),
            alignment: .bottom
        )
    }
    
    private func performSearch() {
        // Implementation would go here
    }
    
    private func nextResult() {
        // Implementation would go here
    }
    
    private func previousResult() {
        // Implementation would go here
    }
    
    private func replaceCurrent() {
        // Implementation would go here
    }
    
    private func replaceAll() {
        // Implementation would go here
    }
}

struct AppleToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                configuration.label
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(configuration.isOn ? .primary : .secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(configuration.isOn ? Color(.controlColor) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
