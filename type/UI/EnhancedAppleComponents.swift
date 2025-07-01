//
//  EnhancedAppleComponents.swift
//  type
//
//  Enhanced Apple-style UI components migrated from ContentView.swift
//

import SwiftUI

// MARK: - Animation Speed Enum
enum AnimationSpeed: String, CaseIterable {
    case slow = "Slow"
    case normal = "Normal"
    case fast = "Fast"
    
    var duration: Double {
        switch self {
        case .slow: return 0.8
        case .normal: return 0.4
        case .fast: return 0.2
        }
    }
    
    var icon: String {
        switch self {
        case .slow: return "tortoise"
        case .normal: return "speedometer"
        case .fast: return "hare"
        }
    }
}

// MARK: - Enhanced Apple-style Toolbar
struct EnhancedAppleToolbar: View {
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
    @Binding var showCustomizationPanel: Bool
    @Binding var animationSpeed: AnimationSpeed
    let onNewDocument: () -> Void
    let onOpenDocument: () -> Void
    let onSaveDocument: () -> Void
    let onSaveDocumentAs: () -> Void
    let onExportDocument: () -> Void
    let canSave: Bool
    let isDocumentModified: Bool
    let currentDocumentName: String
    
    // Collaboration parameters
    @Binding var showCommentsPanel: Bool
    @Binding var showVersionHistory: Bool
    @Binding var showCollaboratorsPanel: Bool
    @Binding var showSharingDialog: Bool
    let collaboratorCount: Int
    let commentCount: Int
    
    // Template selector
    @Binding var showTemplateSelector: Bool
    
    // Character database
    @Binding var showCharacterDatabase: Bool
    let characterCount: Int
    
    // Outline database
    @Binding var showOutlineMode: Bool
    let outlineDatabase: OutlineDatabase
    
    var body: some View {
        HStack(spacing: 12) {
            // File operations with enhanced styling
            HStack(spacing: 6) {
                EnhancedAppleToolbarButton(
                    icon: "doc.badge.plus",
                    label: "New",
                    action: onNewDocument
                )
                
                EnhancedAppleToolbarButton(
                    icon: "folder",
                    label: "Open",
                    action: onOpenDocument
                )
                
                EnhancedAppleToolbarButton(
                    icon: "square.and.arrow.down",
                    label: "Save",
                    action: onSaveDocument
                )
                .disabled(!canSave)
                
                // Save As dropdown
                Menu {
                    Button("Save As...") {
                        onSaveDocumentAs()
                    }
                    Button("Export to PDF...") {
                        onExportDocument()
                    }
                    Button("Export to Final Draft...") {
                        onExportDocument()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .disabled(!canSave)
            }
            
            AppleDivider()
            
            // Template selector
            EnhancedAppleToolbarButton(
                icon: "doc.text",
                label: "Template",
                action: { showTemplateSelector = true }
            )
            
            AppleDivider()
            
            // Edit operations
            HStack(spacing: 6) {
                EnhancedAppleToolbarButton(
                    icon: "arrow.uturn.backward",
                    action: onUndo
                )
                .disabled(!canUndo)
                
                EnhancedAppleToolbarButton(
                    icon: "arrow.uturn.forward",
                    action: onRedo
                )
                .disabled(!canRedo)
                
                EnhancedAppleToolbarButton(
                    icon: "magnifyingglass",
                    action: { showFindReplace.toggle() }
                )
            }
            
            AppleDivider()
            
            // Formatting options with enhanced styling
            HStack(spacing: 8) {
                Picker("Font", selection: $selectedFont) {
                    Text("SF Mono").tag("SF Mono")
                    Text("Menlo").tag("Menlo")
                    Text("Monaco").tag("Monaco")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
                
                HStack(spacing: 4) {
                    EnhancedAppleToolbarButton(
                        icon: "textformat.size.smaller",
                        action: { fontSize = max(10, fontSize - 1) }
                    )
                    
                    Text("\(Int(fontSize))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 25)
                    
                    EnhancedAppleToolbarButton(
                        icon: "textformat.size.larger",
                        action: { fontSize = min(20, fontSize + 1) }
                    )
                }
            }
            
            Spacer()
            
            // View controls with customization
            HStack(spacing: 6) {
                EnhancedAppleToolbarButton(
                    icon: showLineNumbers ? "list.number" : "list.number.fill",
                    action: { showLineNumbers.toggle() }
                )
                
                EnhancedAppleToolbarButton(
                    icon: "paintbrush",
                    action: { showCustomizationPanel.toggle() }
                )
                
                EnhancedAppleToolbarButton(
                    icon: "questionmark.circle",
                    action: { showHelp = true }
                )
                
                EnhancedAppleToolbarButton(
                    icon: showPreview ? "eye.slash" : "eye",
                    action: { showPreview.toggle() }
                )
                
                EnhancedAppleToolbarButton(
                    icon: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right",
                    action: { isFullScreen.toggle() }
                )
            }
            
            AppleDivider()
            
            // Collaboration controls
            HStack(spacing: 6) {
                EnhancedAppleToolbarButton(
                    icon: "bubble.left.and.bubble.right",
                    action: { showCommentsPanel.toggle() }
                )
                .overlay(
                    Group {
                        if commentCount > 0 {
                            Text("\(commentCount)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.red)
                                )
                                .offset(x: 8, y: -8)
                        }
                    }
                )
                
                EnhancedAppleToolbarButton(
                    icon: "clock.arrow.circlepath",
                    action: { showVersionHistory.toggle() }
                )
                
                EnhancedAppleToolbarButton(
                    icon: "person.2",
                    action: { showCollaboratorsPanel.toggle() }
                )
                .overlay(
                    Group {
                        if collaboratorCount > 0 {
                            Text("\(collaboratorCount)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.green)
                                )
                                .offset(x: 8, y: -8)
                        }
                    }
                )
                
                EnhancedAppleToolbarButton(
                    icon: "square.and.arrow.up",
                    action: { showSharingDialog = true }
                )
            }
            
            AppleDivider()
            
            // Character database
            EnhancedAppleToolbarButton(
                icon: "person.3",
                label: "Characters",
                action: { showCharacterDatabase = true }
            )
            .overlay(
                Group {
                    if characterCount > 0 {
                        Text("\(characterCount)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.blue)
                            )
                            .offset(x: 8, y: -8)
                    }
                }
            )
            
            // Outline mode
            EnhancedAppleToolbarButton(
                icon: "list.bullet",
                label: "Outline",
                action: { self.showOutlineMode = true }
            )
            .overlay(
                Group {
                    if self.outlineDatabase.statistics.totalNodes > 0 {
                        Text("\(self.outlineDatabase.statistics.totalNodes)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.green)
                            )
                            .offset(x: 8, y: -8)
                    }
                }
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
}

// MARK: - Enhanced Apple-style Components
struct EnhancedAppleToolbarButton: View {
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
        .buttonStyle(EnhancedAppleButtonStyle())
    }
}

struct EnhancedAppleButtonStyle: ButtonStyle {
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
            .frame(width: 1, height: 20)
            .foregroundColor(Color(.separatorColor))
    }
}

// MARK: - Enhanced Editor Header
struct EnhancedAppleEditorHeader: View {
    let wordCount: Int
    let pageCount: Int
    let characterCount: Int
    let showStatistics: Bool
    @Binding var showAutoCompletion: Bool
    @Binding var showWritingGoals: Bool
    let dailyWordGoal: Int
    let currentDailyWords: Int
    
    var body: some View {
        HStack {
            Text("Editor")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            if showStatistics {
                HStack(spacing: 16) {
                    EnhancedAppleStatisticView(label: "Words", value: "\(wordCount)")
                    EnhancedAppleStatisticView(label: "Pages", value: "\(pageCount)")
                    EnhancedAppleStatisticView(label: "Chars", value: "\(characterCount)")
                    
                    // Writing goal progress
                    if showWritingGoals {
                        WritingGoalProgressView(
                            current: currentDailyWords,
                            goal: dailyWordGoal
                        )
                    }
                }
            }
            
            Button(action: { showAutoCompletion.toggle() }) {
                Image(systemName: showAutoCompletion ? "textformat.abc" : "textformat.abc.dottedunderline")
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
            }
            .buttonStyle(EnhancedAppleButtonStyle())
            
            Button(action: { showWritingGoals.toggle() }) {
                Image(systemName: "target")
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
            }
            .buttonStyle(EnhancedAppleButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Enhanced Supporting Views
struct EnhancedAppleStatisticView: View {
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

struct WritingGoalProgressView: View {
    let current: Int
    let goal: Int
    
    private var progress: Double {
        min(Double(current) / Double(goal), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Text("\(current)")
                    .font(.system(size: 12, weight: .semibold))
                Text("/")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Text("\(goal)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.separatorColor))
                        .frame(height: 2)
                    
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progress, height: 2)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(width: 40, height: 2)
        }
    }
    
    private var progressColor: Color {
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.7 {
            return .orange
        } else {
            return .blue
        }
    }
}

// MARK: - Enhanced Preview Header
struct EnhancedApplePreviewHeader: View {
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

// MARK: - Enhanced Status Bar
struct EnhancedAppleStatusBar: View {
    let wordCount: Int
    let pageCount: Int
    let characterCount: Int
    @Binding var showStatistics: Bool
    let smartFormattingManager: SmartFormattingManager
    let animationSpeed: AnimationSpeed
    let autoSaveEnabled: Bool
    let isDocumentModified: Bool
    let currentDocumentName: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Document info and status
            HStack(spacing: 12) {
                // Document name and modification status
                HStack(spacing: 6) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Text(currentDocumentName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if isDocumentModified {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.orange)
                    }
                }
                
                // Auto-save status
                HStack(spacing: 4) {
                    Image(systemName: autoSaveEnabled ? "clock.arrow.circlepath" : "clock.slash")
                        .font(.system(size: 11))
                        .foregroundColor(autoSaveEnabled ? .green : .secondary)
                    
                    Text(autoSaveEnabled ? "Auto-save" : "Manual save")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
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
            .buttonStyle(EnhancedAppleButtonStyle())
            
            // Right side - Smart formatting and ready status
            HStack(spacing: 16) {
                // Smart formatting status
                HStack(spacing: 6) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                    Text("Smart formatting enabled")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                // Fountain format indicator
                Text("Fountain Format")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                // Ready status
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

// MARK: - Customization Panel
struct CustomizationPanel: View {
    @Binding var animationSpeed: AnimationSpeed
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Customization")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Button(action: { isVisible = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                }
                .buttonStyle(EnhancedAppleButtonStyle())
            }
            
            // Animation Speed
            VStack(alignment: .leading, spacing: 12) {
                Text("Animation Speed")
                    .font(.system(size: 14, weight: .medium))
                
                ForEach(AnimationSpeed.allCases, id: \.self) { speed in
                    Button(action: { animationSpeed = speed }) {
                        HStack {
                            Image(systemName: speed.icon)
                                .font(.system(size: 14))
                            Text(speed.rawValue)
                                .font(.system(size: 14))
                            Spacer()
                            if animationSpeed == speed {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(animationSpeed == speed ? Color(.controlColor) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .frame(width: 250)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        .padding(.trailing, 20)
    }
}

// MARK: - Enhanced Auto-completion Overlay
struct EnhancedAppleAutoCompletionOverlay: View {
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
                .buttonStyle(.plain)
                
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

// MARK: - Enhanced Find/Replace View
struct EnhancedAppleFindReplaceView: View {
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
                EnhancedAppleToolbarButton(
                    icon: "arrow.up",
                    action: previousResult
                )
                .disabled(searchResults.isEmpty)
                
                EnhancedAppleToolbarButton(
                    icon: "arrow.down",
                    action: nextResult
                )
                .disabled(searchResults.isEmpty)
                
                EnhancedAppleToolbarButton(
                    icon: "arrow.triangle.2.circlepath",
                    action: replaceCurrent
                )
                .disabled(searchResults.isEmpty)
                
                EnhancedAppleToolbarButton(
                    icon: "arrow.triangle.2.circlepath.circle",
                    action: replaceAll
                )
                .disabled(searchResults.isEmpty)
            }
            
            // Close button
            EnhancedAppleToolbarButton(
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
        .buttonStyle(.plain)
    }
} 