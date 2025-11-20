//
//  EnhancedAppleComponents.swift
//  type
//
//  Enhanced Apple-style UI components migrated from ContentView.swift
//

import SwiftUI

enum ToolbarMetrics {
    static let rowSpacing: CGFloat = 6
    static let buttonHeight: CGFloat = 28
    static let iconSize: CGFloat = 13
    static let labelFontSize: CGFloat = 12
    static let horizontalPadding: CGFloat = 12
    static let verticalPadding: CGFloat = 6
    static let groupSpacing: CGFloat = 12
    static let itemSpacing: CGFloat = 8
    static let buttonHorizontalPadding: CGFloat = 10
    static let dividerHeight: CGFloat = 20
    static let badgeHorizontalOffset: CGFloat = 10
    static let barHeight: CGFloat = buttonHeight * 3 + rowSpacing * 2 + verticalPadding * 2
}

struct EditorToolbarContext {
    let isFocusMode: Bool
    let isTypewriterMode: Bool
    let hasMultipleCursors: Bool
    let isMinimapVisible: Bool
    let wordCount: Int
    let pageCount: Int
    let characterCount: Int
    let toggleFocusMode: () -> Void
    let toggleTypewriterMode: () -> Void
    let toggleMultipleCursors: () -> Void
    let toggleMinimap: () -> Void
}

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
    let showFindReplace: Bool
    let showHelp: Bool
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
    
    // Editor specific context
    let editorContext: EditorToolbarContext?
    
    // Story Protocol
    let storyProtocolService: StoryProtocolService
    let onProtect: () -> Void
    let onNetworkSelect: () -> Void
    
    let onToggleFindReplace: () -> Void
    let onToggleHelp: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: ToolbarMetrics.rowSpacing) {
            topRow
            middleRow
            bottomRow
        }
        .padding(.horizontal, ToolbarMetrics.horizontalPadding)
        .padding(.vertical, ToolbarMetrics.verticalPadding)
        .frame(minHeight: ToolbarMetrics.barHeight, alignment: .center)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separatorColor)),
            alignment: .bottom
        )
    }
    
    private var topRow: some View {
        HStack(alignment: .center, spacing: ToolbarMetrics.itemSpacing * 2) {
            fileOperationsGroup
            
            AppleDivider()
            
            templateButton
            
            AppleDivider()
            
            editOperationsGroup
            
            Spacer(minLength: 0)
        }
    }
    
    private var middleRow: some View {
        HStack(alignment: .center, spacing: ToolbarMetrics.groupSpacing) {
            formattingGroup
            
            AppleDivider()
            
            viewControlsGroup
            
            if let context = editorContext {
                AppleDivider()
                editorFeaturesGroup(context)
            }
            
            Spacer(minLength: 0)
        }
    }
    
    private var bottomRow: some View {
        HStack(alignment: .center, spacing: ToolbarMetrics.groupSpacing) {
            if let context = editorContext {
                editorStatsGroup(context)
                
                AppleDivider()
            }
            
            collaborationGroup
            
            AppleDivider()
            charactersButton
            outlineButton
            
            AppleDivider()
            storyProtocolGroup
            
            Spacer(minLength: 0)
        }
    }
    
    private var fileOperationsGroup: some View {
        HStack(spacing: ToolbarMetrics.itemSpacing) {
                EnhancedAppleToolbarButton(
                    icon: "doc.badge.plus",
                    label: "New",
                    isActive: false,
                    action: onNewDocument
                )
                
                EnhancedAppleToolbarButton(
                    icon: "folder",
                    label: "Open",
                    isActive: false,
                    action: onOpenDocument
                )
                
                EnhancedAppleToolbarButton(
                    icon: "square.and.arrow.down",
                    label: "Save",
                    isActive: false,
                    action: onSaveDocument
                )
                .disabled(!canSave)
                
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
                    EnhancedAppleToolbarMenuLabel(icon: "chevron.down", accessibilityLabel: "Save & Export Options")
                }
                .menuStyle(.borderlessButton)
                .disabled(!canSave)
            }
            }
            
    private var templateButton: some View {
            EnhancedAppleToolbarButton(
                icon: "doc.text",
                label: "Template",
                isActive: showTemplateSelector,
                action: { showTemplateSelector = true }
            )
    }
    
    private var editOperationsGroup: some View {
        HStack(spacing: ToolbarMetrics.itemSpacing) {
                EnhancedAppleToolbarButton(
                    icon: "arrow.uturn.backward",
                    label: "Undo",
                    isActive: false,
                    action: onUndo
                )
                .disabled(!canUndo)
                
                EnhancedAppleToolbarButton(
                    icon: "arrow.uturn.forward",
                    label: "Redo",
                    isActive: false,
                    action: onRedo
                )
                .disabled(!canRedo)
                
                EnhancedAppleToolbarButton(
                    icon: "magnifyingglass",
                    label: "Find",
                    isActive: showFindReplace,
                    action: onToggleFindReplace
                )
            }
    }
    
    private var formattingGroup: some View {
        HStack(spacing: ToolbarMetrics.itemSpacing) {
                Picker("Font", selection: $selectedFont) {
                    Text("SF Mono").tag("SF Mono")
                    Text("Menlo").tag("Menlo")
                    Text("Monaco").tag("Monaco")
                }
                .pickerStyle(MenuPickerStyle())
                .labelsHidden()
                .frame(width: 110)
                .frame(height: ToolbarMetrics.buttonHeight)
                
                HStack(spacing: ToolbarMetrics.itemSpacing) {
                    EnhancedAppleToolbarButton(
                        icon: "textformat.size.smaller",
                    isActive: false,
                        action: { fontSize = max(10, fontSize - 1) }
                    )
                    
                    Text("\(Int(fontSize))")
                        .font(.system(size: ToolbarMetrics.labelFontSize, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 28, height: ToolbarMetrics.buttonHeight)
                    
                    EnhancedAppleToolbarButton(
                        icon: "textformat.size.larger",
                        isActive: false,
                        action: { fontSize = min(20, fontSize + 1) }
                    )
                }
            }
            }
            
    private var viewControlsGroup: some View {
        HStack(spacing: ToolbarMetrics.itemSpacing) {
                EnhancedAppleToolbarButton(
                    icon: "list.number",
                    label: "Line #",
                    isActive: showLineNumbers,
                    action: { showLineNumbers.toggle() }
                )
                
                EnhancedAppleToolbarButton(
                    icon: "paintbrush",
                    label: "Style",
                    isActive: showCustomizationPanel,
                    action: { showCustomizationPanel.toggle() }
                )
                
                EnhancedAppleToolbarButton(
                    icon: "questionmark.circle",
                    label: "Help",
                    isActive: showHelp,
                    action: onToggleHelp
                )
                
                EnhancedAppleToolbarButton(
                    icon: "eye",
                    label: "Preview",
                    isActive: showPreview,
                    action: { showPreview.toggle() }
                )
                
                EnhancedAppleToolbarButton(
                    icon: "arrow.up.left.and.arrow.down.right",
                    label: isFullScreen ? "Exit Full" : "Full",
                    isActive: isFullScreen,
                    action: { isFullScreen.toggle() }
                )
            }
    }
    
    private func editorFeaturesGroup(_ context: EditorToolbarContext) -> some View {
        HStack(spacing: ToolbarMetrics.itemSpacing) {
            ToolbarToggleButton(
                isActive: context.isFocusMode,
                icon: "eye.slash.fill",
                label: "Focus",
                help: "Toggle Focus Mode",
                action: context.toggleFocusMode
            )
            
            ToolbarToggleButton(
                isActive: context.isTypewriterMode,
                icon: "keyboard.fill",
                label: "Typewriter",
                help: "Toggle Typewriter Mode",
                action: context.toggleTypewriterMode
            )
            
            ToolbarToggleButton(
                isActive: context.hasMultipleCursors,
                icon: "cursorarrow.rays",
                label: "Cursors",
                help: "Toggle Multiple Cursors",
                action: context.toggleMultipleCursors
            )
            
            ToolbarToggleButton(
                isActive: context.isMinimapVisible,
                icon: "map",
                label: "Minimap",
                help: "Toggle Minimap",
                action: context.toggleMinimap
            )
        }
    }
    
    private func editorStatsGroup(_ context: EditorToolbarContext) -> some View {
        HStack(spacing: ToolbarMetrics.itemSpacing) {
            Text("Words: \(context.wordCount)")
            Text("Pages: \(context.pageCount)")
            Text("Chars: \(context.characterCount)")
        }
        .font(.system(size: ToolbarMetrics.labelFontSize - 1, weight: .medium))
        .foregroundColor(.secondary)
    }
    
    private var collaborationGroup: some View {
        HStack(spacing: ToolbarMetrics.itemSpacing) {
                EnhancedAppleToolbarButton(
                    icon: "bubble.left.and.bubble.right",
                    label: "Comments",
                    isActive: showCommentsPanel,
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
                                .offset(x: ToolbarMetrics.badgeHorizontalOffset, y: -ToolbarMetrics.buttonHeight / 2)
                        }
                    }
                )
                
                EnhancedAppleToolbarButton(
                    icon: "clock.arrow.circlepath",
                    label: "Versions",
                    isActive: showVersionHistory,
                    action: { showVersionHistory.toggle() }
                )
                
                EnhancedAppleToolbarButton(
                    icon: "person.2",
                    label: "Collaborators",
                    isActive: showCollaboratorsPanel,
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
                                .offset(x: ToolbarMetrics.badgeHorizontalOffset, y: -ToolbarMetrics.buttonHeight / 2)
                        }
                    }
                )
                
                EnhancedAppleToolbarButton(
                    icon: "square.and.arrow.up",
                    label: "Share",
                    isActive: showSharingDialog,
                    action: { showSharingDialog.toggle() }
                )
            }
            }
            
    private var charactersButton: some View {
            EnhancedAppleToolbarButton(
                icon: "person.3",
                label: "Characters",
                isActive: showCharacterDatabase,
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
                            .offset(x: ToolbarMetrics.badgeHorizontalOffset, y: -ToolbarMetrics.buttonHeight / 2)
                    }
                }
            )
    }
            
    private var outlineButton: some View {
            EnhancedAppleToolbarButton(
                icon: "list.bullet",
                label: "Outline",
                isActive: showOutlineMode,
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
                            .offset(x: ToolbarMetrics.badgeHorizontalOffset, y: -ToolbarMetrics.buttonHeight / 2)
                    }
                }
        )
    }
    
    private var storyProtocolGroup: some View {
        HStack(spacing: ToolbarMetrics.itemSpacing) {
            // Network selector
            Menu {
                ForEach(StoryProtocolNetwork.allCases, id: \.self) { network in
                    Button(action: {
                        Task {
                            await storyProtocolService.switchNetwork(network)
                        }
                    }) {
                        HStack {
                            Text(network.rawValue)
                            if storyProtocolService.selectedNetwork == network {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: storyProtocolService.connectionStatus.icon)
                        .font(.system(size: ToolbarMetrics.iconSize))
                        .foregroundColor(storyProtocolService.connectionStatus.color)
                    
                    Text(storyProtocolService.selectedNetwork.rawValue)
                        .font(.system(size: ToolbarMetrics.labelFontSize, weight: .medium))
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .foregroundColor(.primary)
            }
            .buttonStyle(EnhancedAppleButtonStyle())
            .help("Select Story Protocol Network")
            
            // Protect button
            EnhancedAppleToolbarButton(
                icon: "shield.lefthalf.filled",
                label: "Protect",
                isActive: storyProtocolService.protectionStatus.isProtected,
                action: onProtect
            )
            .help("Protect screenplay as IP on Story Protocol")
            .overlay(
                Group {
                    if storyProtocolService.protectionStatus.isProtected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                            .background(Circle().fill(Color.white))
                            .offset(x: ToolbarMetrics.badgeHorizontalOffset, y: -ToolbarMetrics.buttonHeight / 2)
                    }
                }
            )
        }
    }
}

// MARK: - Enhanced Apple-style Components
struct EnhancedAppleToolbarButton: View {
    let icon: String
    var label: String?
    var isActive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: ToolbarMetrics.iconSize))
                    .foregroundColor(isActive ? .accentColor : .primary)
                if let label = label {
                    Text(label)
                        .font(.system(size: ToolbarMetrics.labelFontSize, weight: .medium))
                        .foregroundColor(isActive ? .accentColor : .primary)
                }
            }
        }
        .buttonStyle(EnhancedAppleButtonStyle(isActive: isActive))
    }
}

private struct ToolbarToggleButton: View {
    let isActive: Bool
    let icon: String
    let label: String
    let help: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: ToolbarMetrics.iconSize))
                Text(label)
                    .font(.system(size: ToolbarMetrics.labelFontSize, weight: .medium))
            }
            .foregroundColor(isActive ? .accentColor : .primary)
        }
        .buttonStyle(EnhancedAppleButtonStyle(isActive: isActive))
        .help(help ?? "")
        .accessibilityLabel(help ?? label)
    }
}

struct EnhancedAppleButtonStyle: ButtonStyle {
    var isActive: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: ToolbarMetrics.buttonHeight)
            .padding(.horizontal, ToolbarMetrics.buttonHorizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(configuration.isPressed ? Color(.controlColor) : (isActive ? Color.accentColor.opacity(0.12) : Color.clear))
            )
            .contentShape(RoundedRectangle(cornerRadius: 6))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AppleDivider: View {
    var body: some View {
        Rectangle()
            .frame(width: 1, height: ToolbarMetrics.dividerHeight)
            .foregroundColor(Color(.separatorColor))
    }
}

struct EnhancedAppleToolbarMenuLabel: View {
    let icon: String
    var accessibilityLabel: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: ToolbarMetrics.iconSize))
        }
        .foregroundColor(.primary)
        .frame(height: ToolbarMetrics.buttonHeight)
        .padding(.horizontal, ToolbarMetrics.buttonHorizontalPadding)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.clear)
        )
        .accessibilityLabel(accessibilityLabel)
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
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
            Text("Editor")
                    .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
                
                HStack(spacing: ToolbarMetrics.itemSpacing) {
                    HeaderIconButton(
                        systemImage: showAutoCompletion ? "textformat.abc" : "textformat.abc.dottedunderline",
                        accessibilityLabel: showAutoCompletion ? "Disable Auto-completion" : "Enable Auto-completion",
                        action: { showAutoCompletion.toggle() }
                    )
                    
                    HeaderIconButton(
                        systemImage: "target",
                        accessibilityLabel: showWritingGoals ? "Hide Writing Goals" : "Show Writing Goals",
                        action: { showWritingGoals.toggle() }
                    )
                }
            }
            
            if showStatistics {
                HStack(spacing: 12) {
                    EnhancedAppleStatisticView(label: "Words", value: "\(wordCount)")
                    EnhancedAppleStatisticView(label: "Pages", value: "\(pageCount)")
                    EnhancedAppleStatisticView(label: "Chars", value: "\(characterCount)")
                    
                    if showWritingGoals {
                        WritingGoalProgressView(
                            current: currentDailyWords,
                            goal: dailyWordGoal
                        )
                    }
                    
                    Spacer(minLength: 0)
                }
            }
            }
        .padding(.horizontal, ToolbarMetrics.horizontalPadding)
        .padding(.vertical, ToolbarMetrics.verticalPadding)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Enhanced Supporting Views
struct EnhancedAppleStatisticView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 11, weight: .semibold))
            Text(label)
                .font(.system(size: 9))
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
        VStack(spacing: 1) {
            HStack(spacing: 3) {
                Text("\(current)")
                    .font(.system(size: 11, weight: .semibold))
                Text("/")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                Text("\(goal)")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.separatorColor))
                        .frame(height: 1.5)
                    
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progress, height: 1.5)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(width: 38, height: 2)
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

private struct HeaderIconButton: View {
    let systemImage: String
    let accessibilityLabel: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: ToolbarMetrics.iconSize))
                .foregroundColor(.primary)
                .frame(height: ToolbarMetrics.buttonHeight)
                .padding(.horizontal, ToolbarMetrics.buttonHorizontalPadding)
        }
        .buttonStyle(EnhancedAppleButtonStyle())
        .accessibilityLabel(accessibilityLabel)
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
// MARK: - Enhanced General Components

struct EnhancedStatCard: View {
    let title: String
    let value: String
    let icon: String
    var color: Color = .accentColor
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                Spacer()
            }
            
            HStack(alignment: .bottom) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
                
                Spacer()
            }
        }
        .padding(12)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separatorColor), lineWidth: 0.5)
        )
    }
}

struct EnhancedHeaderView<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content
    
    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                content
            }
        }
        .padding(ToolbarMetrics.horizontalPadding)
        .background(Color(.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separatorColor)),
            alignment: .bottom
        )
    }
}

struct EnhancedSearchField: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 13))
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(.separatorColor), lineWidth: 0.5)
        )
    }
}
